import 'package:diary_ai/widgets/shared/my_appbar.dart';
import 'package:diary_ai/widgets/shared/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/config.dart';

class MyScaffold extends StatelessWidget {
  final Widget? body;
  final String appbarTitle;

  const MyScaffold({Key? key, this.body, required this.appbarTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appbarTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < Breakpoints.sm) {
            return Center(
              child: Container(
                child: body,
              ),
            );
          } else {
            return Center(
              child: Container(
                width: Breakpoints.sm,
                child: body,
              ),
            );
          }
        },
      ),
      drawer: MyDrawer(),
    );
  }
}
