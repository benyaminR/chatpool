library chat_pool;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatpool/Consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatpool/utils/Utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

part 'package:chatpool/screens/Login.dart';
part 'package:chatpool/utils/Authentication.dart';
part 'package:chatpool/screens/MainScreen.dart';
part 'package:chatpool/screens/Friends.dart';
part 'package:chatpool/screens/Chat.dart';
part 'package:chatpool/utils/Communication.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/main' : (context) => MainScreen(),
        '/main/friends' : (context) => FriendsScreen(),
        '/main/chat' : (context) => ChatScreen()
      },
    );
  }
}