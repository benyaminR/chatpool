part of chat_pool;
class ChatSegment extends StatefulWidget{

  final String id;
  final String groupId;
  ChatSegment({@required this.groupId,@required this.id});

  @override
  State<StatefulWidget> createState()=>ChatSegmentState(groupId,id);
}
class ChatSegmentState extends State<ChatSegment>{
  final String id;
  final String groupId;
  ChatSegmentState(this.groupId,this.id);
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child:Container(
          height: MediaQuery.of(context).size.height/1.1,
          child: StreamBuilder(
            stream: _firestore
                .collection(MESSAGES_COLLECTION)             //Messages
                .document(groupId)                           //this groupId
                .collection(groupId)                         //their collection of messages
                .orderBy(MESSAGE_TIMESTAMP,descending: true) // order messages by time
                .snapshots(),
            builder: (BuildContext buildContext,AsyncSnapshot<QuerySnapshot>snapshots){
              //show error if there is any
              if(snapshots.hasError)
                return Text(snapshots.error);
              //if connecting show progressIndicator
              if(snapshots.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              //show users
              else
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshots.data.documents.length,
                  itemBuilder:(context,index){
                    return _buildMessage(snapshots.data.documents[index],id,groupId);
                  },
                );
            },
          )
      ),
    );
  }

  Widget _buildMessage(DocumentSnapshot snapshot,String id,String groupId){
    return GestureDetector(
        child: Row(
          mainAxisAlignment: snapshot[MESSAGE_ID_FROM] == id ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                 width: MESSAGE_WIDTH,
                  height: snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_PHOTO ? MESSAGE_WIDTH:null,
                  padding: EdgeInsets.all(MESSAGE_PADDING),
                  margin: EdgeInsets.all(MESSAGE_MARGIN),
                  decoration: BoxDecoration(
                      color: MESSAGE_BACKGROUND_COLOR,
                      borderRadius: BorderRadius.circular(MESSAGE_RADIUS)
                  ),
                  child:Column(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: snapshot[MESSAGE_TYPE]== MESSAGE_TYPE_PHOTO ?
                              AspectRatio(
                                aspectRatio: 1.1,
                                child: Hero(
                                  tag:snapshot[MESSAGE_TIMESTAMP],
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          alignment: FractionalOffset.center,
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                            snapshot[MESSAGE_CONTENT],),)
                                    ),
                                  ),
                                ),
                              )

                              : snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_TEXT ?
                              AutoSizeText(
                                snapshot[MESSAGE_CONTENT],
                                style: TextStyle(
                                    fontSize: MESSAGE_FONT_SIZE,
                                    color: MESSAGE_FONT_COLOR
                                ),
                          )
                              :
                          Text('sticker')
                      ),
                      Container(
                        margin: EdgeInsets.all(4.0),
                        child: Align(
                          alignment:Alignment.centerRight ,
                          child: Text(timeConverter(int.parse(snapshot[MESSAGE_TIMESTAMP])),
                            style: TextStyle(
                                fontSize: MESSAGE_DATE_FONT_SIZE,
                                color: MESSAGE_FONT_COLOR
                            ),),
                        ),
                      )
                    ],
                  )
              ),
            ),
          ],
        ),
        onLongPress:()=>_showDeleteMessageDialog(snapshot),
        onTap:()=>snapshot[MESSAGE_TYPE] == MESSAGE_TYPE_PHOTO ? _showImage(snapshot[MESSAGE_CONTENT],snapshot[MESSAGE_TIMESTAMP]):null,
    );
  }
  _showDeleteMessageDialog(DocumentSnapshot snapshot){
    if(snapshot[MESSAGE_ID_FROM]== id ){
      showDialog(context: context,builder: (context){
        return DeleteMessageDialog(groupId: groupId,timestamp: snapshot[MESSAGE_TIMESTAMP]);
      });
    }
  }

  _showImage(String imageUrl,String tag){
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowImage(imageUrl: imageUrl,tag: tag,)));
}
}