part of chat_pool;


class LoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{

  bool loading = true;

  @override
  void initState() {
    super.initState();

    _firebaseAuth
        .onAuthStateChanged
        .first.then((firebaseUser){
      if(firebaseUser != null){
        _redirectToMainScreen(firebaseUser);
      }else{
        setState(() {
          loading = false;
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login screen'),
        ),
        body: loading ? _loadingBody() : _loginScreenBody(),
      );
  }

  Widget _loadingBody(){
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  ///main body of login screen
  Widget _loginScreenBody(){
    return Center(
     child: FlatButton(
         onPressed: ()=> _signInWithGoogle(),
         child: Text(GOOGLE_LOGIN_BUTTON),
         )
    );
  }

  void _signInWithGoogle() async{
    FirebaseUser firebaseUser = await signInWithGoogle();
    _redirectToMainScreen(firebaseUser);
  }

  ///redirect user to main screen
  void _redirectToMainScreen(FirebaseUser firebaseUser) async{
    await createUserProfile(firebaseUser).then((value){
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

}