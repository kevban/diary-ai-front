import 'dart:convert';

import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/shared/confirmation_dialog.dart';
import 'package:diary_ai/widgets/shared/new_scenario_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScenarioTile extends StatefulWidget {
  Scenario? scenario;
  String mode;
  Function(Scenario)? select;
  bool selected;

  ScenarioTile(
      {Key? key,
      this.scenario,
      this.select,
      this.mode = 'display',
      this.selected = false})
      : super(key: key);

  @override
  State<ScenarioTile> createState() => _ScenarioTileState();
}

class _ScenarioTileState extends State<ScenarioTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.scenario == null) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              constraints: BoxConstraints(maxWidth: Breakpoints.sm),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              builder: (BuildContext context) {
                return NewScenarioModal();
              });
        },
        child: GridTile(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border.all(color: kTextColor),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Create New'),
                  const Icon(
                    Icons.add,
                    size: 48,
                  )
                ]),
          ),
        ),
      );
    }

    Widget footer;
    switch (widget.mode) {
      case "display":
        footer = Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                      return NewScenarioModal(
                        scenario: widget.scenario!,
                      );
                    });
              },
            ),
            SizedBox(
              width: spacingSmall,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                        action: 'delete "${widget.scenario!.title}"',
                        actionWidget: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<ScenarioProvider>()
                                  .removeScenarioById(widget.scenario!.id);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(kErrorColor),
                            ),
                            child: const Text('Delete'))));
              },
            ),
          ],
        );
        break;
      case "select":
        footer = Padding(
          padding: EdgeInsets.all(15),
          child: ElevatedButton(
              onPressed: () {
                widget.select!(widget.scenario!);
              },
              child: Text(
                widget.selected ? 'Selected' : 'Select',
              ),
              style: ButtonStyle(
                backgroundColor: widget.selected
                    ? MaterialStateProperty.all<Color>(kSuccessColor)
                    : MaterialStateProperty.all<Color>(kAccentColor),
              )),
        );
        break;
      default:
        footer = Container();
    }
    ImageProvider? imageProvider = widget.scenario!.getImage();

    return GridTile(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            image: imageProvider == null
                ? null
                : DecorationImage(
                    colorFilter:
                        ColorFilter.mode(Colors.black54, BlendMode.darken),
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
            color: kSecondaryColor,
            border: Border.all(color: kTextColor),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            Text(widget.scenario!.title),
            SizedBox(
              height: spacingMedium,
            ),
            Expanded(
                child: SingleChildScrollView(
                    child: Text(widget.scenario!.description ?? ''))),
          ],
        ),
      ),
      footer: footer,
    );
  }
}
