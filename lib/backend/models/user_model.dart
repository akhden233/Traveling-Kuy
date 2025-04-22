class User{
  final int uid;
  final String? firebase_id;
  final String name;
  final String email;
  final String token;
  final String? photoUrl;

  User({
    required this.uid,
    this.firebase_id,
    required this.name, 
    required this.email,
    required this.token,
    this.photoUrl,
    });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      uid: json['uid'],
      firebase_id: json['firebase_id'], 
      name: json['name'] ?? '', 
      email: json['email'],
      token: json['token'],
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  // @override
  Map<String, dynamic> toJson() {
    return{
      'uid': uid,
      'firebase_id': firebase_id,
      'name' : name,
      'email' : email,
      'token' : token,
      'photoUrl' : photoUrl,
    };
  }

  // untuk updateData
  User copyWith({
    int? uid,
    String? firebase_id,
    String? name,
    String? email,
    String? token,
    String? photoUrl,
  }) {
    return User(
      uid: uid ?? this.uid, 
      firebase_id: firebase_id ?? this.firebase_id,
      name: name ?? this.name, 
      email: email ?? this.email, 
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}