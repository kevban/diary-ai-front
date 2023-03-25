import 'dart:convert';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/pages/not_found_page.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../theme.dart';

class CharacterModal extends StatefulWidget {
  final Character? character;

  CharacterModal({Key? key, this.character}) : super(key: key);

  @override
  _CharacterModalState createState() => _CharacterModalState();
}

class _CharacterModalState extends State<CharacterModal> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _vocabController;
  late TextEditingController _referenceController;
  late List<String> _characteristics;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _referenceFormKey = GlobalKey<FormState>();

  ImageImporter imageImporter = ImageImporter(height: 160, width: 160);

  @override
  void initState() {
    if (widget.character != null) {
      _nameController = TextEditingController(text: widget.character!.name);
      _descController = TextEditingController(text: widget.character!.desc!);
      _vocabController = TextEditingController(text: widget.character!.vocab);
      _referenceController = TextEditingController();
      _characteristics = List.from(widget.character!.characteristics!);
    }

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _vocabController.dispose();
    super.dispose();
  }

  void _saveChanges(BuildContext context) {
    // Save the changes made to the character object
    if (_formKey.currentState!.validate()) {
      context.read<CharacterProvider>().updateCharacter(
          name: _nameController.text,
          desc: _descController.text,
          vocab: _vocabController.text,
          characteristics: _characteristics,
          id: widget.character!.id,
          imgBase64: imageImporter.webImage == null
              ? widget.character!.imgBase64
              : base64Encode(imageImporter.webImage!));
      Navigator.pop(context);
    }
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
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await imageImporter.pickImage(
                          source: ImageSource.gallery, context: context);
                      setState(() {});
                    },
                    child: CharacterAvatar(
                        image: imageImporter.imageProvider,
                        character: widget.character,
                        size: avatarLarge,
                      ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    validator: (value) {
                      String trimmedValue = value == null ? '' : value.trim();
                      if (trimmedValue.isEmpty) {
                        return 'Please enter a name';
                      } else if (trimmedValue.length > 30) {
                        return 'Name too long!';
                      } else {
                        return null;
                      }
                    },
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: spacingMedium),
                  TextFormField(
                    validator: (value) {
                      String trimmedValue = value == null ? '' : value.trim();
                      if (trimmedValue.isEmpty) {
                        return 'Please enter a description';
                      } else if (trimmedValue.length > 30) {
                        return 'Description too long!';
                      } else {
                        return null;
                      }
                    },
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  SizedBox(height: spacingMedium),
                  TextFormField(
                    controller: _vocabController,
                    validator: (value) {
                      String trimmedValue = value == null ? '' : value.trim();
                      if (trimmedValue.isEmpty) {
                        return "Please describe the character's dialog style";
                      } else if (trimmedValue.length > 400) {
                        return 'The dialog style description is too long!';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Dialog Style',
                    ),
                  ),
                  SizedBox(height: spacingSmall),
                  Form(
                    key: _referenceFormKey,
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        if (_referenceFormKey.currentState!.validate()) {
                          _addCharacteristic(value);
                          _referenceController.clear();
                        }
                      },
                      validator: (value) {
                        String trimmedValue = value == null ? '' : value.trim();
                        if (trimmedValue.isEmpty) {
                          return 'Please describe the a reference';
                        } else {
                          return null;
                        }
                      },
                      controller: _referenceController,
                      decoration: InputDecoration(
                        labelText: 'Add reference',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {
                            if (_referenceFormKey.currentState!.validate()) {
                              _addCharacteristic(_referenceController.text);
                              _referenceController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacingSmall),
                  Text(
                    'Things that ${widget.character!.name} may reference:',
                  ),
                  SizedBox(height: spacingMedium),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
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
                  ),
                  SizedBox(height: spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(kAccentColor)),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _saveChanges(context),
                            child: Text(
                              'Save',
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        kSuccessColor)),
                          ),
                          // ElevatedButton(
                          //   onPressed: () => _uploadCharacter(),
                          //   child: Text(
                          //     'Share',
                          //   ),
                          //   style: ButtonStyle(
                          //       backgroundColor:
                          //           MaterialStateProperty.all<Color>(kSuccessColor)),
                          // ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
