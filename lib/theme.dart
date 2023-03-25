import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///colors
const kPrimaryColor = Color.fromRGBO(94, 160, 131, 1.0);
const kSecondaryColor = Color(0xFF222222);
const kShadeColor = Color.fromRGBO(34, 34, 34, 0.7);
const kAccentColor = Color.fromRGBO(87, 127, 140, 1.0);
const kSuccessColor = Color.fromRGBO(94, 160, 131, 1.0);
const kTextColor = Color(0xFFE0E0E0);
const kAccentTextColor = Color(0xFFCBCBCB);
const kErrorColor = Color.fromRGBO(173, 54, 79, 1.0);

///sizes
const avatarSmall = kIsWeb ? 54.0 : 42.0;
const avatarLarge = kIsWeb ? 82.0 : 64.0;
const spacingSmall = kIsWeb ? 10.0 : 6.0;
const spacingMedium = kIsWeb ? 16.0 : 10.0;
const spacingLarge = kIsWeb ? 24.0: 32.0;


ThemeData createTheme(context) {
  final theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        brightness: Brightness.dark,
        primary: kPrimaryColor,
        secondary: kAccentColor,
        error: kErrorColor),
    textTheme: Theme.of(context).textTheme.apply(
      fontFamily: 'RocknRollOne',
      fontSizeFactor: kIsWeb ? 1.1 : 0.9,
      bodyColor: kTextColor,
      displayColor: kAccentTextColor,
    ),
  );
  return theme;
}
