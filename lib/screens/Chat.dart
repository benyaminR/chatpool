part of chat_pool;


class ChatScreen extends StatefulWidget{
  final String friendId;

  ChatScreen({@required this.friendId});

  @override
  State<StatefulWidget> createState() => ChatScreenState(friendId: friendId);
}

class ChatScreenState extends State<ChatScreen>{

  final String friendId;

  String friendDisplayName;
  String friendPhotoUri;
  String groupId;
  String id;

  final TextEditingController _textEditingController = new TextEditingController();
  final ScrollController _scrollController = new ScrollController();

  ChatScreenState({@required this.friendId});

  @override
  void initState() {
    super.initState();
    _init();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.grey,
        body: (friendPhotoUri == null || friendDisplayName == null) ?  CircularProgressIndicator(): _chatScreenBody(),
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
          margin: EdgeInsets.all(2.0),
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
                .collection(MESSAGES_COLLECTION)
                .document(groupId)
                .collection(groupId)
                .orderBy(MESSAGE_TIMESTAMP,descending: true)
                .snapshots(),
            builder: (BuildContext buildContext,AsyncSnapshot<QuerySnapshot>snapshots){
              if(snapshots.hasError)
                return Text(snapshots.error);
              if(snapshots.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();
              else
                return ListView.builder(
                  controller: _scrollController,
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
                  child: TextField(
                    autocorrect: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(INPUT_TEXT_FIELD_PADDING),
                      border: InputBorder.none,
                      hintText: TEXT_FIELD_HINT,
                    ),
                    controller: _textEditingController,
                  ),
                )
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(SEND_BUTTON_PADDING),
                margin: EdgeInsets.all(SEND_BUTTON_MARGIN),
                decoration: BoxDecoration(
                  color: SEND_BUTTON_BACKGROUND_COLOR,
                  borderRadius: BorderRadius.circular(SEND_BUTTON_RADIUS),
                ),
                child:  Icon(Icons.send),
              ),
              onTap: _sendMessage,
            ),
          ],
        ) ,
      );
  }

  Widget _chatItemBuilder(DocumentSnapshot document){

    var timeSent = timeConverter(int.parse(document[MESSAGE_TIMESTAMP]));

    return GestureDetector(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: document[MESSAGE_ID_FROM] == id ? MainAxisAlignment.end:MainAxisAlignment.start,
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
                    child: Text(document[MESSAGE_CONTENT],
                      style: TextStyle(
                          fontSize: MESSAGE_FONT_SIZE,
                          color: MESSAGE_FONT_COLOR
                      ),
                    ),
                  ),
                ),
              ],
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
              _deleteMessage(timestamp);},
          ),
          FlatButton(
            child: Text('cancel'),
            onPressed:()=> Navigator.pop(context),
          )
        ],
      );
    });
  }

  _deleteMessage(String timestamp) async{
      await _firestore
        .collection(MESSAGES_COLLECTION)
        .document(groupId)
        .collection(groupId)
        .document(timestamp)
        .delete();

  }

  _sendMessage(){
    //save time to avoid deleting issues
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    var msg = _textEditingController.value.text;
    if(msg.isNotEmpty) {
      _textEditingController.clear();
      var documentReference = Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(groupId)
          .collection(groupId)
          .document(timestamp);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
            documentReference,
            {
              MESSAGE_ID_FROM: id,
              MESSAGE_ID_TO: friendId,
              MESSAGE_TIMESTAMP: timestamp,
              MESSAGE_CONTENT: msg,
              MESSAGE_TYPE: MESSAGE_TYPE_TEXT
            }
        );
      });
    }

    _scrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeIn);

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
    friendPhotoUri = document[USER_PHOTO_URI];
    setState(() {
    });
  }
}