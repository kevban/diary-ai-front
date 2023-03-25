import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/my_appbar.dart';
import 'package:diary_ai/widgets/shared/user_setting_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: ListTile(
              leading: const CharacterAvatar(
                user: true,
              ),
              title: Text(
                AppData.userName,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              trailing: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => UserSettingDialog(
                              updateParent: () => setState(() {}),
                            ));
                  },
                  icon: const Icon(Icons.edit)),
            ),
          ),
          SizedBox(
            height: spacingMedium,
          ),
          Divider(),
          SizedBox(
            height: spacingMedium,
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text("Discover"),
            onTap: () {
              context.go('/discover');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text("New Chat"),
            onTap: () {
              context.go('/interviews/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("My Chats"),
            onTap: () {
              context.go('/chat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.mms_outlined),
            title: const Text("Scenarios"),
            onTap: () {
              context.go('/scenarios');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Characters"),
            onTap: () {
              context.go('/characters');
            },
          ),
        ],
      ),
    );
  }
}
