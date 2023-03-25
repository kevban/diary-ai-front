import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/widgets/char_widgets/char_details_modal.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/char_widgets/character_tile.dart';
import 'package:diary_ai/widgets/shared/char_gen_dialog.dart';
import 'package:diary_ai/widgets/shared/char_list.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CharPage extends StatefulWidget {
  const CharPage({Key? key}) : super(key: key);

  @override
  State<CharPage> createState() => _CharPageState();
}

class _CharPageState extends State<CharPage> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appbarTitle: 'Characters',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: CharList(),
        ),
      ),
    );
  }
}
