part of chat_pool;

class InputSegment extends StatefulWidget{
  final String id;
  final String groupId;
  final String friendId;
  InputSegment({@required this.id,@required this.groupId,@required this.friendId});
  @override
  State<StatefulWidget> createState() => InputSegmentState(id,groupId,friendId);
}
class InputSegmentState extends State<InputSegment>{

  final String id;
  final String groupId;
  final String friendId;
  InputSegmentState(this.id,this.groupId,this.friendId);

  final TextEditingController _textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: INPUT_TEXT_FIELD_BACKGROUND_COLOR,
                    borderRadius: BorderRadius.circular(INPUT_TEXT_FIELD_RADIUS)
                ),
                child: TextField(
                  autocorrect: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(INPUT_TEXT_FIELD_PADDING),
                      border: InputBorder.none,
                      hintText: TEXT_FIELD_HINT,
                      hintStyle: TextStyle(
                          color: INPUT_TEXT_FIELD_HINT_COLOR
                      )
                  ),
                  controller: _textEditingController,
                )
              )
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(SEND_BUTTON_PADDING),
              margin: EdgeInsets.all(SEND_BUTTON_MARGIN),
              decoration: BoxDecoration(
                color: PICK_BUTTON_BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(SEND_BUTTON_RADIUS),
              ),
              child:Icon(Icons.image,color: PICK_BUTTON_ICON_COLOR,),
            ),
            onTap: ()=>_pickImage(),
          ),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(SEND_BUTTON_PADDING),
              margin: EdgeInsets.all(SEND_BUTTON_MARGIN),
              decoration: BoxDecoration(
                color: SEND_BUTTON_BACKGROUND_COLOR,
                borderRadius: BorderRadius.circular(SEND_BUTTON_RADIUS),
              ),
              child: Icon(Icons.send,color: SEND_BUTTON_ICON_COLOR,),
            ),
            onTap:(){
              if(_textEditingController.value.text.isNotEmpty){
                _sendMessage();
              }
            },
          ),
        ],
      ) ,
    );
  }
  _sendMessage(){
    sendMessage(_textEditingController.value.text, groupId, id, friendId);
    _textEditingController.clear();
  }


  _pickImage(){
    ImagePicker.pickImage(source: ImageSource.gallery).then((imageFile) {
      Navigator.push(
          context, PageRouteBuilder(pageBuilder: (context, anim1, anim2) =>
          SendMedia(
            imageFile: imageFile, groupId: groupId, id: id, friendId: friendId,)
      )).then((v){
        if(v[0])
          _sendImage(imageFile);
      });

    });
  }

  _sendImage(File imageFile){
    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    _compressImage(imageFile).then((compressedImage){
      //upload image file
      FirebaseStorage
          .instance
          .ref()
          .child('/media/images/$groupId/$id+$timeStamp').putFile(compressedImage)
          .events.listen((events){
        if(events.type == StorageTaskEventType.success){
          _saveImageUri(timeStamp);
        }
      });
    });

  }
  Future<File> _compressImage(File rawImage) async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = Math.Random().nextInt(10000);
    Im.Image image = Im.decodeImage(rawImage.readAsBytesSync());
    Im.Image smallerImage = Im.copyResize(image, 640);

    return File('$path/$rand.jpg')..writeAsBytesSync(Im.encodeJpg(smallerImage,quality: 70));
  }

  _saveImageUri(String timeStamp){
    FirebaseStorage
        .instance
        .ref()
        .child('/media/images/$groupId/$id+$timeStamp')
        .getDownloadURL().then((uri){
      //save in cloud
      var fireStoreRef = _firestore
          .collection(MESSAGES_COLLECTION)
          .document(groupId)
          .collection(groupId)
          .document(timeStamp);
      _firestore.runTransaction((transaction)async{
        await transaction.set(
            fireStoreRef,
            {
              MESSAGE_CONTENT: uri,
              MESSAGE_TYPE : MESSAGE_TYPE_PHOTO,
              MESSAGE_TIMESTAMP : timeStamp,
              MESSAGE_ID_FROM : id,
              MESSAGE_ID_TO : friendId
            });
      });
    });
  }

}