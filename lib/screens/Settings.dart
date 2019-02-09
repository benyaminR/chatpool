part of chat_pool;

class SettingsScreen extends StatefulWidget{


  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _settingsBody(),
        appBar: _settingsAppBar(),
      ),
      title: 'settings',
    );
  }


  Widget _settingsBody(){
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text('Profile'),
          leading: Icon(Icons.account_circle),
          onTap:()=> Navigator.pushNamed(context,'/main/settings/me'),
        )
      ],
    );
  }

  Widget _settingsAppBar(){
    return AppBar(
      title: Text('Settings'),
    );
  }

}