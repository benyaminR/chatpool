part of chat_pool;

class DeleteMessageDialog extends StatefulWidget{
  final String groupId;
  final String timestamp;
  DeleteMessageDialog({@required this.groupId,@required this.timestamp});
  @override
  State<StatefulWidget> createState() => DeleteMessageDialogState(groupId: groupId,timestamp: timestamp,);
}
class DeleteMessageDialogState extends State<DeleteMessageDialog>{
  final String groupId;
  final String timestamp;
  DeleteMessageDialogState({this.groupId,this.timestamp});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('delete'),
      content: Text('do you want to delete this message?'),
      actions: <Widget>[
        FlatButton(
          child: Text('delete'),
          onPressed: () {
            Navigator.pop(context);
            _deleteMessage(timestamp, groupId);
          },
        ),
        FlatButton(
          child: Text('cancel'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}