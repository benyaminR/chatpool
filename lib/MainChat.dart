part of chat_pool;


class MainScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MAIN_SCREEN_APP_BAR_TITLE),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              _signOutWithGoogle();
            },
          )
        ],
      ),
      body: _mainScreenBody(),
    );
  }

  Widget _mainScreenBody(){
    return Center(
        child: Text('main screen'),
      );
  }

  void _signOutWithGoogle() async{
    await signOutWithGoogle();
    Navigator.of(context).pushReplacementNamed('/');
  }
}
