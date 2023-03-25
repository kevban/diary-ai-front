import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/my_appbar.dart';
import 'package:diary_ai/widgets/shared/my_drawer.dart';
import 'package:diary_ai/widgets/shared/user_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/config.dart';
import 'package:go_router/go_router.dart';

class MyScaffold extends StatelessWidget {
  final Widget? body;
  final String? appbarTitle;
  final List<Widget>? actions;

  MyScaffold({Key? key, this.body, this.appbarTitle, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (AppData.token == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.headlineLarge,
                    children: [
                      TextSpan(text: 'Conver'),
                      TextSpan(
                          text: 'AI', style: TextStyle(color: Colors.teal)),
                    ]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacingMedium),
              Text(
                'Chat with any character, in any scenario.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacingLarge),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => UserSettingDialog());
                },
                icon: Icon(Icons.arrow_forward),
                label: Text('Get started'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: appbarTitle == null
          ? null
          : AppBar(
              title: Text(appbarTitle!),
              actions: actions,
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
