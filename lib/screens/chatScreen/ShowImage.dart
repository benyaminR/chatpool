part of chat_pool;

class ShowImage extends StatefulWidget{
  final String imageUrl;
  final String tag;
  ShowImage({@required this.imageUrl, @required this.tag});
  @override
  State<StatefulWidget> createState() =>ShowImageState(imageUrl,tag);

}
class ShowImageState extends State<ShowImage>{
  final String imageUrl;
  final String tag;
  ShowImageState(this.imageUrl,this.tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('media'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
            tag: tag,
            child: CachedNetworkImage(
                imageUrl: imageUrl)
        ),
      ),
    );
  }

}