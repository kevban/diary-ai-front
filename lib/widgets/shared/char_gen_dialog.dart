import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
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

  void handleSubmit(BuildContext context) async {
    final name = _nameInputController.text;
    final desc = _descInputController.text;
    if (name.isNotEmpty && desc.isNotEmpty) {
      Character character = await context
          .read<CharacterProvider>()
          .createCharacter(name, desc, imageProvider, webImage == null? null :base64Encode(webImage!));
      Navigator.of(context).pop();
    }
  }

  ImageProvider? imageProvider;
  Uint8List? webImage;

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      File? img = File(image.path);
      img = await _cropImage(imageFile: img);
      XFile webImg = XFile(img!.path);
      var webImageBytes = await webImg.readAsBytes();
      setState(() {
        webImage = webImageBytes;
        imageProvider = MemoryImage(webImage!);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<File?> _cropImage({required File imageFile}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        maxHeight: 160,
        maxWidth: 160,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          WebUiSettings(
              context: context,
              boundary: const CroppieBoundary(width: 320, height: 320),
              enableZoom: true,
              viewPort: const CroppieViewPort(
                  width: 160, height: 160, type: 'square'))
        ]);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create a Character'),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 400,
          height: 230,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _pickImage(ImageSource.gallery);
                },
                child: CharacterAvatar(
                  name: _nameInputController.text,
                  size: 82,
                  color: Colors.brown,
                  image: imageProvider,
                ),
              ),
              TextField(
                decoration:
                    InputDecoration(labelText: 'Name', hintText: 'e.g. Mario'),
                controller: _nameInputController,
                onChanged: (text) {
                  setState(() {});
                },
              ),
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. from Super Mario Bros'),
                controller: _descInputController,
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            handleSubmit(context);
          },
          child: Text(
            'Create',
          ),
        )
      ],
    );
  }
}
