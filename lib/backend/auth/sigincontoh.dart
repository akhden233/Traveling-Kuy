// class SignInGoogle() extends ChangeNotifier {
//     try {
//       final googleSignIn = GoogleSignIn();

//       GoogleSignInAccount? _user;

//       GoogleSignInAccount get user => _user;
      
//     } on TimeoutException {
//       _errorMessage = 'Timeout saat login dengan Google';
//       throw Exception(_errorMessage);
//     } on SocketException {
//       _errorMessage = 'Tidak bisa terhubung ke server';
//       throw Exception(_errorMessage);
//     } catch (e) {
//       _errorMessage = 'Login dengan Google gagal: $e';
//       throw Exception(_errorMessage);
//     }
//   }