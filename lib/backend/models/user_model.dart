class User{
  final String uid;
  final String name;
  final String email;
  final String pass;

  User({
    required this.uid, 
    required this.name, 
    required this.email,
    required this.pass
    });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      uid: json['uid'], 
      name: json['name'], 
      email: json['email'],
      pass: json['pass'],
    );
  }
}