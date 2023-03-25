import 'dart:convert';

import 'package:diary_ai/classes/character.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/char_avatar.dart';
import 'package:diary_ai/widgets/shared/confirmation_dialog.dart';
import 'package:diary_ai/widgets/shared/new_scenario_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoveryTile extends StatefulWidget {
  dynamic content;
  Function() select;

  DiscoveryTile({Key? key, required this.content, required this.select})
      : super(key: key);

  @override
  State<DiscoveryTile> createState() => _DiscoveryTileState();
}

class _DiscoveryTileState extends State<DiscoveryTile> {
  bool _selected = false;

  String _displayDownload(int downloads) {
    if (downloads >= 1000) {
      double formattedDownloads = downloads / 1000;
      return '${formattedDownloads}k';
    } else {
      return downloads.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content is Scenario) {
      Scenario scenario = widget.content;
      ImageProvider? imageProvider = scenario.getImage();
      return GridTile(
        footer: Padding(
          padding: EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: () {
              if (!_selected) {
                widget.select();
                setState(() {
                  _selected = true;
                });
              }
            },
            child: _selected
                ? Icon(Icons.check)
                : Text('Add'),
            style: ButtonStyle(
                backgroundColor: _selected
                    ? MaterialStateProperty.all<Color>(kSuccessColor)
                    : MaterialStateProperty.all<Color>(kAccentColor)),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kSecondaryColor,
              image: imageProvider == null
                  ? null
                  : DecorationImage(
                      colorFilter: const ColorFilter.mode(
                          Color.fromRGBO(0, 0, 0, 0.7), BlendMode.darken),
                      fit: BoxFit.cover,
                      image: imageProvider,
                    ),
              border: Border.all(color: kTextColor),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              Text(scenario.title, textAlign: TextAlign.center,),
              SizedBox(
                height: spacingMedium,
              ),
              Text(
                scenario.description ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    } else {
      Character character = widget.content as Character;
      return GridTile(
        footer: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              if (!_selected) {
                widget.select();
                setState(() {
                  _selected = true;
                });
              }
            },
            style: ButtonStyle(
                backgroundColor: _selected
                    ? MaterialStateProperty.all<Color>(kSuccessColor)
                    : MaterialStateProperty.all<Color>(kAccentColor)),
            child: _selected
                ? const Icon(Icons.check)
                : Text('Add'),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kSecondaryColor,
              border: Border.all(color: kTextColor),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              CharacterAvatar(
                character: character,
                size: avatarLarge,
              ),
              const SizedBox(
                height: spacingSmall,
              ),
              Text(
                character.name,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                height: spacingSmall,
              ),
              Text(
                character.desc,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      );
    }
  }
}
