import 'dart:convert';
import 'dart:math';

import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

class NewScenarioModal extends StatefulWidget {
  Scenario? scenario;

  NewScenarioModal({Key? key, this.scenario}) : super(key: key);

  @override
  State<NewScenarioModal> createState() => _NewScenarioModalState();
}

class _NewScenarioModalState extends State<NewScenarioModal> {
  double referenceStrength = 0.5;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  late RichTextController _settingController;
  TextEditingController _instructionController = TextEditingController();
  ScrollController _modalScrollController = ScrollController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ImageImporter imageImporter = ImageImporter(height: 330, width: 240);
  bool _isExpanded = false;

  @override
  void initState() {
    _settingController = RichTextController(
      patternMatchMap: {
        //
        //* Returns every Hashtag with red color
        //
        RegExp(r"\buser\b"): TextStyle(color: Colors.red),
        //
        //* Returns every Mention with blue color and bold style.
        //
        RegExp(r"\bchar\b"): TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.blue,
        ),
      },

      //! Assertion: Only one of the two matching options can be given at a time!

      //* starting v1.1.0
      //* Now you have an onMatch callback that gives you access to a List<String>
      //* which contains all matched strings
      onMatch: (List<String> matches) {
        // Do something with matches.
        //! P.S
        // as long as you're typing, the controller will keep updating the list.
      },
      deleteOnBack: true,
      // You can control the [RegExp] options used:
      regExpUnicode: true,
    );
    if (widget.scenario != null) {
      _titleController.text = widget.scenario!.title;
      _descController.text = widget.scenario!.description ?? '';
      _settingController.text = widget.scenario!.setting;
      _instructionController.text = widget.scenario!.instruction ?? '';
    }
    super.initState();
  }

  void handleCreate(ScenarioProvider scenarioProvider, BuildContext context) {
    String title = _titleController.text;
    String desc = _descController.text;
    String setting = _settingController.text;
    String instruction = _instructionController.text;
    if (_formKey.currentState!.validate()) {
      if (widget.scenario == null) {
        scenarioProvider.addScenario(
          title: title,
          userStart: false,
          setting: setting,
          description: desc,
          instruction: instruction,
          referenceStrength: referenceStrength,
          imgBase64: imageImporter.webImage == null
              ? null
              : base64Encode(imageImporter.webImage!),
        );
      } else {
        scenarioProvider.updateScenario(
            title: title,
            desc: desc,
            referenceStrength: referenceStrength,
            setting: setting,
            userStart: false,
            id: widget.scenario!.id,
            instruction: instruction,
            imgBase64: imageImporter.webImage == null
                ? widget.scenario!.imgBase64
                : base64Encode(imageImporter.webImage!));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ScenarioProvider scenarioProvider = context.read<ScenarioProvider>();
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        width: Breakpoints.sm,
        child: SingleChildScrollView(
          controller: _modalScrollController,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      widget.scenario == null
                          ? 'New Scenario'
                          : 'Edit Scenario',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(
                      height: spacingLarge,
                    ),
                    TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        String trimmedValue = value == null ? '' : value.trim();
                        if (trimmedValue.isEmpty) {
                          return 'Please enter a title';
                        } else if (trimmedValue.length > 30) {
                          return 'Title is too long!';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          label: Text('Title'),
                          helperText: 'Title of the chat scenario',
                          hintText: 'E.g. Meaning of life'),
                    ),
                    SizedBox(
                      height: spacingMedium,
                    ),
                    TextFormField(
                      controller: _settingController,
                      maxLines: 5,
                      minLines: 1,
                      validator: (value) {
                        String trimmedValue = value == null ? '' : value.trim();
                        if (trimmedValue.isEmpty) {
                          return 'Please describe the setting';
                        } else if (trimmedValue.length < 10) {
                          return 'Setting is too short!';
                        } else if (trimmedValue.length > 700) {
                          return 'Setting is too long!';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.casino),
                          onPressed: () {
                            String randomSetting =
                                RandomSetting.getRandomSetting();
                            _settingController.text = randomSetting;
                          },
                        ),
                        label: Text('Setting'),
                        helperMaxLines: 5,
                        helperText: '''
A detailed description on the conversation, which includes the setting and topics with the Character. 
Use 'char' to reference the Character, use 'user' to reference the User''',
                      ),
                    ),
                    SizedBox(
                      height: spacingMedium,
                    ),
                    ExpansionPanelList(
                      expandedHeaderPadding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          _isExpanded = !isExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                          isExpanded: _isExpanded,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              title: Text('Advanced Options'),
                              trailing: Icon(
                                _isExpanded
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                              ),
                            );
                          },
                          body: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      await imageImporter.pickImage(
                                          source: ImageSource.gallery,
                                          context: context);
                                      setState(() {});
                                    },
                                    style: imageImporter.imageProvider == null
                                        ? ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(kAccentColor))
                                        : ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(kSuccessColor)),
                                    child: imageImporter.imageProvider == null
                                        ? const Text('Select an Image')
                                        : const Text('Image Selected')),
                                const SizedBox(
                                  height: spacingMedium,
                                ),
                                TextFormField(
                                  validator: (value) {
                                    String trimmedValue = value == null ? '' : value.trim();
                                    if (trimmedValue.isNotEmpty) {
                                      if (trimmedValue.length > 100) {
                                        return 'Description is too long!';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _descController,
                                  decoration: InputDecoration(
                                      label: Text('Description'),
                                      helperText:
                                          'A short description of the chat scenario',
                                      hintText:
                                          'E.g. A deep discussion by the fireside'),
                                ),
                                SizedBox(
                                  height: spacingMedium,
                                ),
                                TextFormField(
                                  validator: (value) {
                                    String trimmedValue = value == null ? '' : value.trim();
                                    if (trimmedValue.isNotEmpty) {
                                      if (trimmedValue.length > 40) {
                                        return 'The style is too long!';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _instructionController,
                                  decoration: InputDecoration(
                                      label: Text('Dialog Style (optional)'),
                                      helperText:
                                          "Describe things that would appear in the character's dialog that wouldn't be there otherwise.",
                                      hintText: 'E.g. metaphors and analogies'),
                                ),
                                SizedBox(
                                  height: spacingMedium,
                                ),
                                FractionallySizedBox(
                                  widthFactor: 1,
                                  child: Column(children: [
                                    Text('Scenario vs Character strength'),
                                    Slider(
                                      activeColor: kAccentColor,
                                      value: referenceStrength,
                                      onChanged: (newVal) {
                                        setState(() {
                                          referenceStrength = newVal;
                                        });
                                      },
                                      divisions: 10,
                                      max: 1,
                                      min: 0,
                                      label: '$referenceStrength',
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('More on topic'),
                                        Text('More in character'),
                                      ],
                                    )
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: spacingMedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kAccentColor)),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              handleCreate(scenarioProvider, context),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  kSuccessColor)),
                          child:
                              Text(widget.scenario == null ? 'Create' : 'Save'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
