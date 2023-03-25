import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: spacingMedium),
            Text(
              'Oops! We couldn\'t find the page you were looking for.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacingMedium),
            ElevatedButton(
              child: Text('Go Back'),
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
