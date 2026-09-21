import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/user_entity.dart';

/// State controller for authentication and user session
class AuthController extends ChangeNotifier {
  static AuthController of(BuildContext context) => AuthProvider.of(context);

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController() {
    _initSession();
  }

  UserEntity? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get hasAcceptedTerms => _currentUser?.hasAcceptedTerms ?? false;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initSession() async {
    _currentUser = await SessionService.instance.getUser();
    notifyListeners();

    // Verify token with backend
    if (_currentUser != null) {
      try {
        final me = await ApiService.instance.getMe();
        if (me != null) {
          _currentUser = me;
          notifyListeners();
        } else {
          _currentUser = null;
          await SessionService.instance.clearSession();
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  /// Register user
  Future<bool> register({
    required String email,
    required String password,
    required String rePassword,
    String? imagePath,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final res = await ApiService.instance.register(
        email: email,
        password: password,
        rePassword: rePassword,
        imagePath: imagePath,
        imageBytes: imageBytes,
        imageName: imageName,
      );

      _currentUser = res['user'] as UserEntity;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final res = await ApiService.instance.login(
        email: email,
        password: password,
      );

      _currentUser = res['user'] as UserEntity;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  /// Accept terms and conditions (with optional captured evidence screenshot)
  Future<bool> acceptTerms({Uint8List? imageBytes}) async {
    _setLoading(true);
    try {
      final updated = await ApiService.instance.acceptTerms(imageBytes: imageBytes);
      _currentUser = updated;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await SessionService.instance.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  /// Delete Account and wipe user data (Google Play Account Deletion compliance)
  Future<bool> deleteAccount() async {
    _setLoading(true);
    bool success = false;
    try {
      success = await ApiService.instance.deleteAccount();
    } catch (_) {
      await SessionService.instance.clearSession();
      success = true;
    }
    _currentUser = null;
    _setLoading(false);
    notifyListeners();
    return success;
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

/// Provider injection for AuthController
class AuthProvider extends InheritedNotifier<AuthController> {
  const AuthProvider({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null, 'No AuthProvider found in context');
    return provider!.notifier!;
  }
}
