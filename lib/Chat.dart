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
          margin: EdgeInsets.all(8.0),
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
            clipBehavior: Clip.hardEdge,
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
            Expanded(
                flex: 10,
                child:TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: TEXT_FIELD_HINT,
                  ),
                  controller: _textEditingController,
                )
            ),
            Expanded(
              child: GestureDetector(
                child: Icon(Icons.send),
                onTap: _sendMessage,
              ),
            )
          ],
        ) ,
      );
  }

  Widget _chatItemBuilder(DocumentSnapshot document){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment:document[MESSAGE_ID_FROM]==id ? MainAxisAlignment.end: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: MESSAGE_BACKGROUND_COLOR,
                  borderRadius: BorderRadius.circular(MESSAGE_RADIUS)
              ),
              width: MESSAGE_WIDTH,
              margin: EdgeInsets.all(MESSAGE_MARGIN),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(MESSAGE_PADDING),
                    margin: EdgeInsets.all(4.0),
                    child:Row(
                      mainAxisAlignment:MainAxisAlignment.start,
                      children: <Widget>[
                        Text(document[MESSAGE_CONTENT],
                            style: TextStyle(
                                fontSize:MESSAGE_FONT_SIZE,
                                color: MESSAGE_FONT_COLOR
                            )
                        ),
                      ],
                    ) ,
                  )
                 ,
                  Container(
                    margin:EdgeInsets.all(MESSAGE_DATE_MARGIN),
                    child:Row(
                      mainAxisAlignment:MainAxisAlignment.end,
                      children: <Widget>[
                        Text(timeConverter(int.parse(document[MESSAGE_TIMESTAMP])),
                          style: TextStyle(
                              fontSize:MESSAGE_DATE_FONT_SIZE,
                              color: MESSAGE_DATE_FONT_COLOR
                          ),
                        )
                      ],
                    ),
                  )


                ],
              )
            )
          ],
        ),
      ],
    );



  }

  _sendMessage(){
    var msg = _textEditingController.value.text;
    if(msg.isNotEmpty) {
      _textEditingController.clear();
      var documentReference = Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(groupId)
          .collection(groupId)
          .document(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
            documentReference,
            {
              MESSAGE_ID_FROM: id,
              MESSAGE_ID_TO: friendId,
              MESSAGE_TIMESTAMP: DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString(),
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