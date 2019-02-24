part of chat_pool;


Future<DocumentSnapshot> getFriendById(String id) async{
  var documents = await _firestore
      .collection(USERS_COLLECTION)
      .where(USER_ID,isEqualTo: id)
      .limit(1)
      .getDocuments();
  return documents.documents[0];
}

sendMessage(String msg,String groupId,String id,String friendId){
  //save time to avoid deleting issues
  var timestamp = DateTime
      .now()
      .millisecondsSinceEpoch
      .toString();

  var documentReference = Firestore.instance
      .collection(MESSAGES_COLLECTION)
      .document(groupId)
      .collection(groupId)
      .document(timestamp);

  Firestore.instance.runTransaction((transaction) async {
    await transaction.set(
        documentReference,
        {
          MESSAGE_ID_FROM: id,
          MESSAGE_ID_TO: friendId,
          MESSAGE_TIMESTAMP: timestamp,
          MESSAGE_CONTENT: msg,
          MESSAGE_TYPE: MESSAGE_TYPE_TEXT
        }
    );
  });
}

_deleteMessage(String timestamp,String groupId) async{
  // path : /media/images/$groupId/$idFrom+timestamp
  var imageName = '${groupId.split('-')[0]}+$timestamp';

  //delete image reference
  await _firestore
      .collection(MESSAGES_COLLECTION)
      .document(groupId)
      .collection(groupId)
      .document(timestamp)
      .delete();

  // delete image file
  await FirebaseStorage
      .instance
      .ref()
      .child('/media/images/$groupId/$imageName')
      .delete();
  
}

addFriend(String friendId,String id) async{
  var time = DateTime.now().millisecondsSinceEpoch.toString();

  bool isNewFriend = false;

  await _firestore
      .collection(USERS_COLLECTION)
      .document(id)
      .collection(FRIENDS_COLLECTION)
      .where(FRIEND_ID,isEqualTo: friendId)
      .getDocuments().then((value){
    if(value.documents.isEmpty){
      isNewFriend = true;
    }
  });

  if(isNewFriend) {
    await _firestore
        .collection(USERS_COLLECTION)
        .document(id)
        .collection(FRIENDS_COLLECTION)
        .document(friendId)
        .setData({
      FRIEND_ID: friendId,
      FRIEND_TIME_ADDED: time
    });
  }
}

final Firestore _firestore = Firestore.instance;
///creates a new users in the cloud with its firebase' userInfo
Future<Null> createUserProfile(FirebaseUser firebase) async{

  var id = firebase.uid;

  //get user's document
  final QuerySnapshot result = await Firestore
      .instance
      .collection(USERS_COLLECTION)
      .where(USER_ID, isEqualTo: firebase.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;

  //create a new user if the user doesn't exists
  if(documents.length == 0) {
    await _firestore
        .collection(USERS_COLLECTION) //users
        .document(firebase.uid)
        .setData({
      USER_DISPLAY_NAME: firebase.displayName,        //name
      USER_ABOUT_FIELD: null,                         //about
      USER_ID: firebase.uid,                          //id
      USER_PHOTO_URI: USER_IMAGE_PLACE_HOLDER,        //userProfile
      USER_EMAIL: firebase.email,
      USER_TOKEN : await FirebaseMessaging().getToken(),
    });
  }

  //permission for ios
  FirebaseMessaging().requestNotificationPermissions();

  //update user status
  var userFirestoreRef = _firestore.collection(USERS_COLLECTION).document(id);

  var firebaseDatabaseRef = FirebaseDatabase.instance.reference().child('.info/connected');
  var userFirebaseDatabaseRef =FirebaseDatabase.instance.reference().child('/status/$id');
  var isOfflineForFirestore = {
    'state': 'offline',
    'last_changed': DateTime.now().toIso8601String(),
  };

  var isOnlineForFirestore = {
    'state': 'online',
    'last_changed': DateTime.now().toIso8601String(),
  };

  firebaseDatabaseRef.onValue.listen((data){
    print('data : ${data.snapshot.value}');
    if(data.snapshot.value  == false){
      userFirestoreRef.updateData({USER_STATUS:STATUS_OFFLINE});
      return;
    }
    userFirebaseDatabaseRef.onDisconnect().set(isOfflineForFirestore).then((v) {
      userFirebaseDatabaseRef.set(isOnlineForFirestore);
      userFirestoreRef.updateData({USER_STATUS: STATUS_ONLINE});
    });

  });

  //update or add with every login
  //add user id and profile image
  await SharedPreferences.getInstance().then((sp){
    var id = firebase.uid.toString();
    var photoUri = documents[0][USER_PHOTO_URI];
    var name = documents[0][USER_DISPLAY_NAME];
    var about = documents[0][USER_ABOUT_FIELD];

    sp.setString(SHARED_PREFERENCES_USER_ID, id);
    sp.setString(SHARED_PREFERENCES_USER_PHOTO, photoUri != null ? photoUri : USER_IMAGE_PLACE_HOLDER);
    sp.setString(SHARED_PREFERENCES_USER_DISPLAY_NAME, name);
    sp.setString(SHARED_PREFERENCES_USER_ABOUT, about);
  });

}
Future deleteUser(String userId,String id) async{
 await _firestore
      .collection(USERS_COLLECTION)     //users
      .document(id)                     //me
      .collection(FRIENDS_COLLECTION)   //my friends
      .document(userId)                 //this friend
      .delete();                        //delete
}


