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

    if(document[USER_ID_FIELD] == id){
      return null;
    }

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
          Text(document[USER_DISPLAY_NAME_FIELD])
        ],
      ),
      onTap: () {
        Toast.show(document[USER_DISPLAY_NAME_FIELD], context,
            gravity: Toast.BOTTOM, duration: Toast.LENGTH_SHORT);
      },
    );

  }

  _getPreferences() async{
    var prefs = await SharedPreferences.getInstance();
    id = await prefs.get(SHARED_PREFERENCES_USER_ID);
    setState(() {

    });
  }

}