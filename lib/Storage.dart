part of chat_pool;

final Firestore _firestore = Firestore.instance;

///creates a new users in the cloud with its firebase' userInfo
Future<Null> createUserProfile(FirebaseUser firebase) async{

  //get user's document
  final QuerySnapshot result = await Firestore
      .instance
      .collection(USERS_COLLECTION)
      .where(USER_ID_FIELD, isEqualTo: firebase.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  //create a new user if the user doesn't exists
  if(documents.length == 0) {
    _firestore
        .collection(USERS_COLLECTION) //users
        .document(firebase.uid)
        .setData({
      USER_DISPLAY_NAME_FIELD: firebase.displayName, //name
      USERS_ABOUT_FIELD: 'helloWorld',                //about
      USER_ID_FIELD: firebase.uid,                    //id
      USER_PHOTO_URI: firebase.photoUrl               //photo
    });
  }
}