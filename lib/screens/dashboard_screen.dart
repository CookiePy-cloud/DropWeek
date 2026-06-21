import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:dropweek/supabase_client.dart';
import 'package:dropweek/models/todo.dart';
import 'package:dropweek/services/todo_service.dart';
import 'package:dropweek/screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _todoService = TodoService();
  final _newTodoController = TextEditingController();
  List<Todo> _todos = [];
  bool _loading = true;

  String? get _userId =>
      SupabaseClientManager.client.auth.currentSession?.user.id;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _newTodoController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final userId = _userId;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }
    try {
      final todos = await _todoService.getTodos(userId);
      if (!mounted) return;
      setState(() {
        _todos = todos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text('Error loading: $e')),
      );
    }
  }

  Future<void> _addTodo() async {
    final title = _newTodoController.text.trim();
    final userId = _userId;
    if (title.isEmpty || userId == null) return;

    _newTodoController.clear();
    try {
      final todo = await _todoService.addTodo(userId, title);
      if (!mounted) return;
      setState(() => _todos.insert(0, todo));
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text('Error adding: $e')),
      );
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      await _todoService.toggleTodo(todo.id!, !todo.completed);
      if (!mounted) return;
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = todo.copyWith(completed: !todo.completed);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text('Error: $e')),
      );
    }
  }

  Future<void> _editTodo(Todo todo) async {
    final controller = TextEditingController(text: todo.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Edit task'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadInput(
              controller: controller,
              placeholder: const Text('Task'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton(
                onPressed: () => Navigator.of(ctx).pop(controller.text),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.trim().isNotEmpty && todo.id != null) {
      try {
        await _todoService.updateTodoTitle(todo.id!, result.trim());
        if (!mounted) return;
        setState(() {
          final index = _todos.indexWhere((t) => t.id == todo.id);
          if (index != -1) {
            _todos[index] = todo.copyWith(title: result.trim());
          }
        });
      } catch (e) {
        if (!mounted) return;
        ShadToaster.of(context).show(
          ShadToast.destructive(title: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    if (todo.id == null) return;
    try {
      await _todoService.deleteTodo(todo.id!);
      if (!mounted) return;
      setState(() => _todos.removeWhere((t) => t.id == todo.id));
    } catch (e) {
      if (!mounted) return;
      ShadToaster.of(context).show(
        ShadToast.destructive(title: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await SupabaseClientManager.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String get _displayName {
    final user = SupabaseClientManager.client.auth.currentUser;
    return user?.userMetadata?['display_name'] as String? ??
        user?.email ??
        'User';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DropWeek'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                _displayName,
                style: theme.textTheme.p,
              ),
            ),
          ),
          ShadButton.destructive(
            size: ShadButtonSize.sm,
            onPressed: _logout,
            child: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 64,
                        color: theme.colorScheme.mutedForeground,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: theme.textTheme.h4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first task',
                        style: theme.textTheme.p,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _todos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return ShadCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          ShadCheckbox(
                            value: todo.completed,
                            onChanged: (_) => _toggleTodo(todo),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _editTodo(todo),
                              child: Text(
                                todo.title,
                                style: theme.textTheme.p.copyWith(
                                  decoration: todo.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: todo.completed
                                      ? theme.colorScheme.mutedForeground
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            onPressed: () => _deleteTodo(todo),
                            child: const Icon(Icons.delete_outline, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ShadInput(
            controller: _newTodoController,
            placeholder: const Text('Add a new task...'),
            trailing: ShadButton(
              size: ShadButtonSize.sm,
              onPressed: _addTodo,
              child: const Icon(Icons.add, size: 20),
            ),
            onSubmitted: (_) => _addTodo(),
          ),
        ),
      ),
    );
  }
}
