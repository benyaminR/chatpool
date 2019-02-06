import 'package:flutter/material.dart';

///Strings
///LoginScreen
const String GOOGLE_LOGIN_BUTTON = 'login with Google';
///MainScreen
const String MAIN_SCREEN_APP_BAR_TITLE = 'main screen';
///Storage
const String USERS_COLLECTION = 'users';
const String USERS_ABOUT_FIELD = 'about';
const String USER_DISPLAY_NAME = 'display name';
const String USER_ID = 'id';
const String USER_PHOTO_URI = 'photo uri';
const String USER_EMAIL = 'email';
const String USER_FRIENDS = 'friends';
const String FRIENDS_COLLECTION = 'friends';
const String FRIEND_ID = 'friend id';
const String FRIEND_TIME_ADDED = 'time added';
///SharedPreferences
const String SHARED_PREFERENCES_USER_ID = "id";

///Chat
const String MESSAGES_COLLECTION = 'messages';
const String TEXT_FIELD_HINT = 'type a message';
const String MESSAGE_ID_TO = 'idTo';
const String MESSAGE_ID_FROM = 'idFrom';
const String MESSAGE_TIMESTAMP = 'timestamp';
const String MESSAGE_CONTENT = 'content';
const String MESSAGE_TYPE = 'type';
const String MESSAGE_TYPE_PHOTO = 'photo';
const String MESSAGE_TYPE_STICKER = 'sticker';
const String MESSAGE_TYPE_TEXT = 'text';


///Doubles
///Chat
const double APP_BAR_IMAGE_WIDTH = 40.0;
const double APP_BAR_IMAGE_HEIGHT = 40.0;
const double APP_BAR_IMAGE_RADIUS = 25.0;
const double MESSAGE_RADIUS = 6.0;
const double MESSAGE_PADDING = 4.0;
const double MESSAGE_MARGIN = 4.0;
const double MESSAGE_WIDTH = 170.0;
const double MESSAGE_FONT_SIZE = 16.0;
const double MESSAGE_DATE_FONT_SIZE = 9.0;
const double MESSAGE_DATE_MARGIN = 2.0;
const double INPUT_TEXT_FIELD_RADIUS = 20.0;
const double INPUT_TEXT_FIELD_PADDING = 10.0;
const double SEND_BUTTON_RADIUS = 100.0;
const double SEND_BUTTON_PADDING = 8.0;
const double SEND_BUTTON_MARGIN = 4.0;

///MainScreen
const MAINSCREEN_FRIEND_PHOTO_WIDTH = 45.0;
const MAINSCREEN_FRIEND_PHOTO_HEIGHT = 45.0;
const MAINSCREEN_FRIEND_PHOTO_RADIUS = 25.0;
const MAINSCREEN_FRIEND_PHOTO_MARGIN = 2.0;

///Friends
const FRIENDS_PHOTO_WIDTH = 40.0;
const FRIENDS_PHOTO_HEIGHT = 40.0;
const FRIENDS_PHOTO_RADIUS = 25.0;
const FRIENDS_PHOTO_MARGIN = 2.0;

///Colors
///Chat
const Color MESSAGE_FONT_COLOR = Colors.black;
const Color MESSAGE_BACKGROUND_COLOR = Colors.white;
const Color MESSAGE_DATE_FONT_COLOR = Colors.black54;
const Color INPUT_TEXT_FIELD_BACKGROUND_COLOR = Colors.white;
const Color SEND_BUTTON_BACKGROUND_COLOR = Colors.white;


/*GestureDetector(
//onLongPress: _showDeleteDialog(document[MESSAGE_TIMESTAMP]),
child: Column(
children: <Widget>[
Row(
mainAxisAlignment:document[MESSAGE_ID_FROM]==id ? MainAxisAlignment.end: MainAxisAlignment.start,
children: <Widget>[
Container(
decoration: BoxDecoration(
color: MESSAGE_BACKGROUND_COLOR,
borderRadius: BorderRadius.circular(MESSAGE_RADIUS)
),
//width: MESSAGE_WIDTH,
margin: EdgeInsets.all(MESSAGE_MARGIN),
child: Column(
children: <Widget>[
Container(
padding: EdgeInsets.all(MESSAGE_PADDING),
margin: EdgeInsets.all(4.0),
child:Row(
mainAxisAlignment:MainAxisAlignment.start,
children: <Widget>[
Text(document[MESSAGE_CONTENT],
style: TextStyle(
fontSize:MESSAGE_FONT_SIZE,
color: MESSAGE_FONT_COLOR
)
),
],
) ,
)
,
Container(
margin:EdgeInsets.all(MESSAGE_DATE_MARGIN),
child:Row(
mainAxisAlignment:MainAxisAlignment.end,
children: <Widget>[
Text(timeConverter(int.parse(document[MESSAGE_TIMESTAMP])),
style: TextStyle(
fontSize:MESSAGE_DATE_FONT_SIZE,
color: MESSAGE_DATE_FONT_COLOR
),
)
],
),
)
],
)
)
],
)
],
),
);*/
