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
  var _imageFile;

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
                child: _imageFile == null ? TextField(
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
                    : Container(
                  height: MediaQuery.of(context).size.height/2,
                  width: MediaQuery.of(context).size.width/2,
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image(
                    image: FileImage(_imageFile),
                  ),
                ),
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
              if(_imageFile!=null){
                _sendImage();
              }else if(_textEditingController.value.text.isNotEmpty){
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
  _sendImage(){
    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    _compressImage(_imageFile).then((compressedImage){
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
    print('firestore timestamp :$timeStamp');
    print('saved dest :/media/images/$groupId/$id+$timeStamp');
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
      //clear inputSegment
      _imageFile = null;
      setState(() {

      });
    });
  }

  _pickImage(){
    ImagePicker.pickImage(source: ImageSource.gallery).then((imageFile){
      _imageFile = imageFile;
      setState(() {});
    });
  }

}