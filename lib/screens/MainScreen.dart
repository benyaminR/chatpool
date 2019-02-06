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
            margin: EdgeInsets.all(MAINSCREEN_FRIEND_PHOTO_MARGIN),
            child: Material(
              child: CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
                imageUrl: snapshot.data.data[USER_PHOTO_URI],
                width: MAINSCREEN_FRIEND_PHOTO_WIDTH,
                height: MAINSCREEN_FRIEND_PHOTO_HEIGHT,
              ),
              borderRadius: BorderRadius.all(Radius.circular(MAINSCREEN_FRIEND_PHOTO_RADIUS)),
              clipBehavior: Clip.antiAlias,
            ),
          ),
          //navigate to chatScreen
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context)=>ChatScreen(friendId:snapshot.data.data[USER_ID])
              )
          ),
          onLongPress: ()=>_longPressAlertDialog(snapshot.data.data[USER_DISPLAY_NAME],snapshot.data.data[USER_ID]),
        );
      },
    );
  }

  _longPressAlertDialog(String displayName,String userId){
    showDialog(context: context,builder: (context){
      return AlertDialog(
        title:Align(
          alignment:Alignment.centerLeft,
            child:Icon(Icons.delete)
        ),
        content:Text('Do you want to delete $displayName?'),
        actions: <Widget>[
          FlatButton(
            child: Text('delete'),
            onPressed: (){
              Navigator.pop(context);
              _deleteUser(userId);
            },
          ),
          FlatButton(
            child: Text('cancel'),
            onPressed: ()=> Navigator.pop(context),
          )
        ],
      );
    });
  }

  _deleteUser(String userId){
    _firestore
    .collection(USERS_COLLECTION)      //users
        .document(id)                  //me
        .collection(FRIENDS_COLLECTION)//my friends
        .document(userId)              //this friend
        .delete()                      //delete
        .then((_)=>setState((){}));    //reload ui
  }

  void _signOutWithGoogle() async{
    await signOutWithGoogle();
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _showFriends(){
    Navigator.of(context).pushNamed('/main/friends');
  }
}
