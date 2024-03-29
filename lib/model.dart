class ToDoModel {
  int? taskId;
  String title;
  String description;
  String date;

  ToDoModel(
      {this.taskId,
      required this.title,
      required this.description,
      required this.date});

  Map<String, dynamic> todoMap() {
    return {'title': title, 'description': description, 'date': date};
  }

  @override
  String toString() {
    return '{taskId: $taskId,title:$title,description:$description,date:$date}';
  }
}
