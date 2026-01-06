import 'package:flutter/foundation.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Auto-login for demo purposes
    _initializeDemoUser();
  }

  void _initializeDemoUser() {
    _user = User(
      id: 'demo-user-1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      avatarUrl: null,
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
      _user = User(
        id: 'user-${email.hashCode}',
        name: email.split('@')[0],
        email: email,
        avatarUrl: null,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Invalid credentials';
    }

    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful registration
      _user = User(
        id: 'user-${email.hashCode}',
        name: name,
        email: email,
        avatarUrl: null,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Registration failed';
    }

    notifyListeners();
  }

  Future<void> signOut() async {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
