class Todo {
  final int? id;
  final String userId;
  final String title;
  final bool completed;
  final DateTime? createdAt;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    this.completed = false,
    this.createdAt,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      completed: map['completed'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'completed': completed,
    };
  }

  Todo copyWith({
    int? id,
    String? userId,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
