import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/common.dart';
import 'package:flutter_chess/drawer.dart';
import 'package:flutter_chess/server.dart';
import 'package:flutter_chess/models.dart';

bool showLastGames = false;
Timer? gamesUpdateTimer;

class GameListScreen extends StatelessWidget {
  GameListScreen({Key? key, bool lastGames = false}) : super(key: key) {
    showLastGames = lastGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(showLastGames ? "Сыгранные игры" : "Текущие игры")),
      body: const GameListWidget(),
      drawer: getDrawer(context),
    );
  }
}

class GameListWidget extends StatefulWidget {
  const GameListWidget({Key? key}) : super(key: key);

  @override
  State<GameListWidget> createState() => _GameListWidgetState();
}

class _GameListWidgetState extends State<GameListWidget> {
  List<Game> games = [];

  @override
  void initState() {
    if (gamesUpdateTimer != null) {
      gamesUpdateTimer!.cancel();
    }

    gamesUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        getGames(isLast: showLastGames).then((res) {
          setState(() {
            games = res;
          });
        }
      );
    });

    getGames(isLast: showLastGames).then((res) {
        setState(() {
          games = res;
        });
      }
    );

    super.initState();
  }

  @override
  void dispose() {
    if (gamesUpdateTimer != null) {
      gamesUpdateTimer!.cancel();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Widget listViewHeader = Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Image.asset('assets/user.png', height: 30), flex: 3),
          Expanded(child: Container(), flex: 3),
          Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Image.asset('assets/time.png', height: 30),
            ), 
            flex: 5
          ),
          Expanded(child: Image.asset('assets/color.png', height: 30), flex: 3),
          Expanded(child: Image.asset(showLastGames ? 'assets/eye.png' : 'assets/swords.png', height: 30), flex: 5)
        ]
      )
    );

    List<Widget> listViewContent = [listViewHeader];

    listViewContent.addAll(
      games.map((game) => 
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(game.userWhite.id == authorizedUser!.id ? game.userBlack.username : game.userWhite.username, style: const TextStyle(fontSize: 24)), 
                  flex: 6
                ),
                Expanded(child: Text(game.application.timeMode, style: const TextStyle(fontSize: 20)), flex: 4),
                Expanded(
                  child: game.userWhite.id == authorizedUser!.id ? Image.asset('assets/color_white.png', height: 30) : Image.asset('assets/color_black.png', height: 30)
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      child: Text(showLastGames == true ? "Показать" : "Играть", style: TextStyle(fontSize: 12),),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/game',
                          arguments: GameRouteArguments(game: game)
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        textStyle: const TextStyle(fontSize: 20),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
                      )
                    ),
                  ),
                  flex: 5
                ),
              ],
            )
          ),
        ),
      ).toList().reversed
    );
    
    return ListView(
      children: listViewContent
    );
  }
}