part of chat_pool;
class UserProfile extends StatefulWidget{
  final String imageUrl;
  final String username;
  final String about;
  final String id;
  UserProfile({this.imageUrl,this.username,this.about,this.id});

  @override
  State<StatefulWidget> createState()=> UserProfileState(imageUrl,username,about,id);
}

class UserProfileState extends State<UserProfile>{
  var height;
  var width;
  var myId;


  final String imageUrl;
  final String username;
  final String about;
  final String userId;

  UserProfileState(this.imageUrl,this.username,this.about,this.userId);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((sp){
      myId = sp.getString(SHARED_PREFERENCES_USER_ID);
    });
  }

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('profile')
      ),
      body: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 8.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4.0,
              child: CachedNetworkImage(
                  width: width,
                  height: height * 0.45,
                  fit: BoxFit.cover,
                    imageUrl: imageUrl,
                    placeholder: CircularProgressIndicator(),
                ),

            ),
            Card(
                elevation: 4.0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  width: width,
                  child: Text(username,
                    style: TextStyle(
                        fontSize: 22.0
                    ),
                  ),
                )
            ),
            Card(
                elevation: 4.0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  width: width,
                  child: Text(about,
                    style: TextStyle(
                        fontSize: 18.0
                    ),
                  ),
                )
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
          child: Icon(Icons.delete,),
          onPressed:() => _deleteFriend()),
    );
  }

  _deleteFriend(){
    //deleteUser
    deleteUser(userId, myId).then((v){
      //redirect to MainScreen
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    });


  }
}