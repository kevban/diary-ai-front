import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/pages/not_found_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CharacterDetailsPage extends StatefulWidget {
  final Character? character;

  CharacterDetailsPage({Key? key, this.character}) : super(key: key);

  @override
  _CharacterDetailsPageState createState() => _CharacterDetailsPageState();
}

class _CharacterDetailsPageState extends State<CharacterDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late List<String> _characteristics;

  @override
  void initState() {
    if (widget.character != null) {
      _nameController = TextEditingController(text: widget.character!.name);
      _descController = TextEditingController(text: widget.character!.desc!);
      _characteristics = List.from(widget.character!.characteristics!);
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges(BuildContext context) {
    // Save the changes made to the character object
    Character updatedCharacter = Character(
      name: _nameController.text,
      desc: _descController.text,
      vocab: widget.character!.vocab,
      characteristics: _characteristics,
    );
    context.read<CharacterProvider>().updateCharacter(updatedCharacter);
    context.go('/characters');
  }

  void _addCharacteristic(String value) {
    setState(() {
      _characteristics.add(value);
    });
  }

  void _removeCharacteristic(int index) {
    setState(() {
      _characteristics.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    if (widget.character == null) {
      return NotFoundPage();
    }
    print(widget.character!.characteristics.length);
    return MyScaffold(
      appbarTitle: 'Character',
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _descController,
            maxLines: null,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Characteristics',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _characteristics.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_characteristics[index]),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    _removeCharacteristic(index);
                  },
                ),
              );
            },
          ),
          SizedBox(height: 16.0),
          TextField(
            onSubmitted: (value) {
              _addCharacteristic(value);
            },
            decoration: InputDecoration(
              labelText: 'Add characteristic',
              suffixIcon: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  _addCharacteristic(_nameController.text);
                  _nameController.clear();
                },
              ),
            ),
          ),
          SizedBox(height: 16.0),
          TextButton(
            onPressed: () => _saveChanges(context),
            child: Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
