import 'package:flutter/material.dart';

class AddCategoryDialog extends StatelessWidget {
  final Function(String) onCategoryAdded;

  AddCategoryDialog({
    required this.onCategoryAdded,
  });

  @override
  Widget build(BuildContext context) {
    String newCategoryName = '';
    return AlertDialog(
      title: Text(
        'Add New College',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TextField(
        onChanged: (value) {
          newCategoryName = value;
        },
        decoration: InputDecoration(
          labelText: 'College Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onCategoryAdded(newCategoryName);
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
