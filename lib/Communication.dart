part of chat_pool;


Future<DocumentSnapshot> getFriendById(String id) async{
  var documents = await _firestore
      .collection(USERS_COLLECTION)
      .where(USER_ID,isEqualTo: id)
      .limit(1)
      .getDocuments();
  return documents.documents[0];
}