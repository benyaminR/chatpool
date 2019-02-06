part of chat_pool;


class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>{

  String id;

  @override
  void initState() {
    super.initState();

    //get id
    SharedPreferences.getInstance().then((sp){
      setState(() {
        id = sp.get(SHARED_PREFERENCES_USER_ID);
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child:Icon(Icons.perm_contact_calendar),
          onPressed:(){
            _showFriends();
          }),
      appBar: AppBar(
        title: Text(MAIN_SCREEN_APP_BAR_TITLE),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              _signOutWithGoogle();
            },
          )
        ],
      ),
      body: _mainScreenBody(),
    );
  }

  Widget _mainScreenBody(){
    print('id : $id(mainscreen)');
    return StreamBuilder(
      stream: _firestore
          .collection(USERS_COLLECTION)
          .document(id)
          .collection(FRIENDS_COLLECTION)
          .snapshots(),
      builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError)
          return Center(child: Text(snapshot.error),);
        if(snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(),);
        if(snapshot.data.documents.isEmpty)
          return Center(child: Text('add a friend'),);
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,index) => _friendTileBuilder(snapshot.data.documents[index]));
      },
    );
  }

  Widget _friendTileBuilder(DocumentSnapshot document) {

    return StreamBuilder(
      stream: Stream.fromFuture(getFriendById(document[FRIEND_ID])),
      builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot){
        if(snapshot.hasError)
          return Center(child:Text(snapshot.error));
        if(snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(),);
        return ListTile(
          title: Text(snapshot.data.data[USER_DISPLAY_NAME]),
          leading: Container(
            margin: EdgeInsets.all(8.0),
            child: Material(
              child: CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
                imageUrl: snapshot.data.data[USER_PHOTO_URI],
                width: 50.0,
                height: 50.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(80.0)),
              clipBehavior: Clip.hardEdge,
            ),
          ),
        );
      },
    );

  }

  void _signOutWithGoogle() async{
    await signOutWithGoogle();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _showFriends(){
    Navigator.of(context).pushNamed('/main/friends');
  }
}
