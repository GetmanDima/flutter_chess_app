import 'dart:async';
import 'dart:convert';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/drawer.dart';
import 'package:flutter_chess/server.dart';
import 'package:flutter_chess/models.dart';

bool showPersonalApplications = false;
Timer? applicationsUpdateTimer;

class ApplicationListScreen extends StatelessWidget {
  ApplicationListScreen({Key? key, bool personalApplications = false}) : super(key: key) {
    showPersonalApplications = personalApplications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(showPersonalApplications ? "Мои заявки" : "Заявки")),
      body: const ApplicationListWidget(),
      drawer: getDrawer(context),
    );
  }
}

class ApplicationListWidget extends StatefulWidget {
  const ApplicationListWidget({Key? key}) : super(key: key);

  @override
  State<ApplicationListWidget> createState() => _ApplicationListWidgetState();
}

class _ApplicationListWidgetState extends State<ApplicationListWidget> {
  List<Application> applications = [];

  @override
  void initState() {
    if (applicationsUpdateTimer != null) {
      applicationsUpdateTimer!.cancel();
    }

    applicationsUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        getApplications(isPersonal: showPersonalApplications).then((res) {
          setState(() {
            applications = res;
          });
        }
      );
    });

    getApplications(isPersonal: showPersonalApplications).then((res) {
        setState(() {
          applications = res;
        });
      }
    );

    super.initState();
  }

  @override
  void dispose() {
    if (applicationsUpdateTimer != null) {
     applicationsUpdateTimer!.cancel();
    }
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Widget listViewHeader;

    if (showPersonalApplications) {
      listViewHeader = Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Container(), flex: 1),
            Expanded(child: Image.asset('assets/created.png', height: 30), flex: 2),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 0, left: 50),
              child: Image.asset('assets/time.png', height: 30),
            ), flex: 5),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(right: 0, left: 10),
              child: Image.asset('assets/color.png', height: 30),
            ), flex: 3),
            Expanded(child: Image.asset('assets/delete.png', height: 30), flex: 5)
          ]
        )
      );
    } else {
      listViewHeader = Padding(
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
            ), flex: 5),
            Expanded(child: Image.asset('assets/color.png', height: 30), flex: 3),
            Expanded(child: Image.asset('assets/handshake.png', height: 30), flex: 5)
          ]
        )
      );
    }

    List<Widget> listViewContent = [listViewHeader];

    if (showPersonalApplications) {
      listViewContent.addAll(
        applications.map((application) => personalApplicationCard(application)).toList().reversed
      );
    } else {
      listViewContent.addAll(
        applications.map((application) => applicationCard(application)).toList().reversed
      );
    }

    return ListView(children: listViewContent);
  }

  Widget applicationCard(Application application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(application.author.username, style: const TextStyle(fontSize: 24)), flex: 6),
            Expanded(child: Text(application.timeMode, style: const TextStyle(fontSize: 20)), flex: 4),
            Expanded(
              child: application.color == 'white' ? Image.asset('assets/color_black.png', height: 30) : Image.asset('assets/color_white.png', height: 30)
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ElevatedButton(
                  child: const Text("Accept", style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    acceptApplication(application.id).then((res) {
                      var json = jsonDecode(res.body);
                      if (json['accept'] == true) {
                        var game = Game.fromJson(json['game']);

                        Navigator.pushReplacementNamed(
                          context,
                          '/game',
                          arguments: GameRouteArguments(game: game)
                        );
                      }
                    });
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
    );
  }

  Widget personalApplicationCard(Application application) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: Text(application.createdDate, style: const TextStyle(fontSize: 20)), flex: 4),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(application.timeMode, style: const TextStyle(fontSize: 20)),
            ), flex: 4),
            Expanded(
              child: application.color == 'white' ? Image.asset('assets/color_white.png', height: 30) : Image.asset('assets/color_black.png', height: 30)
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: ElevatedButton(
                  child: const Text("Delete"),
                  onPressed: () {
                    _showAlert(context, application).then((exit) {
                      if (exit != null && exit) {
                        setState(() {
                          applications.remove(application);
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
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
    );
  }

  Future<bool?> _showAlert(context, Application application) {
    return Alert(
      context: context,
      title: "Do you want to delete application",
      desc: "Game with time mode ${application.timeMode} and color ${application.color}",
      buttons: [
        DialogButton(
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            deleteApplication(application.id).then((res) {});
            return Navigator.pop(context, true);
          }
        ),
        DialogButton(
          child: const Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context, false)
        ),
      ],
    ).show();
  }
}