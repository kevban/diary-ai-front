import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserSettingDialog extends StatefulWidget {
  UserSettingDialog({Key? key, this.updateParent}) : super(key: key);
  Function()? updateParent;

  @override
  State<UserSettingDialog> createState() => _UserSettingDialogState();
}

class _UserSettingDialogState extends State<UserSettingDialog> {
  final _userNameController = TextEditingController();
  bool _isSubmitting = false;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      await AppData.initializeUser(
        name: _userNameController.text,
      );
      if (widget.updateParent != null) {
        widget.updateParent!();
        Navigator.pop(context);
      } else {
        context.go('/interviews/new');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AlertDialog(
        title: Text('Enter your name'),
        content: Container(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CharacterAvatar(
                //   user: true,
                // ),
                TextFormField(
                  validator: (value) {
                    String trimmedValue = value == null ? '' : value.trim();
                    if (trimmedValue.isEmpty) {
                      return 'Please enter a name!';
                    } else if (trimmedValue.length > 20) {
                      return 'Name too long!';
                    } else {
                      return null;
                    }
                  },
                  onFieldSubmitted: (text) => _handleSubmit(context),
                  decoration: const InputDecoration(
                      helperMaxLines: 2,
                      helperText:
                          'Characters will refer to this name in dialogs.'),
                  controller: _userNameController,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => _handleSubmit(context), child: Text('Enter'))
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
