import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/theme.dart';
import 'package:flutter/material.dart';

class CharacterAvatar extends StatelessWidget {
  final Character? character;
  final ImageProvider? image;
  final String? name;
  final double size;
  final Color color;
  final bool user;

  const CharacterAvatar({
    Key? key,
    this.character,
    this.image,
    this.name,
    this.size = avatarSmall,
    this.color = Colors.brown,
    this.user = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (character != null) {
      return CircleAvatar(
        foregroundImage: image ?? character!.getImage(),
        backgroundColor: color,
        radius: size / 2,
        child: Text(
          character!.name[0],
          style: TextStyle(color: kTextColor),
        ),
      );
    } else if (user) {
      return CircleAvatar(
        backgroundColor: Colors.teal,
        radius: size / 2,
        child: Text('Me', style: TextStyle(color: Colors.white)),
      );
    } else if (image != null) {
      return CircleAvatar(
        backgroundColor: color,
        foregroundImage: image,
        radius: size / 2,
      );
    } else if (name != null && name!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: color,
        foregroundImage: image,
        radius: size / 2,
        child: Text(
          name![0],
          style: TextStyle(color: kTextColor),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: const Text(
          'AI',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
