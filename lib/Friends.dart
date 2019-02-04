part of chat_pool;


class FriendsScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>FriendsScreenState();
}

class FriendsScreenState extends State<FriendsScreen>{

  var id;

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
            .collection(USERS_COLLECTION)
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
    print('ids: $id');

    if(document[USER_ID] == id)
      return Container();

      return ListTile(
        title: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(8.0),
              child: Material(
                child: CachedNetworkImage(
                  placeholder: Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  imageUrl: document[USER_PHOTO_URI],
                  width: 50.0,
                  height: 50.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(80.0)),
                clipBehavior: Clip.hardEdge,
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
          backgroundImage: CachedNetworkImageProvider(friendPhotoUri),
          radius: 120.0,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('add'),
            onPressed: () {
              Navigator.pop(context);
              _addFriend(friendId);
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

  _addFriend(String friendId) async{
    var time = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore
        .collection(USERS_COLLECTION)
        .document(friendId)
        .collection(FRIENDS_COLLECTION)
        .document(time)
        .setData({
      FRIEND_ID : friendId,
      FRIEND_TIME_ADDED : time
    });
  }
  _getPreferences()async{
    var prefs = await SharedPreferences.getInstance();
    id = await prefs.get(SHARED_PREFERENCES_USER_ID);
    setState(() {
    });
  }


}
