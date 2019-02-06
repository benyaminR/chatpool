

String timeConverter(int unix){
  DateTime date = new DateTime.fromMillisecondsSinceEpoch(unix);
  return '${date.hour}:${date.minute}';
}