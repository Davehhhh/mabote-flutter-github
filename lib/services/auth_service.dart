import 'dart:convert';

import 'package:http/http.dart' as http;
import 'session.dart';

class AuthService {
  AuthService({String? baseUrl}) : _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://192.168.254.128/mabote_api');

  final String _baseUrl;

  Uri _url(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> login({required String email, required String password, bool persist = true}) async {
    final response = await http.post(
      _url('/login.php'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({ 'email': email, 'password': password }),
    );

    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      if (persist) {
        await Session.save(
          userId: (data['user_id'] as num?)?.toInt() ?? 0,
          userName: data['name']?.toString() ?? 'User',
          userEmail: email,
          token: data['token']?.toString() ?? '',
          qrId: data['qr_id']?.toString(),
        );
      }
      return data;
    }
    throw AuthException(message: data['message']?.toString() ?? 'Login failed', statusCode: response.statusCode);
  }

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    String? address,
    String? barangay,
    String? city,
  }) async {
    final response = await http.post(
      _url('/signup_extended.php'),
      headers: { 'Content-Type': 'application/json' },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (barangay != null) 'barangay': barangay,
        if (city != null) 'city': city,
      }),
    );
    final data = _decode(response);
    if (response.statusCode == 200 && data['success'] == true) {
      // Extract user data from the 'data' field
      final userData = data['data'] as Map<String, dynamic>? ?? {};
      
      // Auto-save session for signup as well
      await Session.save(
        userId: (userData['user_id'] as num?)?.toInt() ?? 0,
        userName: userData['name']?.toString() ?? '$firstName $lastName',
        userEmail: email,
        token: userData['token']?.toString() ?? '',
        qrId: userData['qr_id']?.toString(),
      );
      return data;
    }
    throw AuthException(message: data['message']?.toString() ?? 'Signup failed', statusCode: response.statusCode);
  }

  Future<void> logout() async {
    await Session.clear();
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return { 'success': false, 'message': 'Invalid server response', 'raw': response.body };
    }
  }
}

class AuthException implements Exception {
  AuthException({required this.message, this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'AuthException($statusCode): $message';
}


