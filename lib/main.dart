import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/screens/auth_screen.dart';
import 'package:flutter_chess/screens/game_screen.dart';
import 'package:flutter_chess/screens/game_list_screen.dart';
import 'package:flutter_chess/screens/application_create_screen.dart';
import 'package:flutter_chess/screens/application_list_screen.dart';
import 'package:flutter_chess/common.dart';

void main() => runApp(const ChessApp());

/// This is the main application widget.
class ChessApp extends StatelessWidget {
  const ChessApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      routes: {
        '/': (context) => const AuthScreen(),
        '/game': (context) => GameScreen(),
        '/games': (context) => GameListScreen(),
        '/games/last': (context) => GameListScreen(lastGames: true),
        '/application/create': (context) => const ApplicationCreateScreen(),
        '/applications': (context) => ApplicationListScreen(),
        '/applications/personal': (context) => ApplicationListScreen(personalApplications: true),
      },
    );
  }
}
