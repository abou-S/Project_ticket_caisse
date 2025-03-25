import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));
  final _storage = const FlutterSecureStorage();

  Future<String?> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/signup', data: {
        'email': email,
        'username': username,
        'password': password,
      });
      return response.data['message'];
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw 'Email ou nom d\'utilisateur déjà utilisé';
      }
      throw 'Une erreur est survenue lors de l\'inscription';
    }
  }

  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      
      final token = response.data['access_token'];
      await _storage.write(key: 'auth_token', value: token);
      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw 'Identifiants incorrects';
      }
      throw 'Une erreur est survenue lors de la connexion';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
} 