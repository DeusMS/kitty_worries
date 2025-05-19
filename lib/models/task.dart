enum TaskPriority { low, medium, high }

class Task {
  String? id;
  String title;
  String? description;
  DateTime? date;
  bool isCompleted;
  TaskPriority priority;
  List<String> tags;
  String listName; // 🔹 название пользовательского списка

  Task({
    this.id,
    required this.title,
    this.description,
    this.date,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.listName = 'Входящие', // 🔸 значение по умолчанию
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': date?.toIso8601String(),
      'isCompleted': isCompleted,
      'priority': priority.index,
      'tags': tags,
      'listName': listName, // 🔹 добавлено в Firebase
    };
  }

  Task copyWith({
  String? id,
  String? title,
  String? description,
  DateTime? date,
  bool? isCompleted,
  TaskPriority? priority,
  List<String>? tags,
  String? listName,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      listName: listName ?? this.listName,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      isCompleted: map['isCompleted'] ?? false,
      priority: TaskPriority.values[(map['priority'] as int?) ?? 1],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      listName: map['listName'] ?? 'Входящие', // 🔹 читаем из Firebase
    );
  }
}
