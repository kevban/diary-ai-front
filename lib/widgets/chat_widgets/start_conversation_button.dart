import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartConversationButton extends StatefulWidget {
  @override
  _StartConversationButtonState createState() =>
      _StartConversationButtonState();
}

class _StartConversationButtonState extends State<StartConversationButton> {
  String? _selectedItem;

  @override
  Widget build(BuildContext context) {
    List<Character> characters = context.watch<CharacterProvider>().characters;
    List<String> items = characters.map((e) => e.name).toList();
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text('Select an Interviewer'),
            DropdownButtonFormField<String>(
              value: _selectedItem,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedItem = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Select an option',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {},
              child: Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
