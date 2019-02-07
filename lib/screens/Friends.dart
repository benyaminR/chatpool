part of chat_pool;

class FriendsScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen>{

  //currentUser
  String id;

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('friends'),
      ),
      body: _friendsScreenBody(),
    );
  }

  Widget _friendsScreenBody(){
      return StreamBuilder(
        stream: _firestore
            .collection(USERS_COLLECTION) //users
            .snapshots(),
        builder: (BuildContext buildContext,AsyncSnapshot<QuerySnapshot> snapshots){
          if(!snapshots.hasData)
            return Text('no data');
          if(snapshots.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          else {
            return ListView.builder(
              itemCount: snapshots.data.documents.length,
              itemBuilder:(context,index) => _friendTileBuilder(snapshots.data.documents[index]),
            );
          }
        },
      );
  }

  Widget _friendTileBuilder(DocumentSnapshot document) {

    if(document[USER_ID] == id)
      return Container();

      return ListTile(
        title: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(FRIENDS_PHOTO_MARGIN),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  imageUrl: document[USER_PHOTO_URI] != null ? document[USER_PHOTO_URI] : USER_IMAGE_PLACE_HOLDER,
                  width: FRIENDS_PHOTO_WIDTH,
                  height: FRIENDS_PHOTO_HEIGHT,
                ),
                borderRadius: BorderRadius.all(Radius.circular(FRIENDS_PHOTO_RADIUS)),
                clipBehavior: Clip.antiAlias,
              ),
            ),
            Text(document[USER_DISPLAY_NAME])
          ],
        ),
        onTap: () {
          _showAddFriendDialog(document[USER_ID],document[USER_DISPLAY_NAME],document[USER_PHOTO_URI]);
        },
      );
  }

  _showAddFriendDialog(String friendId,String friendDisplayName,String friendPhotoUri){
    showDialog(
        context: context,
        builder: (context){
      return AlertDialog(
        title: Text(friendDisplayName),
        content: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(friendPhotoUri != null ? friendPhotoUri : USER_IMAGE_PLACE_HOLDER),
          radius: ADD_FRIEND_DIALOG_PHOTO_RADIUS,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('add'),
            onPressed: () {
              Navigator.pop(context);
              Toast.show('you have added $friendDisplayName', context,duration: Toast.LENGTH_SHORT);
              addFriend(friendId,id);
            },
          ),
          FlatButton(
            child: Text('cancel'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      );
    });
  }

  _getPreferences()async{
    var prefs = await SharedPreferences.getInstance();
    id = await prefs.get(SHARED_PREFERENCES_USER_ID);
    setState(() {
    });
  }


}
