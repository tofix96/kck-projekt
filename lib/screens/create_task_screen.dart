import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_service.dart';
import '../providers/auth_provider.dart';

class CreateTaskScreen extends StatefulWidget {
  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  double? _budget;
  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value,
                validator: (value) => value!.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
                validator: (value) => value!.isEmpty ? 'Description is required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _budget = double.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Budget is required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Deadline'),
                onSaved: (value) => _deadline = DateTime.tryParse(value!),
                validator: (value) => value!.isEmpty ? 'Deadline is required' : null,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await taskService.createTask(
                      _title!,
                      _description!,
                      _budget!,
                      _deadline!,
                      authProvider.user!['id'], // Passing clientId
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
