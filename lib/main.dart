library chat_pool;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';



part 'Login.dart';
part 'Authentication.dart';
part 'MainChat.dart';
part 'Storage.dart';
part 'Friends.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/main' : (context) => MainScreen(),
        '/main/friends' : (context) => FriendsScreen()
      },
    );
  }
}