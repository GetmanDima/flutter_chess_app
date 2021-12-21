import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/drawer.dart';
import 'package:flutter_chess/server.dart';


enum GameColor { white, black }
var buttonNumberToTimeMode = [
  '1 + 0', '2 + 0', '3 + 0',
  '4 + 0', '5 + 0', '6 + 0',
  '7 + 0', '8 + 0', '9 + 0' 
];

class ApplicationCreateScreen extends StatelessWidget {
  const ApplicationCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Создать заявку")),
      body: const ApplicationCreateWidget(),
      drawer: getDrawer(context),
    );
  }
}

class ApplicationCreateWidget extends StatefulWidget {
  const ApplicationCreateWidget({Key? key}) : super(key: key);

  @override
  State<ApplicationCreateWidget> createState() => _ApplicationCreateWidgetState();
}

class _ApplicationCreateWidgetState extends State<ApplicationCreateWidget> {
  int chosenTimeButtonNumber = 0;
  GameColor? chosenColor = GameColor.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Table(
          children: [
            TableRow(
              children: [
                getTimeButton(0),
                getTimeButton(1),
                getTimeButton(2),
              ]
            ),
            TableRow(
              children: [
                getTimeButton(3),
                getTimeButton(4),
                getTimeButton(5),
              ]
            ),
            TableRow(
              children: [
                getTimeButton(6),
                getTimeButton(7),
                getTimeButton(8),
              ]
            )
          ],
        ),
        Row (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container (
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.4,
                    child: Radio<GameColor>(
                      value: GameColor.white,
                      groupValue: chosenColor,
                      onChanged: (GameColor? value) {
                        setState(() {
                          chosenColor = value;
                        });
                      },
                    ),
                  ),
                  const Text('Белый', style: TextStyle(fontSize: 18))
                ],
              ),
              padding: const EdgeInsets.only(top: 20),
              width: 140,
            ),
          
            Container(
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.4,
                    child: Radio<GameColor>(
                      value: GameColor.black,
                      groupValue: chosenColor,
                      onChanged: (GameColor? value) {
                        setState(() {
                          chosenColor = value;
                        });
                      },
                    ),
                  ),
                  const Text('Черный', style: TextStyle(fontSize: 18))
                ],
              ),
              padding: const EdgeInsets.only(top: 20),
              width: 120,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: ElevatedButton(
            child: const Text("Создать"),
            onPressed: () {
              createApplication(
                buttonNumberToTimeMode[chosenTimeButtonNumber], 
                chosenColor == GameColor.white ? 'white': 'black'
              ).then(
                (res) {
                  _showAlert(context);
                }
              );
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              textStyle: const TextStyle(fontSize: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            )
          )
        )
      ]
    );
  }

  Padding getTimeButton(int number) {
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.blue,
            textStyle: const TextStyle(fontSize: 20),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
          );

    if (chosenTimeButtonNumber == number) {
      buttonStyle = ElevatedButton.styleFrom(
            primary: Colors.blue,
            onPrimary: Colors.white,
            textStyle: const TextStyle(fontSize: 20),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
          );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
          child: Text(buttonNumberToTimeMode[number]),
          onPressed: () {
            setState(() {
              chosenTimeButtonNumber = number;
            });
          },
          style: buttonStyle
        )
    );
  }

  _showAlert(context) {
    Alert(
      context: context,
      title: "You created application",
      desc: "Game with time mode ${buttonNumberToTimeMode[chosenTimeButtonNumber]} and color ${chosenColor == GameColor.white ? 'white': 'black'}",
      buttons: [
        DialogButton(
          child: const Text(
            "Show my applications",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/applications/personal',
            );
          }
        ),
      ],
    ).show();
  }
}