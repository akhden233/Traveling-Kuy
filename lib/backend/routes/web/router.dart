import 'package:flutter/material.dart';
import '../../../screens/travel_screen.dart';
import '../../../screens/homepage_screen.dart';
import '../../../screens/user_profile.dart';
import '../../../screens/signin_screen.dart';
import '../../../screens/signup_screen.dart';
import '../../../screens/forgot_password_screen.dart';
// import '../../../screens/payment_screen.dart';

class RoutePath {
  final String location;
  const RoutePath._(this.location);

  static const home = RoutePath._('/');
  static const dashboard = RoutePath._('/dashboard');
  static const login = RoutePath._('/login');
  static const register = RoutePath._('/register');
  static const forgotPassword = RoutePath._('/forgot-password');
  static const userProfile = RoutePath._('/user-profile');
  static const orderPayment = RoutePath._('/order-payment');

  bool get isHomePage => location == '/';
  bool get isDashboardPage => location == '/dashboard';
  bool get isLoginPage => location == '/login';
  bool get isRegisterPage => location == '/register';
  bool get isForgotPasswordPage => location == '/forgot-password';
  bool get isUserProfilePage => location == '/user-profile';
  bool get isOrderPaymentPage => location == '/order-payment';
}

class MyRouteInfoParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(RouteInformation routeInfo) async {
    final location = routeInfo.location ?? '/';
    print('[DEBUG] routeInfo.location: $location ');
    final uri = Uri.parse(location);
    if (uri.pathSegments.isEmpty) {
      return RoutePath.home;
    }
    switch (uri.pathSegments[0]) {
      case 'login':
        return RoutePath.login;
      case 'register':
        return RoutePath.register;
      case 'forgot password':
        return RoutePath.forgotPassword;
      case 'dashboard':
        return RoutePath.dashboard;
      case 'user-profile':
        return RoutePath.userProfile;
      // case 'order-payment':
      //   return RoutePath.orderPayment;
      default:
        return RoutePath.home;
    }
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePath config) {
    return RouteInformation(location: config.location);
  }
}

class MyRouteDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  RoutePath _currentPath = RoutePath.home;

  MyRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  RoutePath get currentConfiguration => _currentPath;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_currentPath.isHomePage)
          MaterialPage(child: TravelScreen(), key: ValueKey('TravelScreen')),
        if (_currentPath.isLoginPage)
          MaterialPage(child: SigninScreen(), key: ValueKey('SigninScreen')),
        if (_currentPath.isRegisterPage)
          MaterialPage(child: SignupScreen(), key: ValueKey('SignupScreens')),
        if (_currentPath.isForgotPasswordPage)
          MaterialPage(
            child: ForgotPasswordScreen(),
            key: ValueKey('ForgotPasswordSreen'),
          ),
        if (_currentPath.isDashboardPage)
          MaterialPage(
            child: HomepageScreen(),
            key: ValueKey('HomepageScreen'),
          ),
        if (_currentPath.isUserProfilePage)
          MaterialPage(
            child: UserProfileScreen(),
            key: ValueKey('UserProfileScreen'),
          ),
        // if (_currentPath.isOrderPaymentPage)
        //   MaterialPage(
        //     child: PaymentScreen(destination: destination, packageType: packageType, price: price, userId: userId),
        //     key: ValueKey('Order-Payment'),
        //   ),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _currentPath = RoutePath.home;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(RoutePath config) async {
    _currentPath = config;
  }

  void goToHome() {
    _currentPath = RoutePath.home;
    notifyListeners();
  }

  void goToSignIn() {
    _currentPath = RoutePath.login;
    notifyListeners();
  }

  void goToSignUp() {
    _currentPath = RoutePath.register;
    notifyListeners();
  }

  void goToForgotPassword() {
    _currentPath = RoutePath.forgotPassword;
    notifyListeners();
  }

  void goToDashboard() {
    _currentPath = RoutePath.dashboard;
    notifyListeners();
  }

  void goToUserProfile() {
    _currentPath = RoutePath.userProfile;
    notifyListeners();
  }

  // void goToOrderPayment() {
  //   _currentPath = RoutePath.orderPayment;
  //   notifyListeners();
  // }
}
