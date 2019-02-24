part of chat_pool;

class SendMedia extends StatefulWidget{
  final String groupId;
  final String id;
  final String friendId;
  final File imageFile;
  SendMedia({this.imageFile,this.groupId,this.id,this.friendId});
  @override
  State<StatefulWidget> createState() => SendMediaState(imageFile,groupId,id,friendId);
}

class SendMediaState extends State<SendMedia>{
  final String groupId;
  final String id;
  final String friendId;
  final File imageFile;
  SendMediaState(this.imageFile,this.groupId,this.id,this.friendId);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar :_appBar(),
      body: Center(
        child:Image.file(imageFile),
      ),
      floatingActionButton:FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () => Navigator.pop(context,[true])
      ),
    );
  }

  Widget _appBar(){
    return AppBar(
      title: Text('Send media'),
    );
  }


}