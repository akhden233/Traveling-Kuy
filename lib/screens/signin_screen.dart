import 'dart:convert';
import 'package:abp_travel/backend/utils/constants/constants_flutter.dart';
import 'package:flutter/material.dart';
import '../backend/routes/web/router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../backend/providers/auth_provider.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/homepage_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  SigninScreenState createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen> {
  bool isRememberMeChecked = false;
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Memuat email dan password yang tersimpan
  }

  // Memuat email dan password yang tersimpan
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('savedEmail') ?? '';
      passwordController.text = prefs.getString('savedPassword') ?? '';
      isRememberMeChecked = prefs.getBool('rememberMe') ?? false;
    });
  }

  // Menyimpan atau menghapus email dan password
  Future<void> _saveOrRemoveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isRememberMeChecked) {
      await prefs.setString('savedEmail', emailController.text);
      await prefs.setString('savedPassword', passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
      await prefs.setBool('rememberMe', false);
    }
  }

  void _login() async {
    print("LOGIN BUTTON PRESSED");

    

    if (!mounted) return; // Ensure widget is still mounted

    setState(() {
      isLoading = true; // Show loading indicator
    });

    String email = emailController.text;
    String pass = passwordController.text;

    try {
      // // untuk debug dari frontend
      // final response = await http.post(
      //   Uri.parse('$authEndpoint/login'),
      //   headers: {"Content-Type": "application/json"},
      //   body: jsonEncode({
      //     "email": emailController.text.trim(),
      //     "pass": passwordController.text.trim(),
      //   }),
      // );

      // print("STATUS: ${response.statusCode}");
      // print("BODY: ${response.body}");

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(email, pass);

      if (success && authProvider.user != null) {
        // save token ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (authProvider.user?.token != null) {
          await prefs.setString('token', authProvider.user!.token);
        } else {
          print('[WARNING] Token kosong! Tidak disimpan.');
        }

        // Save email & pass jika remember me aktif
        await _saveOrRemoveCredentials();

        if (!mounted) return;
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (context) => HomepageScreen(),
        //   ),
        // );

        final routerDelegate = Router.of(context).routerDelegate as MyRouteDelegate;
        routerDelegate.goToDashboard();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ??
                  "login gagal. Periksa kembali email dan password.",
            ),
          ),
        );
      }
    } catch (e) {
      print('[ERROR CAUGHT IN _login]: $e');
      if (!mounted) return;
      String errorMessage = "Terjadi error saat login";

      if (e.toString().contains('timeout')) {
        errorMessage =
            'Koneksi Timeout. Silahkan cek koneksi internet anda terlebih dahulu.';
      } else if (e.toString().contains('format')) {
        errorMessage = 'Format response tidak valid, Silahkan coba lagi';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Tidak dapat terhubung ke server.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      // }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  void _handleGoogleAuth() async {
    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.authGoogle();

      if (success && authProvider.user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomepageScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? "Login gagal.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login error. Try again")));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtain the router delegate from the current context
    final routerDelegate = Router.of(context).routerDelegate as MyRouteDelegate;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background_signin.png',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset('assets/signin.png', width: 150),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildInputField(
                        Icons.email,
                        "Email",
                        "Enter your email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 15),
                      buildInputField(
                        Icons.lock,
                        "Password",
                        "Enter your password",
                        obscureText: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isRememberMeChecked,
                                activeColor: Colors.blue,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    isRememberMeChecked = newValue!;
                                  });
                                },
                              ),
                              const Text("Remember me"),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (context) => const ForgotPasswordScreen(),
                              //   ),
                              // );

                              routerDelegate.goToForgotPassword();
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(47, 73, 44, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: isLoading ? null : _login,
                          child:
                              isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _handleGoogleAuth(),
                            child: Image.asset("assets/google.png", width: 30),
                          ),
                          const SizedBox(width: 20),
                          Image.asset("assets/apple.png", width: 30),
                          const SizedBox(width: 20),
                          Image.asset("assets/facebook.png", width: 30),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const SignupScreen(),
                          //   ),
                          // );

                          routerDelegate.goToSignUp();
                        },
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField(
    IconData icon,
    String label,
    String hint, {
    bool obscureText = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey[300],
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
