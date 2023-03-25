import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/widgets/char_widgets/char_details_modal.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/char_gen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../shared/confirmation_dialog.dart';

class CharacterTile extends StatefulWidget {
  final Character? character;
  final bool selected;
  String mode;
  final Function(Character)? select;

  CharacterTile(
      {Key? key,
      this.character,
      this.select,
      this.selected = false,
      this.mode = 'display'})
      : super(key: key);

  @override
  State<CharacterTile> createState() => _CharacterTileState();
}

class _CharacterTileState extends State<CharacterTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.character == null) {
      return ListTile(
        title: Text('Create a new character'),
        onTap: () {
          showDialog(context: context, builder: (_) => CharGenDialog());
        },
        leading: Icon(Icons.add),
      );
    }
    Widget trailing;
    switch (widget.mode) {
      case 'display':
        trailing = Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(maxWidth: Breakpoints.sm),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      builder: (BuildContext context) {
                        return CharacterModal(character: widget.character,);
                      });
                },
              ),
              SizedBox(width: spacingSmall),
              IconButton(onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                        action: 'delete "${widget.character!.name}"',
                        actionWidget: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<CharacterProvider>()
                                  .removeCharacterById(widget.character!.id);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all<Color>(kErrorColor),
                            ),
                            child: const Text('Delete'))));
              }, icon: const Icon(Icons.delete)),
            ],
          ),
        );
        break;
      case 'select':
        trailing = ElevatedButton(
            onPressed: () {
              widget.select!(widget.character!);
            },
            child: Text(
              widget.selected ? 'Selected' : 'Select',
            ),
            style: ButtonStyle(
              backgroundColor: widget.selected
                  ? MaterialStateProperty.all<Color>(kSuccessColor)
                  : MaterialStateProperty.all<Color>(kAccentColor),
            ));
        break;
      default:
        trailing = Container();
    }
    return ListTile(
        leading: CharacterAvatar(
          character: widget.character,
          size: avatarSmall,
        ),
        title: Text(widget.character!.name),
        subtitle: Text(widget.character!.desc),
        trailing: trailing);
  }
}
