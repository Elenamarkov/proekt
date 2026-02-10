import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _loggedInUserEmail;
  int? _loggedInUserId;
  String? _loggedInUserName;
  String? _token;

  bool get isLoggedIn => _loggedInUserEmail != null;
  String? get loggedInUserEmail => _loggedInUserEmail;
  int? get loggedInUserId => _loggedInUserId;
  String? get loggedInUserName => _loggedInUserName;
  String? get token => _token;

  Future<bool> register(String fullName, String email, String password,
      String? phoneNumber) async {
    try {
      final user = await ApiService.registerUser(UserRegistration(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      ));

      _loggedInUserEmail = user.email;
      _loggedInUserId = user.id;
      _loggedInUserName = user.fullName;
      _token = user.token;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.loginUser(email, password);

      _loggedInUserEmail = response['email'];
      _loggedInUserId = response['id'];
      _loggedInUserName = response['fullName'] ?? email.split('@')[0];
      _token = response['token'];

      notifyListeners();
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void demoLogin() {
    _loggedInUserEmail = 'demo@dreamscape.com';
    _loggedInUserId = 1;
    _loggedInUserName = 'Demo User';
    _token = 'demo-token';
    notifyListeners();
  }

  void logout() {
    _loggedInUserEmail = null;
    _loggedInUserId = null;
    _loggedInUserName = null;
    _token = null;
    notifyListeners();
  }
}
