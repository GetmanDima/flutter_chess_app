import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/common.dart';

Drawer getDrawer(context) {
  String username = "";
  if (authorizedUser != null) {
    username = authorizedUser!.username;
  }

  return Drawer(
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          padding: EdgeInsets.fromLTRB(10.0, 20.0, 5.0, 5.0),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text("Пользователь: \n" + username, style: TextStyle(fontSize: 25)),
        ),
        TextButton(
          child: const Text('Создать заявку'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/application/create',
            );
          },
        ),
        TextButton(
          child: const Text('Заявки на игру'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/applications',
            );
          },
        ),
        TextButton(
          child: const Text('Мои заявки на игру'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/applications/personal',
            );
          },
        ),
        TextButton(
          child: const Text('Мои текущие игры'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/games',
            );
          },
        ),
        TextButton(
          child: const Text('Мои сыгранные игры'),
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              '/games/last',
            );
          },
        ),
      ],
    ),
  );
}