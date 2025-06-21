import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static const _storageKey = 'todos';

  static Future<List<Todo>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getString(_storageKey);

    if (todosJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(todosJson);
      return decoded.map((item) => Todo.fromJson(item)).toList();
    } catch (e) {
      print('Error loading todos: $e');
      return [];
    }
  }

  static Future<void> saveAll(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = json.encode(todos.map((todo) => todo.toJson()).toList());
    await prefs.setString(_storageKey, todosJson);
  }
}
