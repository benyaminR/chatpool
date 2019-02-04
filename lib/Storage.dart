part of chat_pool;

final Firestore _firestore = Firestore.instance;

///creates a new users in the cloud with its firebase' userInfo
Future<Null> createUserProfile(FirebaseUser firebase) async{

  //add user id
  SharedPreferences.getInstance().then((sp){
    sp.setString(SHARED_PREFERENCES_USER_ID, firebase.uid.toString());
  });


  //get user's document
  final QuerySnapshot result = await Firestore
      .instance
      .collection(USERS_COLLECTION)
      .where(USER_ID, isEqualTo: firebase.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  //create a new user if the user doesn't exists
  if(documents.length == 0) {
    _firestore
        .collection(USERS_COLLECTION) //users
        .document(firebase.uid)
        .setData({
      USER_DISPLAY_NAME: firebase.displayName, //name
      USERS_ABOUT_FIELD: 'helloWorld',                //about
      USER_ID: firebase.uid,                     //id
      USER_PHOTO_URI: firebase.photoUrl,
      USER_EMAIL: firebase.email
    });
  }
}