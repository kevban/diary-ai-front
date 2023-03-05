import 'package:diary_ai/helpers.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';

class DiaryDetailsPage extends StatefulWidget {
  final String title;
  final String date;

  DiaryDetailsPage({required this.title, required this.date});

  @override
  State<DiaryDetailsPage> createState() => _DiaryDetailsPageState();
}

class _DiaryDetailsPageState extends State<DiaryDetailsPage> {
  Future<String> getDiaryEntry() async {
    print('title:'+ widget.title);
    print('date:'+ widget.date);
    final entries =
        await LocalStorage.getLocalFile('/diary/${widget.title}${widget.date}.txt');
    if (entries == null) {
      return '';
    } else {
      return entries;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        appbarTitle: 'Diary',
        body: FutureBuilder(
          future: getDiaryEntry(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              final content = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      widget.date,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
