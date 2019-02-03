part of chat_pool;


class LoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>{

  @override
  void initState() {
    super.initState();

    _firebaseAuth
        .onAuthStateChanged
        .firstWhere((firebaseUser)=> firebaseUser != null) // check if user is signed in
        .then((firebaseUser) => _redirectToMainScreen(firebaseUser));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login screen'),
        ),
        body: _loginScreenBody(),
      );
  }

  ///main body of login screen
  Widget _loginScreenBody(){
    return Center(
     child: FlatButton(
         onPressed: (){
           print('clicked');

           _signInWithGoogle();

         },
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