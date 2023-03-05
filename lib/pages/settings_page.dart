import 'package:diary_ai/providers/message_provider.dart';
import 'package:diary_ai/widgets/setting_widgets/topics_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/shared/my_scaffold.dart';

class SettingsPage extends StatefulWidget {
  final String userName;
  final List<String> topics;

  const SettingsPage({required this.userName, required this.topics});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _userName;
  late List<String> _topics;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _topics = List<String>.from(widget.topics);
  }

  void _onUserNameChanged(String value) {
    setState(() {
      _userName = value;
    });
  }

  void _onTopicsChanged(List<String> value) {
    setState(() {
      _topics = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appbarTitle: 'Settings',
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'User Name',
            ),
            onChanged: _onUserNameChanged,
            onEditingComplete: () => {saveSettings(context)},
            controller: TextEditingController(text: _userName),
          ),
          TopicsField(
            topics: _topics,
            onChanged: _onTopicsChanged,
            onEditingComplete: () => {saveSettings(context)},
          ),
        ],
      ),
    );
  }

  void saveSettings(BuildContext context) {
    // context.read<MessageProvider>().updateSettings(_userName, _topics);
    // save settings to local storage or database
  }
}
