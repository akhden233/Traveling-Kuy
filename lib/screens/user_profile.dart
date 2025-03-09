import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'signin_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _profileImagePath;

  // ValueNotifier untuk update gambar di halaman lain
  static final ValueNotifier<String?> profileImageNotifier = ValueNotifier(
    null,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  void _loadUserData() {
    _nameController.text = widget.userName;
    _emailController.text = widget.userEmail;
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Cek apakah widget masih ada sebelum update state
    setState(() {
      _profileImagePath = prefs.getString('profileImage');
      profileImageNotifier.value = _profileImagePath;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', pickedFile.path);

      if (!mounted) return; // Cek apakah widget masih ada sebelum update state
      setState(() {
        _profileImagePath = pickedFile.path;
        profileImageNotifier.value =
            pickedFile.path; // Perbarui foto di homepage
      });
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userEmail', _emailController.text);

    if (!mounted) {
      return; // Cek apakah widget masih ada sebelum menampilkan SnackBar
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return; // Cek apakah widget masih ada sebelum navigasi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Foto Profil (Bisa Diklik untuk Ganti)
              GestureDetector(
                onTap: _pickImage,
                child: ValueListenableBuilder<String?>(
                  valueListenable: profileImageNotifier,
                  builder: (context, profileImage, child) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Color.fromRGBO(47, 73, 44, 1),
                      backgroundImage:
                          profileImage != null
                              ? FileImage(File(profileImage))
                              : null,
                      child:
                          profileImage == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                              : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20), // Add padding for spacing
              // Form Ganti Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20), // Add padding for spacing
              // Form Ganti Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20), // Add padding for spacing
              // Form Ganti Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "New Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30), // Add padding for spacing
              // Tombol Update Profile
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(47, 73, 44, 1),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add padding for spacing
              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
