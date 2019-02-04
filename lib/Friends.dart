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
                borderRadius: BorderRadius.all(Radius.circular(100.0)),
                clipBehavior: Clip.hardEdge,
              ),
            ),
            Text(document[USER_DISPLAY_NAME])
          ],
        ),
        onTap: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) =>
                  ChatScreen(friendId: document[USER_ID])));
        },
      );
  }
  _getPreferences()async{
    var prefs = await SharedPreferences.getInstance();
    id = await prefs.get(SHARED_PREFERENCES_USER_ID);
    setState(() {

    });
  }


}
