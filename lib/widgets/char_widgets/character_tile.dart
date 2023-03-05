import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CharacterTile extends StatelessWidget {
  final Character character;

  const CharacterTile({Key? key, required this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CharacterAvatar(
        name: character.name,
        size: 48,
        image: character.getImage(),
      ),
      title: Text(character.name),
      subtitle: Text(character.desc),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          context.go('/characters/${character.name}');
        },
      ),
    );
  }
}
