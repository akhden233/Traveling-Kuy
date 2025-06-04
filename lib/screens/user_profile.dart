import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/providers/userProfile_provider.dart';
import '../backend/utils/validators.dart';
import '../backend/providers/auth_provider.dart';
import '../backend/routes/web/router.dart';
import '../screens/homepage_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  String? _profileImageBase64;

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
    String? storedPhotoUrl = prefs.getString('photoUrl');
    print('DEBUG: Loaded photoUrl from SharedPreferences: $storedPhotoUrl');
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      setState(() {
        if (storedPhotoUrl != null && storedPhotoUrl.isNotEmpty) {
          _profileImageBase64 = storedPhotoUrl;
          profileImageNotifier.value = _profileImageBase64;
          print('DEBUG: profileImageNotifier updated with storedPhotoUrl');
        } else if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
          _profileImageBase64 = user.photoUrl;
          profileImageNotifier.value = user.photoUrl;
          print('DEBUG: profileImageNotifier updated with user.photoUrl');
        } else {
          _profileImageBase64 = null;
          print('DEBUG: No profile image found');
        }
      });
    } else {
      print('DEBUG: User is null in _loadUserData');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      if (!mounted) return; // Cek apakah widget ada sebelum update state

      Uint8List? imageBytes;

      if (kIsWeb) {
        // For web, read as bytes directly
        imageBytes = await pickedFile.readAsBytes();

        // Optionally, compress image on web using canvas or other methods
        // For simplicity, skipping compression on web here
      } else {
        // For mobile, compress image file
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          pickedFile.path,
          quality: 50,
        );

        if (compressedBytes == null) {
          print('[ERROR] Image compression failed');
          return;
        }
        imageBytes = compressedBytes;
      }

      final base64Image = base64Encode(imageBytes);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('photoUrl', base64Image);

      setState(() {
        _profileImageBase64 = base64Image;
        profileImageNotifier.value = base64Image; // Perbarui foto di homepage
      });
    }
  }

  Future<void> _updateProfile() async {
    final routerDelegate = Router.of(context).routerDelegate as MyRouteDelegate;

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
        photoUrl: profileImageNotifier.value,
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
      if (_profileImageBase64 != null) {
        prefs.setString('photoUrl', profileImageNotifier.value!);
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

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        photoUrl: _profileImageBase64,
      );

      await userProvider.loadUserFromStorage();
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomepageScreen()),
      // );
      routerDelegate.goToDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    final routerDelegate = Router.of(context).routerDelegate as MyRouteDelegate;

    final userProvider = Provider.of<UserprofileProvider>(
      context,
      listen: false,
    );
    await userProvider.clearUserData();

    if (!mounted) return; // Cek apakah widget masih ada sebelum navigasi
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SigninScreen()),
    // );
    routerDelegate.goToSignIn();
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
                      builder: (context, profileImageBase64, child) {
                            if (profileImageBase64 != null && profileImageBase64.isNotEmpty) {
                              try {
                                // Debug log base64 length and snippet
                                print('[DEBUG] profileImageBase64 length: \${profileImageBase64.length}');
                                print('[DEBUG] profileImageBase64 snippet: \${profileImageBase64.substring(0, 30)}');

                                // String base64Str = profileImageBase64;
                                // if (!profileImageBase64.startsWith('data:image')) {
                                //   final header = profileImageBase64.substring(0, 10).toLowerCase();
                                //   String format = 'png';
                                //   if (header.contains('jpeg') || header.contains('jpg')) {
                                //     format = 'jpeg';
                                //   } else if (header.contains('gif')) {
                                //     format = 'gif';
                                //   } else if (header.contains('bmp')) {
                                //     format = 'bmp';
                                //   } else if (header.contains('webp')) {
                                //     format = 'webp';
                                //   }
                                //   base64Str = 'data:image/\$format;base64,\$profileImageBase64';
                                // }
                                // final base64Data = base64Str.contains(',')
                                //     ? base64Str.split(',').last
                                //     : base64Str;


                                // String base642Decode = profileImageBase64;
                                // if (base642Decode.length > 10000) {
                                //   base642Decode = base642Decode.substring(0, 10000);
                                //   print('[DEBUG] Truncated base64');
                                // }
                                final decodeBytes = base64Decode(profileImageBase64);
                                return CircleAvatar(
                                  radius: 50,
                                  backgroundImage: MemoryImage(decodeBytes),
                                );
                              } catch (e) {
                                print('[ERROR] Failed to decode base64 image: \$e');
                                return _defaultProfileIcon();
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
