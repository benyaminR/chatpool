part of chat_pool;

class MeScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MeScreenState();
}

class MeScreenState extends State<MeScreen>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('me'),
    );
  }
}