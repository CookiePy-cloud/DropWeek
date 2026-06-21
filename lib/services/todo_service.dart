import 'package:dropweek/models/todo.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TodoService {
  final SupabaseClient _client = SupabaseClientManager.client;

  Future<List<Todo>> getTodos(String userId) async {
    final response = await _client
        .from('todos')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((item) => Todo.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Todo> addTodo(String userId, String title) async {
    final response = await _client
        .from('todos')
        .insert({'user_id': userId, 'title': title, 'completed': false})
        .select()
        .single();
    return Todo.fromMap(response);
  }

  Future<void> toggleTodo(int id, bool completed) async {
    await _client
        .from('todos')
        .update({'completed': completed})
        .eq('id', id);
  }

  Future<void> updateTodoTitle(int id, String title) async {
    await _client.from('todos').update({'title': title}).eq('id', id);
  }

  Future<void> deleteTodo(int id) async {
    await _client.from('todos').delete().eq('id', id);
  }
}
