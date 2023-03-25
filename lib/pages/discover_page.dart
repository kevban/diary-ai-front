import 'package:diary_ai/app_data.dart';
import 'package:diary_ai/classes/scenario.dart';
import 'package:diary_ai/diary_api.dart';
import 'package:diary_ai/providers/character_provider.dart';
import 'package:diary_ai/providers/discovery_provider.dart';
import 'package:diary_ai/providers/scenario_provider.dart';
import 'package:diary_ai/theme.dart';
import 'package:diary_ai/widgets/discover_widgets/discovery_tile.dart';
import 'package:diary_ai/widgets/discover_widgets/search_form.dart';
import 'package:diary_ai/widgets/discover_widgets/tutorial_dialog.dart';
import 'package:diary_ai/widgets/shared/char_gen_dialog.dart';
import 'package:diary_ai/widgets/shared/my_scaffold.dart';
import 'package:diary_ai/widgets/shared/scenario_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../classes/character.dart';

class DiscoverPage extends StatefulWidget {
  DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  ScrollController charScrollController = ScrollController();
  ScrollController scenarioScrollController = ScrollController();
  bool isSearching = false;
  List<Character>? characterList;
  List<Scenario>? scenarioList;

  void searchScenario(String term, DiscoverProvider discoverProvider) async {
    setState(() {
      isSearching = true;
    });

    if (term.isNotEmpty) {
      scenarioList = await DiaryAPI.findScenario(scenarioTitle: term);
    } else {
      scenarioList = discoverProvider.popularScenarios;
    }
    setState(() {
      isSearching = false;
    });
  }

  void searchChar(String term, DiscoverProvider discoverProvider) async {
    setState(() {
      isSearching = true;
    });

    if (term.isNotEmpty) {
      characterList = await DiaryAPI.findChar(charName: term);
    } else {
      characterList = discoverProvider.popularCharacters;
    }

    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DiscoverProvider discoverProvider = context.watch<DiscoverProvider>();
    CharacterProvider characterProvider = context.read<CharacterProvider>();
    ScenarioProvider scenarioProvider = context.read<ScenarioProvider>();
    if (AppData.tutorials['discover'] == false) {
      Future.delayed(
          Duration.zero,
          () => showDialog(
              context: context, builder: (context) => const TutorialDialog()));
      AppData.showTutorial('discover');
    }
    if (discoverProvider.popularCharacters == null ||
        discoverProvider.popularScenarios == null) {
      discoverProvider.initDiscover();
      return MyScaffold(
        appbarTitle: 'Discover',
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      if (scenarioList == null || characterList == null) {
        setState(() {
          scenarioList = discoverProvider.popularScenarios;
          characterList = discoverProvider.popularCharacters;
        });
      }
      return MyScaffold(
        appbarTitle: 'Discover',
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Stack(
            children: [
              ListView(
                children: [
                  Material(
                    elevation: 4,
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.go('/interviews/new');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.add_circle),
                            Text(
                              'Start a new chat',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: spacingMedium,
                  ),
                  Text(
                    'Popular Scenarios',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: spacingMedium,
                  ),
                  SearchForm(
                    send: (term) {
                      searchScenario(term, discoverProvider);
                    },
                    searchTarget: 'scenarios',
                  ),
                  Container(
                    height: 250,
                    child: Scrollbar(
                      controller: scenarioScrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        controller: scenarioScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: scenarioList!.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: spacingSmall,
                          );
                        },
                        itemBuilder: (context, index) {
                          return Container(
                              width: 170,
                              height: 250,
                              child: DiscoveryTile(
                                content: scenarioList![index],
                                select: () {
                                  scenarioProvider.downloadScenario(
                                      scenario: scenarioList![index]);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: spacingSmall),
                                          Expanded(
                                            child: Text(
                                              'Successfully added scenario!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.grey[800],
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ));
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: spacingLarge,
                  ),
                  Text(
                    'Popular Characters',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: spacingMedium,
                  ),
                  SearchForm(
                    send: (term) {
                      searchChar(term, discoverProvider);
                    },
                    searchTarget: 'characters',
                  ),
                  Container(
                    height: 260,
                    child: Scrollbar(
                      controller: charScrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        controller: charScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: characterList!.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            width: spacingSmall,
                          );
                        },
                        itemBuilder: (context, index) {
                          return Container(
                              width: 170,
                              height: 250,
                              child: DiscoveryTile(
                                content: characterList![index],
                                select: () {
                                  characterProvider.downloadCharacter(
                                      character: characterList![index]);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: spacingSmall),
                                          Expanded(
                                            child: Text(
                                              'Successfully added character!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.grey[800],
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ));
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (isSearching)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      );
    }
  }
}
