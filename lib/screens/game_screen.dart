import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_chess/game/desk.dart';
import 'package:flutter_chess/game/figure.dart';
import 'package:flutter_chess/drawer.dart';
import 'package:flutter_chess/common.dart';
import 'package:flutter_chess/server.dart';
import 'package:flutter_chess/models.dart';
//import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math';

Timer? positionUpdateTimer;
Timer? timeUpdateTimer;
late GameRouteArguments routeArguments;
bool reversedDesk = false;
typedef timeCallback = void Function(Color color);
var deviceSize = window.physicalSize / window.devicePixelRatio;
late List<Move> gameMoves;
late int endGameMoveNumber;
double deviceWidth = min(350, deviceSize.width);
bool isEndGame = false;

class GameScreen extends StatelessWidget {
  GameScreen({Key? key}) : super(key: key) {
    print("deviceWidth");
    print(deviceWidth);
  }

  @override
  Widget build(BuildContext context) {
    //deviceWidth = MediaQuery.of(context).size.width;
    print("device width 2");
    print(MediaQuery.of(context).size.width);
    routeArguments = ModalRoute.of(context)!.settings.arguments as GameRouteArguments;

    return Scaffold(
      appBar: AppBar(title: Text(appTitle)),
      body: const GameWidget(),
      drawer: getDrawer(context),
    );
  }
}


class GameWidget extends StatefulWidget {
  const GameWidget({Key? key}) : super(key: key);

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late Duration timeUser;
  late Duration timeOpponent;
  late String currentUserColor;
  late String opponentUserColor;
  late User opponentUser;
  late var board;
  int? resultGame;

  void setBoard() {
    setState(() {
      board = Desk.position;
    });
  }

  void setAllState(Duration whiteTime, Duration blackTime) {
    setState(() {
      board = Desk.position;
      if (currentUserColor == "white") {
        timeUser = whiteTime;
        timeOpponent = blackTime;
      } else {
        timeUser = blackTime;
        timeOpponent = whiteTime;
      }
    });
  }

  void setTime(Duration whiteTime, Duration blackTime) {
    if (currentUserColor == "white") {
      setState(() {
        timeUser = whiteTime;
        timeOpponent = blackTime;
      });
    } else {
      setState(() {
        timeUser = blackTime;
        timeOpponent = whiteTime;
      });
    }
  }

  @override
  void initState() {
    String timeMode = routeArguments.game.application.timeMode;
    List<String> timeArr = timeMode.split(" + ");
    int minutes = int.parse(timeArr.first);
    int seconds = int.parse(timeArr.last);
    Duration startTime = Duration(minutes: minutes);

    if (authorizedUser!.username == routeArguments.game.userWhite.username) {
      currentUserColor = "white";
      opponentUserColor = "black";
      opponentUser = routeArguments.game.userBlack;
      reversedDesk = false;
    } else {
      currentUserColor = "black";
      opponentUserColor = "white";
      opponentUser = routeArguments.game.userWhite;
      reversedDesk = true;
    }

    Desk.initialize();
    Desk.halfMoveNumber = 1;

    if (routeArguments.game.userWhite.id == authorizedUser!.id) {
      Desk.userColor = 'w';
    } else {
      Desk.userColor = 'b';
    }
    
    if (positionUpdateTimer != null) {
      positionUpdateTimer!.cancel();
    }

    int gameId = routeArguments.game.id;

    getMoves(gameId).then((res) {   
      List<Move> moves = res["moves"] as List<Move>;
      int? result = res["result"];

      if (moves.isNotEmpty) {
        if (moves.last.fen != Desk.positionToFen()) {
          Desk.loadPositionFromFen(moves.last.fen);
          Desk.halfMoveNumber = moves.last.id - moves.first.id + 2;

          Duration whiteTime = Duration(seconds: res["whiteTime"] as int);
          Duration blackTime = Duration(seconds: res["blackTime"] as int);

          if (result != null) {
            gameMoves = moves;
            endGameMoveNumber = moves.length - 1;
            isEndGame = true;
          }
          setState(() {
              resultGame = result;
              board = Desk.position;
              if (currentUserColor == "white") {
                timeUser = whiteTime;
                timeOpponent = blackTime;
              } else {
                timeUser = blackTime;
                timeOpponent = whiteTime;
              }
            });
        }
      }

      positionUpdateTimer = Timer.periodic(const Duration(seconds: secondsForUpdatePosition), (timer) {
        if (!isEndGame) {
          getMoves(gameId).then((res) {   
          List<Move> moves = res["moves"] as List<Move>;

          if (moves.isNotEmpty) {
            if (moves.last.fen != Desk.positionToFen()) {
              int? result = res["result"];
              Desk.loadPositionFromFen(moves.last.fen);
              Desk.halfMoveNumber = moves.last.id - moves.first.id + 2;

              Duration whiteTime = Duration(seconds: res["whiteTime"] as int);
              Duration blackTime = Duration(seconds: res["blackTime"] as int);

              if (result != null) {
                gameMoves = moves;
                endGameMoveNumber = moves.length - 1;
                isEndGame = true;
                timer.cancel();
              }

              setState(() {
                resultGame = result;
                board = Desk.position;
                if (currentUserColor == "white") {
                  timeUser = whiteTime;
                  timeOpponent = blackTime;
                } else {
                  timeUser = blackTime;
                  timeOpponent = whiteTime;
                }
              });
            }
          }
        });
        }
      });
    });

    timeUpdateTimer = Timer.periodic(const Duration(seconds: secondsForUpdatePosition), (timer) {
      print(Desk.halfMoveNumber);
      if (currentUserColor == Desk.getCurrentMoveColor()) {
        setState(() {
          timeUser = Duration(seconds: max(0, timeUser.inSeconds - 1));
        });
      } else {
        setState(() {
          timeOpponent = Duration(seconds: max(0, timeOpponent.inSeconds - 1));
        });
      }
    });

    setAllState(startTime, startTime);
    super.initState();
  }

  @override
  void dispose() {
    if (positionUpdateTimer != null) {
      positionUpdateTimer!.cancel();
    }

    if (timeUpdateTimer != null) {
      timeUpdateTimer!.cancel();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UserGamePanel(user: opponentUser.username, color: opponentUserColor, time: timeOpponent, resultGame: resultGame, setBoardState: setBoard,),
        BoardWidget(setTimeState: setTime, setBoardState: setBoard, setAllGameState: setAllState, resultGame: resultGame),
        UserGamePanel(user: authorizedUser!.username, color: currentUserColor, time: timeUser, resultGame: resultGame, setBoardState: setBoard,),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: ElevatedButton(
                child: const Text("Сдаться"),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15)
                )
              ),
            ),
          ],
        )
      ],
    );
  }
}

class UserGamePanel extends StatelessWidget {
  final String user;
  final String color;
  final Duration time;
  final int? resultGame;
  final Function setBoardState;

  const UserGamePanel({Key? key, required this.user, required this.color, required this.time, required this.resultGame, required this.setBoardState}): super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Widget rightWidget;

    if (resultGame == null) {
      rightWidget = TimeWidget(time: time);
    } else {
      String text;

      if (resultGame == 1) {
        if (color == "white") {
          text = "1";
        } else {
          text = "0";
        }
      } else if (resultGame == -1) {
        if (color == "white") {
          text = "0";
        } else {
          text = "1";
        }
      } else {
        text = "1/2";
      }

      rightWidget = Row(
        children: [
          ElevatedButton(
            child: const Text("<"),
            onPressed: () {
              if (endGameMoveNumber > 0) {
                endGameMoveNumber--;
                Desk.loadPositionFromFen(gameMoves[endGameMoveNumber].fen);
                setBoardState();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15)
            )
          ),

          ElevatedButton(
            child: const Text(">"),
            onPressed: () {
              if (endGameMoveNumber < gameMoves.length - 1) {
                endGameMoveNumber++;
                Desk.loadPositionFromFen(gameMoves[endGameMoveNumber].fen);
                setBoardState();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15)
            )
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(text, style: const TextStyle(fontSize: 24)),
          )
        ],
      );
    }

    return SizedBox(
      width: deviceWidth,
      child: Card(
        color: Colors.white38,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(color, style: const TextStyle(fontSize: 20)), flex: 2),
              Expanded(child: Text(user, style: const TextStyle(fontSize: 20)), flex: 4),
              Expanded(child: rightWidget, flex: resultGame == null ? 2 : 5),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeWidget extends StatelessWidget {
  final Duration time;

  const TimeWidget({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String minutesStr = time.inMinutes.remainder(60).toString().padLeft(2, "0");
    String secondsStr = time.inSeconds.remainder(60).toString().padLeft(2, "0");
    
    return Text(
      "$minutesStr:$secondsStr", 
      style: const TextStyle(fontSize: 24)
    );
  }
}

class BoardWidget extends StatelessWidget {
  List<TableRow> board = [];
  final Function setTimeState;
  final Function setBoardState;
  final Function setAllGameState;
  final int? resultGame;

  BoardWidget({Key? key, required this.setTimeState, required this.setBoardState, required this.setAllGameState, required this.resultGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //deviceWidth = MediaQuery.of(context).size.width;
    setBoard(context);
    print("device width 3");

    String imgPath = 'assets/desk_white.png';
    if (reversedDesk) {
      imgPath = 'assets/desk_black.png';
    }
    print(deviceWidth);
    
    return Container(
        child: Padding(
            child: Table(children: board),
            padding: EdgeInsets.fromLTRB(deviceWidth / 20, deviceWidth / 20,
                deviceWidth / 23, deviceWidth / 20)
            ),
        height: deviceWidth,
        width: deviceWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imgPath),
            fit: BoxFit.contain,
          ),
        )
      );
  }

  void setBoard(BuildContext context) {
    board = [];

    for (int x = 0; x < 8; x++) {
      List<Widget>? row = [];

      for (int y = 0; y < 8; y++) {
        Figure? figure;

        if (reversedDesk) {
          figure = Desk.position[7-x][7-y];
        } else {
          figure = Desk.position[x][y];
        }

        row.add(squareWidget(context, x, y, figure, setTimeState, setBoardState));
      }

      board.add(TableRow(children: row));
    }
  }

  Widget squareWidget(BuildContext context, int row, int col, Figure? figure, Function setTimeState, Function setBoardState) {
    print(Desk.position);
    print(Desk.position);
    return DragTarget<Figure>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        if (figure == null) {
          return Container(
              width: deviceWidth / 8.8,
              height: deviceWidth / 8.8,
              );
        }

        return Container(
            width: deviceWidth / 8.8,
            height: deviceWidth / 8.8,
            child: figureWidget(context, figure));
      },
      onAccept: (Figure acceptedFigure) {
        if (!isEndGame) {
          bool moveCheckStatus;
          
          if (reversedDesk) {
            moveCheckStatus = Desk.move(acceptedFigure.row, acceptedFigure.col, 7 - row, 7 - col);
          } else {
            moveCheckStatus = Desk.move(acceptedFigure.row, acceptedFigure.col, row, col);
          }

          if (moveCheckStatus) {
            sendMove(routeArguments.game.id, Desk.positionToFen()).then((res) {
              var data = jsonDecode(res.body);
              Duration whiteTime = Duration(seconds: data["whiteTime"]);
              Duration blackTime = Duration(seconds: data["blackTime"]);
              setAllGameState(whiteTime, blackTime);
            });
          }
        }
      },
    );
  }

  Widget figureWidget(BuildContext context, Figure figure) {
    var figureImages = {
      'p': 'pawn.svg',
      'r': 'rook.svg',
      'n': 'knight.svg',
      'b': 'bishop.svg',
      'k': 'king.svg',
      'q': 'queen.svg',
    };

    var imageSrc = 'assets/' + (figureImages[figure.symbol] ?? '');
    var image = SvgPicture.asset(imageSrc);

    if (figure.color == 'b') {
      image = SvgPicture.asset(imageSrc, color: Colors.black);
    }

    return Draggable<Figure>(
      data: figure,
      child: image,
      feedback: SizedBox(
        child: image,
      ),
      childWhenDragging: Container(),
    );
  }
}