class Game {
  final int id;
  final User userWhite;
  final User userBlack;
  final Application application;
  final String createdDate;

  Game({
    required this.id,
    required this.userWhite,
    required this.userBlack,
    required this.application,
    required this.createdDate
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'], 
      userWhite: User.fromJson(json['user_white']),
      userBlack: User.fromJson(json['user_black']),
      application: Application.fromJson(json['application']),
      createdDate: json['created_date']
    );
  }
}

class Move {
  final int id;
  final String fen;

  Move({
    required this.id,
    required this.fen,
  });

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      id: json['id'], fen: json['fen']
    );
  }
}

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], username: json['username'], firstName: json['first_name'], lastName: json['last_name']
    );
  }
}

class Application {
  final int id;
  final User author;
  final String color;
  final String timeMode;
  final bool isActive;
  final String createdDate;

  Application({
    required this.id,
    required this.author,
    required this.color,
    required this.timeMode,
    required this.isActive,
    required this.createdDate
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'], author: User.fromJson(json['author']), color: json['color'], 
      timeMode: json['time_mode'], isActive: json['is_active'], 
      createdDate: json['created_date']
    );
  }
}

class GameRouteArguments {
  final Game game;

  GameRouteArguments({required this.game});
}