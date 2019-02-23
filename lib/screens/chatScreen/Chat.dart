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
        body: (friendPhotoUri == null || friendDisplayName == null) ? Center(child:CircularProgressIndicator()) : _chatScreenBody(),
        appBar: AppBar(
          title: (friendPhotoUri == null || friendDisplayName == null) ? null : ChatAppBar(
            photoUri: friendPhotoUri,
            displayName: friendDisplayName,
            id:friendId
            ),
          actions: _appBarActions(),
        )
    );
  }

  List<Widget> _appBarActions(){
    return null;
  }

  Widget _chatScreenBody(){
    return Column(
      children: <Widget>[
        ChatSegment(groupId:groupId,id: id),
        InputSegment(groupId: groupId,id: id,friendId: friendId,)
      ],
    );
  }

  _init(){
    _getFriendInfo();
    _setGroupChatId();
  }

  _setGroupChatId()async{
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
