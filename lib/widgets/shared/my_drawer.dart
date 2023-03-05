import 'package:diary_ai/widgets/shared/my_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("New Intervew"),
            onTap: () {
              context.go('/interviews/new');
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text("Chat"),
            onTap: () {
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text("Diary"),
            onTap: () {
              context.go('/diary');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Characters"),
            onTap: () {
              context.go('/characters');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              context.go('/settings');
            },
          ),
        ],
      ),
    );
  }
}
