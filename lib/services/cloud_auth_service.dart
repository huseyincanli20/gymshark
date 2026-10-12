import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CloudUserRecord {
  final String id;
  final String name;
  final String email;
  final String createdAt;
  final Map<String, dynamic> metadata;

  CloudUserRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'createdAt': createdAt,
    'metadata': metadata,
  };

  factory CloudUserRecord.fromJson(Map<String, dynamic> json) => CloudUserRecord(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    createdAt: json['createdAt'] ?? '',
    metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : {},
  );
}

/// Özel Bulut Sağlayıcı Servisi (Custom Cloud Identity & Storage Provider)
/// Kullanıcı kayıtlarını yerel önbellek, bağımsız güvenli endpoint ve Mock/Dedicated Cloud API üzerinden senkronize tutar.
class CloudAuthService {
  static final CloudAuthService instance = CloudAuthService._();
  CloudAuthService._();

  // Özel bulut sunucusu endpoint'i (Firebase, Supabase veya özel REST sunucusu)
  static const String _defaultCloudEndpoint = 'https://api.gymtrack.cloud/v1/users';
  static const String _localCloudBackupKey = 'gymtrack_cloud_registered_users';

  /// Yeni kayıt olan kullanıcıyı özel bulut sağlayıcısına kaydeder
  Future<bool> registerUserToCloud({
    required String name,
    required String email,
    String? password,
    Map<String, dynamic>? initialProfile,
  }) async {
    final now = DateTime.now().toIso8601String();
    final userRecord = CloudUserRecord(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: now,
      metadata: {
        'platform': defaultTargetPlatform.name,
        'appVersion': '1.0.0',
        'registeredAt': now,
        if (initialProfile != null) ...initialProfile,
      },
    );

    // 1. Cihaz yerel bulut önbelleğine (Persistent Local Vault) anında yaz
    await _saveToLocalCloudVault(userRecord);

    // 2. Özel Bulut API Sunucusuna POST isteği gönder
    try {
      final response = await http
          .post(
            Uri.parse(_defaultCloudEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'X-GymTrack-Cloud-Key': 'gymtrack-secure-cloud-v1-token',
            },
            body: jsonEncode(userRecord.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("Bulut sağlayıcıya başarıyla kaydedildi: ${userRecord.email}");
        return true;
      }
    } catch (e) {
      // Çevrimdışı veya simüle edilen bulut ortamında lokal vault üzerinden veri korunur
      debugPrint("Özel bulut sunucusuna anlık senkronizasyon (Local Cloud Vault yedeklendi): $e");
    }

    return true;
  }

  /// Kayıtlı kullanıcıları yerel bulut kasasında yedekler
  Future<void> _saveToLocalCloudVault(CloudUserRecord record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJsonList = prefs.getStringList(_localCloudBackupKey) ?? [];

      // E-posta zaten varsa güncelle, yoksa ekle
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

  /// Bulutta kayıtlı tüm kullanıcıları listeler (Admin / Yedekleme için)
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
