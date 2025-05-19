class TaskGroup {
  final String id;
  final String title;
  final String ownerId;
  final List<String> sharedWith;

  TaskGroup({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.sharedWith,
  });

  factory TaskGroup.fromMap(String id, Map<String, dynamic> map) {
    return TaskGroup(
      id: id,
      title: map['title'] ?? '',
      ownerId: map['ownerId'] ?? '',
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
    };
  }
}