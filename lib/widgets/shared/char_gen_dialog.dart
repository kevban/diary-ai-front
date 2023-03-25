import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/no_more_tokens_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CharGenDialog extends StatefulWidget {
  CharGenDialog({Key? key}) : super(key: key);

  @override
  State<CharGenDialog> createState() => _CharGenDialogState();
}

class _CharGenDialogState extends State<CharGenDialog> {
  final _nameInputController = TextEditingController();
  final _descInputController = TextEditingController();
  bool _isSubmitting = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ImageImporter imageImporter = ImageImporter(height: 160, width: 160);

  void handleSubmit(BuildContext context, ImageImporter imageImporter) async {
    final name = _nameInputController.text;
    final desc = _descInputController.text;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      bool success = await context.read<CharacterProvider>().createCharacter(
          name: name,
          desc: desc,
          imgBase64: imageImporter.webImage == null
              ? null
              : base64Encode(imageImporter.webImage!));
      if (!success) {
        showDialog(
            context: context, builder: (context) => NoMoreTokensDialog());
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AlertDialog(
        title: Text('Create a Character'),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacingSmall),
          child: Container(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await imageImporter.pickImage(
                          source: ImageSource.gallery, context: context);
                      setState(() {});
                    },
                    child: Center(
                      child: CharacterAvatar(
                        name: _nameInputController.text,
                        size: avatarLarge,
                        color: Colors.brown,
                        image: imageImporter.imageProvider,
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Name', hintText: 'e.g. Mario'),
                    controller: _nameInputController,
                    validator: (value) {
                      String trimmedValue = value == null ? '' : value.trim();
                      if (trimmedValue.isEmpty) {
                        return 'Please enter a name';
                      } else if (trimmedValue.length > 30) {
                        return 'Name is too long!';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: spacingMedium),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'e.g. from Super Mario Bros'),
                    validator: (value) {
                      String trimmedValue = value == null ? '' : value.trim();
                      if (trimmedValue.isEmpty) {
                        return 'Please enter a description';
                      } else if (trimmedValue.length > 30) {
                        return 'Description is too long!';
                      } else {
                        return null;
                      }
                    },
                    controller: _descInputController,
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              handleSubmit(context, imageImporter);
            },
            child: Text(
              'Create',
            ),
          )
        ],
      ),
      if (_isSubmitting)
        Container(
          color: Colors.black54,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
    ]);
  }
}
