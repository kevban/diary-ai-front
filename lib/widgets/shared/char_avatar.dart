import 'package:diary_ai/classes/character.dart';
import 'package:flutter/material.dart';

class CharacterAvatar extends StatelessWidget {
  final String name;
  final ImageProvider? image;
  final double size;
  final Color color;

  const CharacterAvatar({
    Key? key,
    this.name = 'AI',
    this.size = 48,
    this.color = Colors.brown,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return CircleAvatar(
        backgroundImage: image,
        backgroundColor: color,
        radius: size / 2,
      );
    } else if (name == '') {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: const Text(
          'AI',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: Text(
          name[0],
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
