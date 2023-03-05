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
            SizedBox(height: 16.0),
            Text(
              'Oops! We couldn\'t find the page you were looking for.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
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
