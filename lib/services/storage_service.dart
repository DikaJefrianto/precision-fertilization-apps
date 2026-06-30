import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async => await _storage.write(key: 'token', value: token);
  Future<String?> getToken() async => await _storage.read(key: 'token');
  
  Future<void> saveRole(String role) async => await _storage.write(key: 'role', value: role);
  Future<String?> getRole() async => await _storage.read(key: 'role');

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'role');
  }
}