import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/loan_calculator/domain/entities/saved_loan_item.dart';
import '../../features/loan_calculator/domain/entities/seven_day_loan_result.dart';
import '../services/session_service.dart';

/// API Client connecting Flutter client directly to Node.js & MySQL Backend
class ApiService {
  ApiService._() {
    _initDefaultBaseUrl();
  }
  static final ApiService instance = ApiService._();

  /// Flag for testing environments only (defaults to false for real live API)
  static bool useLocalMockForTesting = false;

  late String _baseUrl;

  void _initDefaultBaseUrl() {
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      _baseUrl = customUrl.endsWith('/api') ? customUrl : '$customUrl/api';
      return;
    }

    // Default to Production API
    _baseUrl = 'http://10.0.2.2:5000/api';
  }

  void setBaseUrl(String url) {
    _baseUrl = url;
  }

  String get baseUrl => _baseUrl;

  /// Helper for auth headers
  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await SessionService.instance.getToken();
    final headers = <String, String>{};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Health check to verify Node.js backend & MySQL status
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'status': 'error', 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      return {'status': 'offline', 'error': e.toString()};
    }
  }

  // ==========================================
  // AUTH APIS (Direct to Node.js & MySQL)
  // ==========================================

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String rePassword,
    String? imagePath,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    if (useLocalMockForTesting) {
      final user = UserEntity(
        id: 1,
        email: email,
        hasAcceptedTerms: false,
        createdAt: DateTime.now(),
      );
      const token = 'test_mock_token';
      await SessionService.instance.saveSession(token: token, user: user);
      return {'success': true, 'user': user, 'token': token};
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/register');
      final request = http.MultipartRequest('POST', uri);

      request.fields['email'] = email.trim();
      request.fields['password'] = password;
      request.fields['re_password'] = rePassword;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final filename = imageName ?? 'avatar.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            imageBytes,
            filename: filename,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      } else if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            imagePath,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resData = data['data'] as Map<String, dynamic>;
        final token = resData['token'] as String;
        final user = UserEntity.fromJson(resData['user'] as Map<String, dynamic>);
        await SessionService.instance.saveSession(token: token, user: user);
        return {'success': true, 'user': user, 'token': token};
      } else {
        throw Exception(data['message'] ?? 'การสมัครสมาชิกล้มเหลว');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ Backend ที่ $_baseUrl ได้ กรุณาตรวจสอบว่ารัน "npm start" ในโฟลเดอร์ backend แล้ว',
        );
      }
      rethrow;
    }
  }

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (useLocalMockForTesting) {
      final user = UserEntity(
        id: 1,
        email: email,
        hasAcceptedTerms: await SessionService.instance.hasAcceptedTerms(),
        createdAt: DateTime.now(),
      );
      const token = 'test_mock_token';
      await SessionService.instance.saveSession(token: token, user: user);
      return {'success': true, 'user': user, 'token': token};
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/login');
      final headers = await _getHeaders();
      final body = jsonEncode({'email': email.trim(), 'password': password});

      final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resData = data['data'] as Map<String, dynamic>;
        final token = resData['token'] as String;
        final user = UserEntity.fromJson(resData['user'] as Map<String, dynamic>);
        await SessionService.instance.saveSession(token: token, user: user);
        return {'success': true, 'user': user, 'token': token};
      } else {
        throw Exception(data['message'] ?? 'เข้าสู่ระบบล้มเหลว');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ Backend ที่ $_baseUrl ได้ กรุณาตรวจสอบว่ารัน "npm start" ในโฟลเดอร์ backend แล้ว',
        );
      }
      rethrow;
    }
  }

  /// POST /api/auth/accept-terms (with optional evidence screenshot capture)
  Future<UserEntity> acceptTerms({Uint8List? imageBytes}) async {
    if (useLocalMockForTesting) {
      await SessionService.instance.updateTermsAccepted(true);
      final currentUser = await SessionService.instance.getUser();
      return currentUser?.copyWith(hasAcceptedTerms: true) ??
          const UserEntity(id: 1, email: 'user@finclub.com', hasAcceptedTerms: true);
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/accept-terms');
      final headers = await _getHeaders();

      http.Response response;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final request = http.MultipartRequest('POST', uri);
        headers.remove('Content-Type');
        request.headers.addAll(headers);
        request.files.add(
          http.MultipartFile.fromBytes(
            'evidence',
            imageBytes,
            filename: 'policy_capture_${DateTime.now().millisecondsSinceEpoch}.png',
            contentType: MediaType('image', 'png'),
          ),
        );
        final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http.post(uri, headers: headers).timeout(const Duration(seconds: 8));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final userData = data['data']['user'] as Map<String, dynamic>;
        final user = UserEntity.fromJson(userData);
        await SessionService.instance.updateTermsAccepted(true);
        return user;
      } else {
        throw Exception(data['message'] ?? 'บันทึกการยอมรับเงื่อนไขล้มเหลว');
      }
    } catch (e) {
      debugPrint('acceptTerms error or offline fallback: $e');
      await SessionService.instance.updateTermsAccepted(true);
      final currentUser = await SessionService.instance.getUser();
      return currentUser?.copyWith(hasAcceptedTerms: true) ??
          const UserEntity(id: 1, email: 'user@finclub.com', hasAcceptedTerms: true);
    }
  }

  /// GET /api/auth/me - Verifies token and user existence directly in database
  Future<UserEntity?> getMe() async {
    if (useLocalMockForTesting) {
      return SessionService.instance.getUser();
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/me');
      final headers = await _getHeaders();
      if (!headers.containsKey('Authorization')) {
        return null;
      }

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserEntity.fromJson(data['data']['user'] as Map<String, dynamic>);
        final token = await SessionService.instance.getToken();
        if (token != null) {
          await SessionService.instance.saveSession(token: token, user: user);
        }
        return user;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        // User was deleted from DB or token is invalid!
        debugPrint('[ApiService] User does not exist in DB (HTTP ${response.statusCode}). Invalidation triggered.');
        await SessionService.instance.clearSession();
        return null;
      }
    } catch (e) {
      debugPrint('[ApiService] getMe check offline or error: $e');
      // If server is offline, do NOT invalidate session - fall back to cached user
      return await SessionService.instance.getUser();
    }
    return null;
  }

  /// DELETE /api/auth/account - Google Play Account Deletion Policy compliance
  Future<bool> deleteAccount() async {
    if (useLocalMockForTesting) {
      await SessionService.instance.clearSession();
      return true;
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/account');
      final headers = await _getHeaders();
      if (!headers.containsKey('Authorization')) {
        await SessionService.instance.clearSession();
        return true;
      }

      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 8));
      await SessionService.instance.clearSession();
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] Delete account error: $e');
      await SessionService.instance.clearSession();
      return true;
    }
  }

  // ==========================================
  // SAVED PLANS APIS (User-Isolated in MySQL)
  // ==========================================

  /// GET /api/saved-plans
  Future<List<SavedLoanItem>> getSavedPlans() async {
    if (useLocalMockForTesting) return [];

    try {
      final uri = Uri.parse('$_baseUrl/saved-plans');
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data']['plans'] as List<dynamic>;
        return list.map((json) => SavedLoanItem.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] Error fetching saved plans: $e');
    }
    return [];
  }

  /// POST /api/saved-plans
  Future<SavedLoanItem?> createSavedPlan({
    String? title,
    required double loanAmount,
    double annualRate = 35.80,
    String? note,
  }) async {
    if (useLocalMockForTesting) {
      return SavedLoanItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title ?? 'สินเชื่อ 7 วัน ฿${loanAmount.toInt()}',
        createdAt: DateTime.now(),
        loanAmount: loanAmount,
        interestPerDay: ((loanAmount * 0.358) / 365 * 100).roundToDouble() / 100.0,
        totalInterest: (((loanAmount * 0.358) / 365 * 100).roundToDouble() / 100.0) * 7,
        revenueFee: loanAmount * 0.01 > 50 ? loanAmount * 0.01 : 50.0,
        totalAmount: loanAmount + ((((loanAmount * 0.358) / 365 * 100).roundToDouble() / 100.0) * 7) + (loanAmount * 0.01 > 50 ? loanAmount * 0.01 : 50.0),
        tenureDays: 7,
        dueDate: '7 วันหลังจากอนุมัติ',
        annualInterestRate: annualRate,
        note: note,
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/saved-plans');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'title': title,
        'loan_amount': loanAmount,
        'annual_rate': annualRate,
        'note': note,
      });

      final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final planJson = data['data']['plan'] as Map<String, dynamic>;
        return SavedLoanItem.fromJson(planJson);
      }
    } catch (e) {
      debugPrint('[ApiService] Error saving plan: $e');
    }
    return null;
  }

  /// DELETE /api/saved-plans/:id
  Future<bool> deleteSavedPlan(String id) async {
    if (useLocalMockForTesting) return true;

    try {
      final uri = Uri.parse('$_baseUrl/saved-plans/$id');
      final headers = await _getHeaders();

      final response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 6));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('[ApiService] Error deleting plan: $e');
    }
    return false;
  }

  // ==========================================
  // 7-DAY LOAN APIS
  // ==========================================

  /// POST /api/loans/calculate
  Future<SevenDayLoanResult> calculate7DaysLoan({
    required double principal,
    double annualRate = 35.80,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/loans/calculate');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'principal': principal,
        'annual_rate': annualRate,
      });

      final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return SevenDayLoanResult.fromJson(data['data'] as Map<String, dynamic>);
      }
    } catch (_) {}

    // Pure local calculation fallback
    return SevenDayLoanResult.compute(principal: principal, annualRate: annualRate);
  }

  /// POST /api/loans/apply
  Future<SevenDayLoanResult> apply7DaysLoan({
    required double principal,
    double annualRate = 35.80,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/loans/apply');
      final headers = await _getHeaders();
      final body = jsonEncode({
        'principal': principal,
        'annual_rate': annualRate,
      });

      final response = await http.post(uri, headers: headers, body: body).timeout(const Duration(seconds: 8));
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SevenDayLoanResult.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(data['message'] ?? 'ยื่นกู้สินเชื่อไม่สำเร็จ');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('Connection refused')) {
        throw Exception(
          'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ Backend ที่ $_baseUrl ได้ กรุณาตรวจสอบว่ารัน "npm start" ในโฟลเดอร์ backend แล้ว',
        );
      }
      rethrow;
    }
  }
}
