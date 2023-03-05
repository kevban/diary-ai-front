import 'package:diary_ai/providers/content_provider.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        appbarTitle: 'Diaries',
        body: ListView.builder(
            itemCount: 0,
            itemBuilder: (BuildContext context, int index) {
          final entry = [];
          if (entry.isEmpty) {
            return Text('You have no diary recorded');
          }
          return ListTile(
            title: Text(entry[0]),
            subtitle: Text(entry[0]),
            trailing: IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                context.go('/diary/$index');
              },
            ),
          );
        }));
  }
}
