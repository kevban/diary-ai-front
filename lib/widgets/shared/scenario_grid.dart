import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/config.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/widgets/shared/scenario_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScenarioGrid extends StatefulWidget {
  String mode;
  Function(Scenario)? select;
  String? selectedId;

  ScenarioGrid({Key? key, this.mode = 'display', this.select, this.selectedId})
      : super(key: key);

  @override
  State<ScenarioGrid> createState() => _ScenarioGridState();
}

class _ScenarioGridState extends State<ScenarioGrid> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ScenarioProvider scenarioProvider = context.watch<ScenarioProvider>();
    return GridView.count(
      crossAxisCount: width < Breakpoints.sm ? 2 : 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 10,
      childAspectRatio: 0.75,
      children: [
        ScenarioTile(),
        ...scenarioProvider.scenarios.map((scenario) => ScenarioTile(
              scenario: scenario,
              select: widget.select,
              selected: widget.selectedId == null
                  ? false
                  : widget.selectedId == scenario.id,
              mode: widget.mode,
            )).toList().reversed
      ],
    );
  }
}
