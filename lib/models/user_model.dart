class User{
  final String uid;
  final String name;
  final String email;

  User({required this.uid, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      uid: json['uid'], 
      name: json['name'], 
      email: json['email'],
    );
  }
}