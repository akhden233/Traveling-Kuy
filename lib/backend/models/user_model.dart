class User{
  final int uid;
  final String name;
  final String email;
  final String pass;
  final String token;

  User({
    required this.uid, 
    required this.name, 
    required this.email,
    required this.pass,
    required this.token,
    });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      uid: json['uid'], 
      name: json['name'], 
      email: json['email'],
      pass: json['pass'],
      token: json['token'],
    );
  }
}