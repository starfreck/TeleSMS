import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

class StorageService {
  static final secureStorage = _getSecureStorage();
  static final StorageService _storageService = StorageService._internal();

  factory StorageService() {
    return _storageService;
  }

  StorageService._internal();

  static FlutterSecureStorage _getSecureStorage() {
    // This will prevent errors due to mixed usage of encryptedSharedPreferences
    if (Platform.isAndroid) {
      return const FlutterSecureStorage(
          aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ));
    }

    if (Platform.isIOS) {
      return const FlutterSecureStorage(
          iOptions:
              IOSOptions(accessibility: KeychainAccessibility.first_unlock));
    }
    return const FlutterSecureStorage();
  }

  Future<void> write({required String key, required String value}) async {
    await secureStorage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await secureStorage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await secureStorage.delete(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return await secureStorage.containsKey(key: key);
  }
}
