part of chat_pool;

class SettingsScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('settings'),
    );
  }
}