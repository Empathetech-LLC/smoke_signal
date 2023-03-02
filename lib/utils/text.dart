import '../user/user-api.dart';
import '../utils/constants.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Aliases
const String defaultStyle = 'defaultStyle';
const String titleStyle = 'titleStyle';
const String subTitleStyle = 'subTitleStyle';
const String buttonStyle = 'buttonStyle';
const String dialogTitleStyle = 'dialogTitleStyle';
const String dialogContentStyle = 'dialogContentStyle';
const String colorSettingStyle = 'colorSettingStyle';
const String imageSettingStyle = 'imageSettingStyle';
const String joinedStyle = 'joinedStyle';
const String watchingStyle = 'watchingStyle';
const String errorStyle = 'errorStyle';

TextStyle getTextStyle(String textType) {
  // Gather theme data
  late String currFontFamily = googleStyleAlias(AppUser.prefs[fontFamilyKey]).fontFamily!;

  late double currSize = AppUser.prefs[fontSizeKey];

  late Color themeColor = Color(AppUser.prefs[themeColorKey]);
  late Color themeTextColor = Color(AppUser.prefs[themeTextColorKey]);
  late Color buttonTextColor = Color(AppUser.prefs[buttonTextColorKey]);
  late Color joinedTextColor = Color(AppUser.prefs[joinedTextColorKey]);
  late Color watchingTextColor = Color(AppUser.prefs[watchingTextColorKey]);

  switch (textType) {
    // Shared
    case defaultStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize,
        color: themeTextColor,
      );

    case titleStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize * 1.5,
        color: themeTextColor,
      );

    case subTitleStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize * 1.25,
        color: themeTextColor,
        decoration: TextDecoration.underline,
      );

    case buttonStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize,
        color: buttonTextColor,
      );

    case dialogTitleStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize * 1.25,
        color: themeTextColor,
      );

    case dialogContentStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize,
        color: themeTextColor,
      );

    case colorSettingStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize,
        color: themeColor,
      );

    case imageSettingStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize,
        color: buttonTextColor,
      );

    // Signals
    case joinedStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize * 1.5,
        color: joinedTextColor,
      );

    case watchingStyle:
      return TextStyle(
        fontFamily: currFontFamily,
        fontSize: currSize * 1.5,
        color: watchingTextColor,
      );

    // Debug
    case errorStyle:
    default:
      return TextStyle(
        fontSize: 48,
        color: Colors.red,
      );
  }
}

// Aliases
const String sora = 'Sora';
const String hahmlet = 'Hahmlet';
const String jetbrains_mono = 'JetBrains Mono';
const String andada_pro = 'Andada Pro';
const String epilogue = 'Epilogue';
const String inter = 'Inter';
const String encode_sans = 'Encode Sans';
const String manrope = 'Manrope';
const String lora = 'Lora';
const String biorhyme = 'BioRhyme';
const String playfair = 'Playfair Display';
const String archivo = 'Archivo';
const String roboto = 'Roboto';
const String cormorant = 'Cormorant';
const String spectral = 'Spectral';
const String raleway = 'Raleway';
const String work_sans = 'Work Sans';
const String lato = 'Lato';
const String anton = 'Anton';
const String old_standard = 'Old Standard TT';

// Top 20 most commonly used Google Fonts according to a random medium article in Sept 2022
const List<String> myGoogleFonts = [
  sora,
  hahmlet,
  jetbrains_mono,
  andada_pro,
  epilogue,
  inter,
  encode_sans,
  manrope,
  lora,
  biorhyme,
  playfair,
  archivo,
  roboto,
  cormorant,
  spectral,
  raleway,
  work_sans,
  lato,
  anton,
  old_standard,
];

// Google Getter
TextStyle googleStyleAlias(String fontName) {
  switch (fontName) {
    case sora:
      return GoogleFonts.sora();

    case hahmlet:
      return GoogleFonts.hahmlet();

    case jetbrains_mono:
      return GoogleFonts.jetBrainsMono();

    case andada_pro:
      return GoogleFonts.andadaPro();

    case epilogue:
      return GoogleFonts.epilogue();

    case inter:
      return GoogleFonts.inter();

    case encode_sans:
      return GoogleFonts.encodeSans();

    case manrope:
      return GoogleFonts.manrope();

    case lora:
      return GoogleFonts.lora();

    case biorhyme:
      return GoogleFonts.bioRhyme();

    case playfair:
      return GoogleFonts.playfairDisplay();

    case archivo:
      return GoogleFonts.archivo();

    case roboto:
      return GoogleFonts.roboto();

    case cormorant:
      return GoogleFonts.cormorant();

    case spectral:
      return GoogleFonts.spectral();

    case raleway:
      return GoogleFonts.raleway();

    case work_sans:
      return GoogleFonts.workSans();

    case lato:
      return GoogleFonts.lato();

    case anton:
      return GoogleFonts.anton();

    case old_standard:
      return GoogleFonts.oldStandardTt();

    case errorStyle:
    default:
      return TextStyle(
        fontSize: 48,
        color: Colors.red,
      );
  }
}
