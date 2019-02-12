part of chat_pool;

class MeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeScreenState();
}

class MeScreenState extends State<MeScreen> {
  String _id;
  String _name;
  String _about;
  String _imageUri;

  //picked image or taken
  var _file;

  @override
  void initState() {
    super.initState();
    _initLocale();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      resizeToAvoidBottomInset: false,
        body: _meScreenBody(),
        appBar: _meScreenAppBar(),
      ),
    );
  }

  Widget _meScreenBody() {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: CircleAvatar(
                radius: 100.0,
                backgroundImage: CachedNetworkImageProvider(_imageUri),
                child: Align(
                  alignment: Alignment(1.0, 1.0),
                  child: FloatingActionButton(
                    child: Icon(Icons.camera_alt),
                    onPressed: () => _showCameraDialog(),
                  ),
                )),
          ),
        ),
        Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _name,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                Flexible(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editDisplayName())),
                )
              ],
            )),
        Container(
            margin: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _about != null
                          ? _about
                          : 'write something about your self',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                Flexible(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editAbout())),
                )
              ],
            ))
      ],
    );
  }

  Widget _meScreenAppBar() {
    return AppBar(
      title: Text('me'),
      actions: _meScreenAppBarActions(),
    );
  }

  List<Widget> _meScreenAppBarActions() {
    return null;
  }

  _showCameraDialog() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('Camera'),
                leading: Icon(Icons.camera_alt),
                onTap: () => _selectPhoto(ImageSource.camera),
              ),
              ListTile(
                title: Text('Gallery'),
                leading: Icon(Icons.photo),
                onTap: () => _selectPhoto(ImageSource.gallery),
              ),
              ListTile(
                title: Text('Delete'),
                leading: Icon(Icons.delete),
                onTap: () => _deletePhoto(),
              ),
            ],
          );
        });
  }

  _initLocale() {
    SharedPreferences.getInstance().then((sp) {
      setState(() {
        _id = sp.getString(SHARED_PREFERENCES_USER_ID);
        _name = sp.getString(SHARED_PREFERENCES_USER_DISPLAY_NAME);
        _imageUri = sp.getString(SHARED_PREFERENCES_USER_PHOTO);
        _about = sp.getString(SHARED_PREFERENCES_USER_ABOUT);
      });
    });
  }

  _selectPhoto(ImageSource source) {
    ImagePicker.pickImage(source: source).then((file) {
      _file = file;
      _uploadPhoto();
    });
  }

  _deletePhoto() {
    FirebaseStorage.instance
        .ref()
        .child('/profile_images/$_id')
        .delete()
        .then((val) {
      _firestore
          .collection(USERS_COLLECTION)
          .document(_id)
          .updateData({USER_PHOTO_URI: USER_IMAGE_PLACE_HOLDER}).then((val) {
        _updateSharedPreferences(USER_IMAGE_PLACE_HOLDER);
      });
    });
  }

  _uploadPhoto() {
    var ref = FirebaseStorage.instance.ref().child('/profile_images/$_id');
    var task = ref.putFile(_file);

    task.events.listen((event) {
      switch (event.type) {
        case StorageTaskEventType.failure:
          _onError();
          break;
        case StorageTaskEventType.progress:
          break;
        case StorageTaskEventType.pause:
          break;
        case StorageTaskEventType.resume:
          break;
        case StorageTaskEventType.success:
          _onDone();
          break;
      }
    });
  }

  _onError() {
    Toast.show('can not upload your photo', context);
  }

  _onDone() {
    Toast.show('your photo has been uploaded successfully', context);
    FirebaseStorage.instance
        .ref()
        .child('/profile_images/$_id')
        .getDownloadURL()
        .then((url) {
      _firestore
          .collection(USERS_COLLECTION)
          .document(_id)
          .updateData({USER_PHOTO_URI: url.toString()}).then((val) {
        _updateSharedPreferences(url.toString());
      });
    });
  }

  _updateSharedPreferences(String url) {
    SharedPreferences.getInstance().then((sp) {
      sp.setString(SHARED_PREFERENCES_USER_PHOTO, url);
      _initLocale();
    });
  }

  _editAbout() {
    var text = _about != null ? _about : '';
    final textEditingController = TextEditingController(text: text);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('write something about yourself'),
            content: TextField(
                maxLines: 4,
                maxLength: 100,
                controller: textEditingController,
              ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    if(_about != textEditingController.value.text) {
                      _uploadAbout(textEditingController.value.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('change')),
              FlatButton(
                onPressed: ()=>Navigator.pop(context),
                child: Text('cancel'),
              )
            ],
          );
        });
  }

  _uploadAbout(String text) {
    _firestore
        .collection(USERS_COLLECTION)
        .document(_id)
        .updateData({USER_ABOUT_FIELD: text}).then((_) {
      SharedPreferences.getInstance().then((sp) {
        sp.setString(SHARED_PREFERENCES_USER_ABOUT, text);
        _initLocale();
        setState(() {});
      });
    });
  }

  _editDisplayName() {
    var text = _name != null ? _name : '';
    final textEditingController = TextEditingController(text: text);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('change your name'),
            content: TextField(
                  maxLines: 1,
                  maxLength: 10,
                  controller: textEditingController,
                ),

            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    if(_name != textEditingController.value.text) {
                      _uploadName(textEditingController.value.text);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('change')),
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'),
              )
            ],
          );
        });
  }

  _uploadName(String text) {
    _firestore
        .collection(USERS_COLLECTION)
        .document(_id)
        .updateData({USER_DISPLAY_NAME: text}).then((_) {
      SharedPreferences.getInstance().then((sp) {
        sp.setString(SHARED_PREFERENCES_USER_DISPLAY_NAME, text);
        _initLocale();
        setState(() {});
      });
    });
  }
}
