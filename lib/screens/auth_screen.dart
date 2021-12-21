import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess/common.dart';
import 'package:flutter_chess/server.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? username;
    String? password; 

    return Scaffold(
      appBar: AppBar(title: Text("$appTitle: Авторизация")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Username"),
                //keyboardType: TextInputType.emailAddress,
                onChanged: (val) => username = val,
              ),
              width: 300.0,
            ),
            Container(
              child: TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (val) => password = val,
              ),
              width: 300.0,
              padding: const EdgeInsets.only(top: 20.0),
            ),
            Container(
              child:
                ElevatedButton(
                  child: const Text("login"),
                  onPressed: () {
                    authUser(username, password).then((res) {
                      authToken = 'Token ' + jsonDecode(res.body)['auth_token'];

                      getAuthUser().then((user) {
                          authorizedUser = user;

                          Navigator.pushReplacementNamed(
                            context,
                            '/applications',
                          );
                        }
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
                  )
                ),
                padding: const EdgeInsets.only(top: 30.0),
            )
          ],
        ),
      ),
    );
  }
}
