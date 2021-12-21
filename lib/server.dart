import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_chess/common.dart';
import 'package:flutter_chess/models.dart';

Future<http.Response> createApplication(String timeMode, String gameColor) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .post(
        Uri.parse(serverUrl + '/applications/'),
        headers: headers, 
        body: {'color': gameColor, 'timeMode': timeMode}
      );
  
  if (response.statusCode == 201) {
    return response;
  } else {
    throw Exception('Failed query: Code: ' + response.statusCode.toString());
  }
}

Future<List<Application>> getApplications({bool isPersonal = false}) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};
  String url = serverUrl + '/applications/';

  if (isPersonal) {
    url += '?personal=1';
  }

  final response = await http
      .get(
        Uri.parse(url),
        headers: headers, 
      );
  
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    return (json['applications'] as List).map((val) => Application.fromJson((val))).toList();
  } else {
    throw Exception('Failed query: Code: ' + response.statusCode.toString());
  }
}

Future<http.Response> acceptApplication(int id) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .post(
        Uri.parse(serverUrl + '/applications/$id/accept'), 
        headers: headers
      );
  
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed query');
  }
}

Future<http.Response> deleteApplication(int id) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .delete(
        Uri.parse(serverUrl + '/applications/$id/'), 
        headers: headers
      );
  
  if (response.statusCode == 204) {
    return response;
  } else {
    throw Exception('Failed query');
  }
}

Future<http.Response> authUser(String? username, String? password) async {
  print(serverUrl + '/auth/token/login/');
  final response = await http
      .post(
        Uri.parse(serverUrl + '/auth/token/login/'), 
        body: {"username": username, "password": password}
      );
  
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed auth');
  }
}

Future<User> getAuthUser() async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .post(
        Uri.parse(serverUrl + '/getAuthUser/'), 
        headers: headers
      );
  
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    return User.fromJson(json['user']);
  } else {
    throw Exception('Failed auth');
  }
}

Future<List<Game>> getGames({bool isLast = false}) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  String url = serverUrl + '/games/';

  if (isLast) {
    url += 'last/';
  } else {
    url += 'current/';
  }

  final response = await http
      .get(
        Uri.parse(url),
        headers: headers, 
      );
  
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    return (json['games'] as List).map((val) => Game.fromJson((val))).toList();
  } else {
    throw Exception('Failed query: Code: ' + response.statusCode.toString());
  }
}

Future<http.Response> sendMove(int gameId, String? fen) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .post(
        Uri.parse(serverUrl + '/games/$gameId/moves/'), 
        body: {"fen": fen},
        headers: headers
      );
  
  if (response.statusCode == 201) {
    return response;
  } else {
    throw Exception('Failed auth');
  }
}

Future<Map<String, dynamic>> getMoves(int gameId) async {
  Map<String, String> headers = {'Authorization': authToken ?? ''};

  final response = await http
      .get(
        Uri.parse(serverUrl + '/games/$gameId/moves/'), 
        headers: headers
      );
  
  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    return {
      "moves": (json['moves'] as List).map((val) => Move.fromJson((val))).toList(),
      "whiteTime": json["whiteTime"],
      "blackTime": json["blackTime"],
      "result": json["result"]
    };
  } else {
    throw Exception('Failed when get moves');
  }
}