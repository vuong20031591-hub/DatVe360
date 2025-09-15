import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Storage service for persisting data using SharedPreferences
class StorageService {
  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Initialize storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Write string value
  Future<bool> write(String key, dynamic value) async {
    try {
      if (value == null) {
        return await _prefs.remove(key);
      }

      if (value is String) {
        return await _prefs.setString(key, value);
      } else if (value is int) {
        return await _prefs.setInt(key, value);
      } else if (value is double) {
        return await _prefs.setDouble(key, value);
      } else if (value is bool) {
        return await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        return await _prefs.setStringList(key, value);
      } else {
        // For complex objects, serialize to JSON
        final jsonString = jsonEncode(value);
        return await _prefs.setString(key, jsonString);
      }
    } catch (e) {
      if (kDebugMode) {
        print('StorageService write error: $e');
      }
      return false;
    }
  }

  /// Read value
  T? read<T>(String key) {
    try {
      final value = _prefs.get(key);
      if (value == null) return null;

      // If T is String and value is String, return directly
      if (T == String && value is String) {
        return value as T;
      }

      // If T is a complex type, try to parse JSON
      if (value is String && T != String) {
        try {
          final decoded = jsonDecode(value);
          return decoded as T;
        } catch (e) {
          // If JSON parsing fails, return the string value
          return value as T;
        }
      }

      return value as T;
    } catch (e) {
      if (kDebugMode) {
        print('StorageService read error: $e');
      }
      return null;
    }
  }

  /// Read string value
  String? readString(String key) {
    return _prefs.getString(key);
  }

  /// Read int value
  int? readInt(String key) {
    return _prefs.getInt(key);
  }

  /// Read double value
  double? readDouble(String key) {
    return _prefs.getDouble(key);
  }

  /// Read bool value
  bool? readBool(String key) {
    return _prefs.getBool(key);
  }

  /// Read string list value
  List<String>? readStringList(String key) {
    return _prefs.getStringList(key);
  }

  /// Delete value
  Future<bool> delete(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('StorageService delete error: $e');
      }
      return false;
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Clear all data
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      if (kDebugMode) {
        print('StorageService clear error: $e');
      }
      return false;
    }
  }

  /// Reload preferences from disk
  Future<void> reload() async {
    try {
      await _prefs.reload();
    } catch (e) {
      if (kDebugMode) {
        print('StorageService reload error: $e');
      }
    }
  }

  /// Get storage size (approximate)
  int getStorageSize() {
    int size = 0;
    for (String key in _prefs.getKeys()) {
      final value = _prefs.get(key);
      if (value != null) {
        size += key.length;
        if (value is String) {
          size += value.length;
        } else {
          size += value.toString().length;
        }
      }
    }
    return size;
  }
}
