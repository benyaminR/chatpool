part of chat_pool;


class ChatScreen extends StatefulWidget{

  final String friendId;
  ChatScreen({@required this.friendId});

  @override
  State<StatefulWidget> createState() => ChatScreenState(friendId: friendId);
}

class ChatScreenState extends State<ChatScreen>{

  final String friendId;

  var imageFile;

  String friendDisplayName;
  String friendPhotoUri;
  String groupId;
  String id;

  final TextEditingController _textEditingController = new TextEditingController();

  ChatScreenState({@required this.friendId});

  @override
  void initState() {
    super.initState();
    _init();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: CHAT_SCREEN_BACKGROUND,
        body: (friendPhotoUri == null || friendDisplayName == null) ?
          Center(
              child:CircularProgressIndicator()
          )
            :
          _chatScreenBody(),
        appBar: AppBar(
          title: (friendPhotoUri == null || friendDisplayName == null) ?  null :_appBarTitle(),
          actions: _appBarActions(),
        )
    );
  }

  Widget _appBarTitle() {
    return  Row(
      children: <Widget>[
        Container(
          child: Material(
            child: CachedNetworkImage(
              placeholder: Container(
                child: CircularProgressIndicator(),
              ),
              imageUrl: friendPhotoUri,
              width: APP_BAR_IMAGE_WIDTH,
              height: APP_BAR_IMAGE_HEIGHT,
            ),
            borderRadius: BorderRadius.all(Radius.circular(APP_BAR_IMAGE_RADIUS)),
            clipBehavior: Clip.antiAlias,
          ),
        ),
        Text(friendDisplayName)
      ],
    );
  }

  List<Widget> _appBarActions(){
    return null;
  }

  Widget _chatScreenBody(){
    return Column(
      children: <Widget>[
        _chatSegment(),
        _inputSegment()
      ],
    );
  }

  Widget _chatSegment(){
    return Flexible(
      child:Container(
          child: StreamBuilder(
            stream: _firestore
                .collection(MESSAGES_COLLECTION)             //Messages
                .document(groupId)                           //this groupId
                .collection(groupId)                         //their collection of messages
                .orderBy(MESSAGE_TIMESTAMP,descending: true) // order messages by time
                .snapshots(),
            builder: (BuildContext buildContext,AsyncSnapshot<QuerySnapshot>snapshots){
              //show error if there is any
              if(snapshots.hasError)
                return Text(snapshots.error);
              //if connecting show progressIndicator
              if(snapshots.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              //show users
              else
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshots.data.documents.length,
                  itemBuilder:(context,index)=> _chatItemBuilder(snapshots.data.documents[index]),
                );
            },
          )
      ),
    );
  }

  Widget _inputSegment(){
    return Container(
        margin: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Flexible(
                child: Container(
                  decoration: BoxDecoration(
                      color: INPUT_TEXT_FIELD_BACKGROUND_COLOR,
                      borderRadius: BorderRadius.circular(INPUT_TEXT_FIELD_RADIUS)
                  ),
                  child: imageFile == null ? TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(INPUT_TEXT_FIELD_PADDING),
                      border: InputBorder.none,
                      hintText: TEXT_FIELD_HINT,
                      hintStyle: TextStyle(
                        color: INPUT_TEXT_FIELD_HINT_COLOR
                      )
                    ),
                    controller: _textEditingController,
                  )
                      : Container(
                    padding: EdgeInsets.all(10.0),
                    margin: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Image(
                      image: FileImage(imageFile),
                  ),
                  ),
                )
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(SEND_BUTTON_PADDING),
                margin: EdgeInsets.all(SEND_BUTTON_MARGIN),
                decoration: BoxDecoration(
                  color: PICK_BUTTON_BACKGROUND_COLOR,
                  borderRadius: BorderRadius.circular(SEND_BUTTON_RADIUS),
                ),
                child:Icon(Icons.image,color: PICK_BUTTON_ICON_COLOR,),
              ),
              onTap: ()=>null,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(SEND_BUTTON_PADDING),
                margin: EdgeInsets.all(SEND_BUTTON_MARGIN),
                decoration: BoxDecoration(
                  color: SEND_BUTTON_BACKGROUND_COLOR,
                  borderRadius: BorderRadius.circular(SEND_BUTTON_RADIUS),
                ),
                child: Icon(Icons.send,color: SEND_BUTTON_ICON_COLOR,),
              ),
              onTap:(){
                if(_textEditingController.value.text.isNotEmpty) {
                  sendMessage(_textEditingController.value.text, groupId, id, friendId);
                  _textEditingController.clear();
                }
              },
            ),
          ],
        ) ,
      );
  }

  Widget _chatItemBuilder(DocumentSnapshot document){
    return GestureDetector(
        child: Row(
          mainAxisAlignment: document[MESSAGE_ID_FROM] == id ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                  width: MESSAGE_WIDTH,
                  padding: EdgeInsets.all(MESSAGE_PADDING),
                  margin: EdgeInsets.all(MESSAGE_MARGIN),
                  decoration: BoxDecoration(
                      color: MESSAGE_BACKGROUND_COLOR,
                      borderRadius: BorderRadius.circular(MESSAGE_RADIUS)
                  ),
                  child:Column(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child:Text(document[MESSAGE_CONTENT],
                            style: TextStyle(
                                fontSize: MESSAGE_FONT_SIZE,
                                color: MESSAGE_FONT_COLOR
                            ),
                          )
                      ),
                      Align(
                        alignment:Alignment.centerRight ,
                        child: Text(timeConverter(int.parse(document[MESSAGE_TIMESTAMP])),
                          style: TextStyle(
                              fontSize: MESSAGE_DATE_FONT_SIZE,
                              color: MESSAGE_FONT_COLOR
                          ),),
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
        onLongPress:() {
          //delete only my messages
          document[MESSAGE_ID_FROM]== id ? _showDeleteDialog(document[MESSAGE_TIMESTAMP]): null;
        }
    );
  }

  _showDeleteDialog(String timestamp){
    showDialog(context: context,builder:(BuildContext buildContext){
      return AlertDialog(
        title: Text('delete'),
        content: Text('do you want to delete this message?'),
        actions: <Widget>[
          FlatButton(
            child: Text('delete'),
            onPressed:(){
              Navigator.pop(context);
              _deleteMessage(timestamp,groupId);},
          ),
          FlatButton(
            child: Text('cancel'),
            onPressed:()=> Navigator.pop(context),
          )
        ],
      );
    });
  }


  _init(){
    _getFriendInfo();
    _getGroupChatId();
  }


  _getGroupChatId()async{
    var sp = await SharedPreferences.getInstance();
    id = sp.get(SHARED_PREFERENCES_USER_ID);
    if(id.hashCode < friendId.hashCode){
      groupId = '$friendId-$id';
    }else{
      groupId = '$id-$friendId';
    }
  }

  _getFriendInfo()async{
    var document = await getFriendById(friendId);
    friendDisplayName = document[USER_DISPLAY_NAME];
    friendPhotoUri = document[USER_PHOTO_URI] != null ?  document[USER_PHOTO_URI] : USER_IMAGE_PLACE_HOLDER;
    setState(() {
    });
  }
}