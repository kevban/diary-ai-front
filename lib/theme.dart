import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color(0xFF121212);
const kSecondaryColor = Color(0xFF222222);
const kShadeColor = Color.fromRGBO(34, 34, 34, 0.7);
const kAccentColor = Color.fromRGBO(0, 112, 143, 1);
const kSuccessColor = Colors.teal;
const kTextColor = Color(0xFFE0E0E0);
const kErrorColor = Colors.red;

ColorScheme appColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: kPrimaryColor,
    onPrimary: kTextColor,
    secondary: kSecondaryColor,
    onSecondary: kTextColor,
    error: kSecondaryColor,
    onError: kErrorColor,
    background: kPrimaryColor,
    onBackground: kTextColor,
    surface: kSecondaryColor,
    onSurface: kTextColor);

ThemeData appTheme = ThemeData(
    colorScheme: appColorScheme,
    textTheme: GoogleFonts.rocknRollOneTextTheme(TextTheme()),
    inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: kTextColor),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: kTextColor))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
            backgroundColor: MaterialStateProperty.all<Color>(kAccentColor))),
    textSelectionTheme: TextSelectionThemeData(cursorColor: kTextColor));
