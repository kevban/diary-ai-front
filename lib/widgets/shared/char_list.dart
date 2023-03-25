import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/widgets/char_widgets/character_tile.dart';
import 'package:provider/provider.dart';

class CharList extends StatefulWidget {
  String mode;
  String? selectedId;
  Function(Character)? select;

  CharList({Key? key, this.mode = 'display', this.selectedId, this.select})
      : super(key: key);

  @override
  State<CharList> createState() => _CharListState();
}

class _CharListState extends State<CharList> {
  @override
  Widget build(BuildContext context) {
    List<Character> characters = context.watch<CharacterProvider>().characters;
    return ListView(
      children: [
        CharacterTile(),
        ...characters.map((character) => CharacterTile(
              character: character,
              mode: widget.mode,
              selected: widget.selectedId == null
                  ? false
                  : widget.selectedId == character.id,
              select: widget.select,
            )).toList().reversed,
      ],
    );
  }
}
