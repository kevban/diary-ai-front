import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String text;
  final Function(String) onSave;

  const EditableTextWidget({Key? key, required this.text, required this.onSave}) : super(key: key);

  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool _isEditing = false;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _textEditingController.text = widget.text;
    });
  }

  void _saveEditing() {
    setState(() {
      _isEditing = false;
      widget.onSave(_textEditingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startEditing,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: _isEditing
            ? Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                controller: _textEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onEditingComplete: _saveEditing,
              ),
            ),
            IconButton(
              onPressed: _cancelEditing,
              icon: Icon(Icons.cancel),
            ),
          ],
        )
            : Text(
          widget.text,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}