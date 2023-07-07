import 'package:flutter/material.dart';
import 'package:golden_eye_draft/screens/details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

// import 'package:golden_eye_draft/screens/details_screen.dart';
// import 'package:golden_eye_draft/archive/web_screen.dart';
// import 'package:golden_eye_draft/archive/web_screen_two.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 63, 17, 177),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: GoogleFonts.latoTextTheme(),
);

// main.dart
void main() {
  WebViewPlatform.instance = WebWebViewPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // var screenSize = MediaQuery.of(context).size;
    // print(screenSize);
    return MaterialApp(
      title: 'Explore',
      theme: theme,
      home: const DetailsScreen(),
    );
  }
}