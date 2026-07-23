import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class ApiService extends ChangeNotifier {
  // Production API Base URL deployed on Render
  static String baseUrl = 'https://qr-based-app.onrender.com';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static const String _tokenKey = 'jwt_auth_token';

  UserModel? _currentUser;
  String? _jwtToken;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get jwtToken => _jwtToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _jwtToken != null && _jwtToken!.isNotEmpty;

  ApiService() {
    _initToken();
  }

  Future<void> _initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString(_tokenKey);
    if (_jwtToken != null) {
      _setAuthHeader(_jwtToken!);
    }
  }

  void _setAuthHeader(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void setBaseUrl(String newUrl) {
    baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
    notifyListeners();
  }

  /// Exchange Firebase ID Token for Backend JWT
  Future<bool> loginWithFirebaseToken(String idToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post('/api/auth/login', data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        _jwtToken = response.data['token'];
        _currentUser = UserModel.fromJson(response.data['user']);

        _setAuthHeader(_jwtToken!);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _jwtToken!);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('API Login Error: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Unexpected Login Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Fetch User Profile from Backend
  Future<UserModel?> fetchProfile() async {
    if (_jwtToken == null) return null;

    try {
      final response = await _dio.get('/api/user');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['user']);
        notifyListeners();
        return _currentUser;
      }
    } on DioException catch (e) {
      debugPrint('Fetch Profile Error: ${e.response?.data ?? e.message}');
    }
    return null;
  }

  /// Update User Profile
  Future<bool> updateProfile({String? name, String? qrData}) async {
    if (_jwtToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.put('/api/user', data: {
        if (name != null) 'name': name,
        if (qrData != null) 'qrData': qrData,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        _currentUser = UserModel.fromJson(response.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout User
  Future<void> logout() async {
    _jwtToken = null;
    _currentUser = null;
    _dio.options.headers.remove('Authorization');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);

    notifyListeners();
  }
}
