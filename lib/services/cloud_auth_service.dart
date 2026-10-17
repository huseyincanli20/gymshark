import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CloudUserRecord {
  final String id;
  final String name;
  final String email;
  final String password;
  final String createdAt;
  final Map<String, dynamic> metadata;

  CloudUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'createdAt': createdAt,
    'metadata': metadata,
  };

  factory CloudUserRecord.fromJson(Map<String, dynamic> json) => CloudUserRecord(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    createdAt: json['createdAt'] ?? '',
    metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : {},
  );
}

/// Özel Bulut ve Hosting Sağlayıcı Servisi
/// Kullanıcı kayıtlarını yerel önbellek ve kullanıcının kendi hosting API'si (PHP/MySQL) üzerinden senkronize tutar.
class CloudAuthService {
  static final CloudAuthService instance = CloudAuthService._();
  CloudAuthService._();

  static const String _defaultHostingUrl = 'https://huseyincanli.com/api';
  static const String _localCloudBackupKey = 'gymtrack_cloud_registered_users';
  static const String _customHostingUrlKey = 'gymtrack_custom_hosting_url';

  String? _cachedHostingUrl;

  /// Kayıtlı özel hosting URL'sini döner (Varsayılan: https://huseyincanli.com/api)
  Future<String> getHostingUrl() async {
    if (_cachedHostingUrl != null && _cachedHostingUrl!.isNotEmpty) {
      return _cachedHostingUrl!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_customHostingUrlKey);
      if (saved != null && saved.trim().isNotEmpty) {
        _cachedHostingUrl = saved.trim();
        return _cachedHostingUrl!;
      }
    } catch (_) {}
    _cachedHostingUrl = _defaultHostingUrl;
    return _defaultHostingUrl;
  }

  /// Özel hosting URL'sini ayarlar veya temizler
  Future<void> setHostingUrl(String? url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (url == null || url.trim().isEmpty) {
        await prefs.remove(_customHostingUrlKey);
        _cachedHostingUrl = _defaultHostingUrl;
      } else {
        String clean = url.trim();
        if (clean.endsWith('/')) {
          clean = clean.substring(0, clean.length - 1);
        }
        await prefs.setString(_customHostingUrlKey, clean);
        _cachedHostingUrl = clean;
      }
    } catch (e) {
      debugPrint("setHostingUrl error: $e");
    }
  }

  /// Hosting bağlantısını ve API durumunu test eder
  Future<Map<String, dynamic>> testHostingConnection(String url) async {
    String clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    final testUri = Uri.parse('$clean/test_connection.php');

    try {
      final response = await http.get(testUri).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Hosting ve MySQL veritabanına başarıyla bağlanıldı! 🚀',
          'totalUsers': data['total_registered_users'] ?? 0,
          'phpVersion': data['php_version'] ?? '',
        };
      } else {
        String msg = 'Sunucu HTTP ${response.statusCode} hatası döndürdü.';
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) msg = data['message'];
        } catch (_) {}
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Bağlantı kurulamadı ($e). Lütfen URL adresinizi ve hostinginizi kontrol edin.'
      };
    }
  }

  /// Yeni kayıt olan kullanıcıyı doğrudan hosting MySQL veritabanına kaydeder
  Future<bool> registerUserToCloud({
    required String name,
    required String email,
    String? password,
    Map<String, dynamic>? initialProfile,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim().isNotEmpty ? name.trim() : 'Sporcu';
    final hostingUrl = await getHostingUrl();

    final now = DateTime.now().toIso8601String();
    final metadata = {
      'platform': defaultTargetPlatform.name,
      'appVersion': '1.0.0',
      'registeredAt': now,
      if (initialProfile != null) ...initialProfile,
    };

    try {
      final regUri = Uri.parse('$hostingUrl/register.php');
      final response = await http
          .post(
            regUri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'name': cleanName,
              'email': cleanEmail,
              'password': password ?? '',
              'metadata': metadata,
            }),
          )
          .timeout(const Duration(seconds: 10));

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {}

      if (response.statusCode == 201 || response.statusCode == 200) {
        final serverUserId = data?['user']?['id'] ?? 'usr_${DateTime.now().millisecondsSinceEpoch}';
        final userRecord = CloudUserRecord(
          id: serverUserId,
          name: cleanName,
          email: cleanEmail,
          password: password ?? '',
          createdAt: data?['user']?['createdAt'] ?? now,
          metadata: metadata,
        );
        // Sadece sunucu kaydı başarılı olduktan sonra yerel kasaya ekle
        await _saveToLocalCloudVault(userRecord);
        debugPrint("Hosting veritabanına başarıyla kaydedildi: $cleanEmail");
        return true;
      } else if (response.statusCode == 409) {
        final msg = data?['message'] ?? "Bu e-posta adresi ile hosting üzerinde zaten bir hesap kayıtlı! Lütfen giriş yapın.";
        throw Exception(msg);
      } else if (response.statusCode == 400) {
        final msg = data?['message'] ?? "E-posta veya şifre bilgileri eksik veya geçersiz.";
        throw Exception(msg);
      } else {
        final msg = data?['message'] ?? "Sunucu hatası (HTTP ${response.statusCode}). Lütfen tekrar deneyin.";
        throw Exception(msg);
      }
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint("Hosting register bağlantı hatası: $e");
      throw Exception("Hosting sunucusuna bağlanılamadı ($e). Lütfen internetinizi ve sunucu adresinizi kontrol edin.");
    }
  }

  /// Kayıtlı kullanıcıları yerel kasada yedekler
  Future<void> _saveToLocalCloudVault(CloudUserRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJsonList = prefs.getStringList(_localCloudBackupKey) ?? [];

      final updatedList = <String>[];
      bool exists = false;

      for (final item in existingJsonList) {
        try {
          final data = jsonDecode(item);
          if (data['email'] == record.email) {
            updatedList.add(jsonEncode(record.toJson()));
            exists = true;
          } else {
            updatedList.add(item);
          }
        } catch (_) {}
      }

      if (!exists) {
        updatedList.add(jsonEncode(record.toJson()));
      }

      await prefs.setStringList(_localCloudBackupKey, updatedList);
    } catch (e) {
      debugPrint("Local Cloud Vault error: $e");
    }
  }

  /// Belirli bir e-postayı yerel kasadan siler
  Future<void> removeUserFromLocalVault(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localCloudBackupKey) ?? [];
      final cleanEmail = email.trim().toLowerCase();
      final updated = list.where((item) {
        try {
          final data = jsonDecode(item);
          return (data['email'] ?? '').toString().trim().toLowerCase() != cleanEmail;
        } catch (_) {
          return true;
        }
      }).toList();
      await prefs.setStringList(_localCloudBackupKey, updated);
    } catch (_) {}
  }

  /// E-posta adresinin daha önce kayıt olup olmadığını kontrol eder
  Future<bool> isEmailAlreadyRegistered(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    final users = await getCloudRegisteredUsers();
    return users.any((u) => u.email.trim().toLowerCase() == cleanEmail);
  }

  /// Giriş yaparken e-posta ve şifrenin doğruluğunu kontrol eder
  Future<CloudUserRecord?> verifyCredentials(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Yönetici Hesabı Doğrulaması (Hüseyin Canlı)
    if (cleanEmail == 'huseyincanli@gmail.com' && password == '15715799') {
      return CloudUserRecord(
        id: 'admin_usr_001',
        name: 'Hüseyin Canlı',
        email: 'huseyincanli@gmail.com',
        password: '15715799',
        createdAt: DateTime.now().toIso8601String(),
        metadata: {'role': 'admin'},
      );
    }

    // 2. Özel Hosting API Doğrulaması
    final hostingUrl = await getHostingUrl();
    try {
      final loginUri = Uri.parse('$hostingUrl/login.php');
      final response = await http
          .post(
            loginUri,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'email': cleanEmail,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final u = data['user'];
          final record = CloudUserRecord(
            id: u['id'] ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
            name: u['name'] ?? 'Sporcu',
            email: u['email'] ?? cleanEmail,
            password: password,
            createdAt: u['createdAt'] ?? DateTime.now().toIso8601String(),
            metadata: u['metadata'] is Map<String, dynamic> ? u['metadata'] : {},
          );
          await _saveToLocalCloudVault(record);
          return record;
        }
      } else if (response.statusCode == 401) {
        // Hatalı şifre veya kayıtlı olmayan e-posta
        return null;
      }
    } catch (e) {
      debugPrint("Hosting login error: $e. Falling back to local vault.");
    }

    // 3. Yerel Kasa / Çevrimdışı Doğrulama (İnternetsiz durumlar için)
    final users = await getCloudRegisteredUsers();
    for (final u in users) {
      if (u.email.trim().toLowerCase() == cleanEmail) {
        if (u.password == password) {
          return u;
        } else {
          return null;
        }
      }
    }

    return null;
  }

  /// Kayıtlı tüm kullanıcıları listeler
  Future<List<CloudUserRecord>> getCloudRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localCloudBackupKey) ?? [];
      return list.map((item) => CloudUserRecord.fromJson(jsonDecode(item))).toList();
    } catch (_) {
      return [];
    }
  }
}
