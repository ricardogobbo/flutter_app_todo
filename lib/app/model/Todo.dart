class Todo {
  String title;
  bool done;


  Todo(this.title, this.done);

  @override
  String toString() {
    return '{ "title": "$title", "done": $done }';
  }
}