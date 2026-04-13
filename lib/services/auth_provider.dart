import 'package:flutter/material.dart';
import 'package:pro_link/models/app_user.dart';
import 'package:pro_link/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<UserRole> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _apiService.login(email: email, password: password);
      return _currentUser!.role;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
