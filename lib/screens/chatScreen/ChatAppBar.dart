part of chat_pool;
///appBar
class ChatAppBar extends StatefulWidget{
  final String photoUri;
  final String displayName;
  final String id;
  final String about;
  ChatAppBar({this.photoUri, this.displayName,this.id,this.about});
  @override
  State<StatefulWidget> createState()=>ChatAppBarState(photoUri: photoUri,displayName: displayName,id: id,about:about);
}
class ChatAppBarState extends State<ChatAppBar>{

  final String photoUri;
  final String displayName;
  final String id;
  final String about;
  String userStatus = '';

  StreamSubscription<Event> stateListener;

  ChatAppBarState({this.photoUri,this.displayName,this.id,this.about});
  @override
  void initState() {
    super.initState();
    stateListener = FirebaseDatabase.instance.reference().child('/status/$id').onValue.listen((event){
      setState(() {
        userStatus = event.snapshot.value['state'];
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: <Widget>[
          //user image
          Container(
            child: Material(
              child: CachedNetworkImage(
                placeholder: Container(
                  child: CircularProgressIndicator(),
                ),
                imageUrl: photoUri,
                width: APP_BAR_IMAGE_WIDTH,
                height: APP_BAR_IMAGE_HEIGHT,
              ),
              borderRadius: BorderRadius.all(Radius.circular(APP_BAR_IMAGE_RADIUS)),
              clipBehavior: Clip.antiAlias,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 8.0),
                  child:Text(displayName),
                ),
                Text(userStatus,style: TextStyle(fontSize: 10.0))
              ],
            ),
          )
        ],
      ),
      onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>
          UserProfile(imageUrl: photoUri,id: id,username: displayName,about: about,))
      )

    );
  }
  @override
  void dispose() {
    stateListener.cancel();
    super.dispose();
  }
}

