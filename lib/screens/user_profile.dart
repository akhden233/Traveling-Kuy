import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/providers/userProfile_provider.dart';
import '../backend/utils/validators.dart';
import '../screens/homepage_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'signin_screen.dart';

// ValueNotifier untuk update gambar di halaman lain
ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(null);

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserprofileProvider>(
      context,
      listen: false,
    );
    await userProvider.loadUserFromStorage(); // load data dari local
    final user = userProvider.user;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedProfileImage = prefs.getString('profileImage');
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      setState(() {
        if (storedProfileImage != null) {
          _profileImageFile = File(storedProfileImage);
        } else if (user.photoUrl != null) {
          _profileImageFile = File(user.photoUrl!);
        } else {
          _profileImageFile = null;
        }
        profileImageNotifier.value = storedProfileImage;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (!mounted) return; // Cek apakah widget masih ada sebelum update state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileImageFile = File(pickedFile.path);
        profileImageNotifier.value =
            pickedFile.path; // Perbarui foto di homepage
      });
      await prefs.setString('profileImage', pickedFile.path);
    }
  }

  Future<void> _updateProfile() async {
    final userProvider = Provider.of<UserprofileProvider>(
      context,
      listen: false,
    );

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Update profile di backend atau local storage
      await userProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _profileImageFile,
        currentPassword:
            _currentPasswordController.text.isNotEmpty
                ? _currentPasswordController.text
                : null,
        newPassword:
            _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
      );

      // Simpan ke SharedPreferences jika perlu
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', _nameController.text.trim());
      prefs.setString('userEmail', _emailController.text.trim());
      if (_profileImageFile != null) {
        prefs.setString('profileImage', _profileImageFile!.path);
      }

      // Pastikan state di-refresh
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya atau update UI
      setState(() {
        // Memastikan state terbaru ditampilkan
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomepageScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    final userProvider = Provider.of<UserprofileProvider>(
      context,
      listen: false,
    );
    await userProvider.clearUserData();

    if (!mounted) return; // Cek apakah widget masih ada sebelum navigasi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Call provider
    final userProvider = Provider.of<UserprofileProvider>(
      context,
      listen: true,
    );

    return WillPopScope(
      onWillPop: () async {
        // Save data before going back to the previous screen
        if (_formKey.currentState?.validate() ?? false) {
          await _updateProfile();
        }
        return true; // Allow back action
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Foto Profil (Bisa Diklik untuk Ganti)
                  GestureDetector(
                    onTap: _pickImage,
                    child: ValueListenableBuilder<String?>(
                      valueListenable: profileImageNotifier,
                      builder: (context, profileImage, child) {
                        if (_profileImageFile != null &&
                            _profileImageFile!.existsSync()) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(_profileImageFile!),
                          );
                        } else if (profileImage != null) {
                          if (Uri.parse(profileImage).isAbsolute) {
                            // Kalau URL
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(profileImage),
                            );
                          } else if (File(profileImage).existsSync()) {
                            // Kalau path lokal
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(File(profileImage)),
                            );
                          } else {
                            // **Kalau Base64**
                            try {
                              final decodedBytes = base64Decode(profileImage);
                              return CircleAvatar(
                                radius: 50,
                                backgroundImage: MemoryImage(decodedBytes),
                              );
                            } catch (e) {
                              // Kalau gagal decode, tampilkan icon default
                              return _defaultProfileIcon();
                            }
                          }
                        } else if (userProvider.user?.photoUrl != null) {
                          if (Uri.parse(
                            userProvider.user!.photoUrl!,
                          ).isAbsolute) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                userProvider.user!.photoUrl!,
                              ),
                            );
                          } else if (File(
                            userProvider.user!.photoUrl!,
                          ).existsSync()) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(
                                File(userProvider.user!.photoUrl!),
                              ),
                            );
                          } else {
                            try {
                              final decodedBytes = base64Decode(
                                userProvider.user!.photoUrl!,
                              );
                              return CircleAvatar(
                                radius: 50,
                                backgroundImage: MemoryImage(decodedBytes),
                              );
                            } catch (e) {
                              return _defaultProfileIcon();
                            }
                          }
                        }
                        return _defaultProfileIcon();
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name cannot be empty';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!Validators.isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20), // Add padding for spacing
                  // Form current Password
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      prefixIcon: const Icon(Icons.password_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    validator: (value) {
                      if (_passwordController.text.isNotEmpty) {
                        if (value != null && value.isEmpty) {
                          return 'Masukkan current Password untuk Update Profile';
                        }
                        if (value != null &&
                            !Validators.isValidPassword(value)) {
                          return 'Password minimal 8 karakter';
                        }
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !Validators.isValidPassword(value)) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
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
        ),
      ),
    );
  }
}

Widget _defaultProfileIcon() {
  return const CircleAvatar(
    radius: 50,
    backgroundColor: Color.fromRGBO(47, 73, 44, 1),
    child: Icon(Icons.person, size: 50, color: Colors.white),
  );
}
