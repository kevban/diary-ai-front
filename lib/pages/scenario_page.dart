import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:diary_ai/widgets/shared/scenario_grid.dart';
import 'package:diary_ai/widgets/shared/scenario_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScenarioPage extends StatefulWidget {
  ScenarioPage({Key? key}) : super(key: key);

  @override
  State<ScenarioPage> createState() => _ScenarioState();
}

class _ScenarioState extends State<ScenarioPage> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
        appbarTitle: 'Scenarios',
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: ScenarioGrid(),
        ));
  }
}
