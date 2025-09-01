import 'package:flutter/material.dart';

const brandNavy = Color(0xFF0F2136);
const cardNavy  = Color(0xFF152A40);
const brandGold = Color(0xFFFFC648);
const sidebarBg = Color(0xFFF2F2F2);
const textBody  = Color(0xFF2B2B2B);

ThemeData buildAdminTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: base.colorScheme.copyWith(
      primary: brandNavy,
      secondary: brandGold,
      surface: Colors.white,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: textBody,
      displayColor: textBody,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: textBody),
    ),
  );
}
