import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

class AgriApiService {
  static const String baseUrl = "http://192.168.1.10:5000"; // Pi IP adresi
  static const String mqttBrokerHost = "192.168.1.10"; // MQTT broker IP adresi

  late MqttServerClient _mqttClient;

  AgriApiService() {
    _mqttClient = MqttServerClient(mqttBrokerHost, 'flutter-client-${DateTime.now().millisecondsSinceEpoch}');
    _mqttClient.port = 1883; // MQTT portu
    _mqttClient.logging(on: false);
    _mqttClient.keepAlivePeriod = 20;
    _mqttClient.onDisconnected = () => print('MQTT disconnected');
    _mqttClient.onConnected = () => print('MQTT Connected');
    _mqttClient.onSubscribed = (topic) => print('Subscribed to $topic');
    _mqttClient.onSubscribeFail = (topic) => print('Failed to subscribe $topic');
  }

  Future<void> connectMqtt() async {
    try {
      await _mqttClient.connect();
    } catch (e) {
      print('MQTT connect error $e');
      _mqttClient.disconnect();
      rethrow;
    }
  }

  void disconnectMqtt() {
    _mqttClient.disconnect();
  }

  // Generic HTTP GET request with retry logic
  Future<Map<String, dynamic>> _get(Uri uri) async {
    int tries = 0;
    int maxTries = 3;
    int delayMs = 500;
    while (tries < maxTries) {
      try {
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final jsonRes = jsonDecode(res.body);
          // Removed special gallery logic to ensure consistent response handling
          if (jsonRes['status'] == 'success' || jsonRes['status'] == 'empty') {
            return jsonRes;
          }
          // The gallery endpoint might just return data without a 'success' status
          if (uri.path.contains('/api/gallery')) {
             return jsonRes;
          }
          throw Exception(jsonRes['message'] ?? 'Unknown server error');
        } else if (res.statusCode >= 500) {
          tries++;
          await Future.delayed(Duration(milliseconds: delayMs));
          delayMs *= 3;
          continue;
        } else {
          throw Exception('HTTP ${res.statusCode}: ${res.body}');
        }
      } catch (e) {
        tries++;
        if (tries >= maxTries) rethrow;
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    throw Exception('Retries exhausted for GET ${uri.path}');
  }

  // Generic HTTP POST request with retry logic
  Future<Map<String, dynamic>> _post(Uri uri, Map<String, dynamic> body) async {
    final headers = {'Content-Type': 'application/json'};
    int tries = 0;
    int maxTries = 3;
    int delayMs = 500;
    while (tries < maxTries) {
      try {
        final res = await http.post(uri, headers: headers, body: jsonEncode(body)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final jsonRes = jsonDecode(res.body);
          if (jsonRes['status'] == 'success') return jsonRes;
          throw Exception(jsonRes['message'] ?? 'Unknown server error');
        } else if (res.statusCode >= 500) {
          tries++;
          await Future.delayed(Duration(milliseconds: delayMs));
          delayMs *= 3;
          continue;
        } else {
          throw Exception('HTTP ${res.statusCode}: ${res.body}');
        }
      } catch (e) {
        tries++;
        if (tries >= maxTries) rethrow;
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }
    throw Exception('Retries exhausted for POST ${uri.path}');
  }

  // MQTT Client instance getter
  MqttServerClient get mqttClient => _mqttClient;

  // 1. Kamera Hareket Ettirme
  Future<void> moveCamera(String direction) async {
    try {
      final url = Uri.parse('$baseUrl/api/move/$direction');
      await _get(url);
    } catch (e) {
      print("Kamera hatası: $e");
      rethrow;
    }
  }

  // 2. Analiz Başlat (Foto Çek & Konseyi Tetikle)
  Future<Map<String, dynamic>> analyzePlant() async {
    try {
      final url = Uri.parse('$baseUrl/api/capture');
      return await _get(url);
    } catch (e) {
      print("Analiz başlatma hatası: $e");
      rethrow;
    }
  }

  // 3. Konsey Geçmişini Çek (Sohbeti Gör)
  Future<Map<String, dynamic>> getCouncilLog() async {
    try {
      final url = Uri.parse('$baseUrl/api/council_log');
      return await _get(url);
    } catch (e) {
      print("Konsey geçmişi hatası: $e");
      rethrow;
    }
  }

  // 4. CEO Mesajı Gönder (Senin Konuşman) - Now uses MQTT
  Future<bool> sendCeoMessage(String message) async {
    try {
      final payload = jsonEncode({'message': message});
      final builder = MqttClientPayloadBuilder();
      builder.addUTF8String(payload);
      _mqttClient.publishMessage('agrimind/mobile/ceo', MqttQos.atLeastOnce, builder.payload!);
      return true;
    } catch (e) {
      print("Mesaj hatası (MQTT): $e");
      return false;
    }
  }

  // 5. Canlı Yayın Linki
  String get videoStreamUrl => "$baseUrl/video_feed";

  // 6. Galeri Fotoğraflarını Çek (Önceki archived_photos)
  Future<List<String>> fetchGallery() async {
    try {
      final uri = Uri.parse('$baseUrl/api/gallery');
      final response = await _get(uri);
      if (response['status'] == 'success' && response['data'] is List) {
        // CORRECTED: Map the relative paths from the server to full URLs.
        return List<String>.from(response['data'].map((path) => '$baseUrl$path'));
      }
      return [];
    } catch (e) {
      print("Galeri fotoğrafları bağlantı hatası: $e");
      rethrow;
    }
  }

  // 7. Saatlik Raporu Çek
  Future<Map<String, dynamic>> getHourlyReport() async {
    try {
      final url = Uri.parse('$baseUrl/api/reports/hourly');
      return await _get(url);
    } catch (e) {
      print("Saatlik rapor bağlantı hatası: $e");
      rethrow;
    }
  }

  // 8. Günlük Raporu Çek
  Future<Map<String, dynamic>> getDailyReport() async {
    try {
      final url = Uri.parse('$baseUrl/api/reports/daily');
      return await _get(url);
    } catch (e) {
      print("Günlük rapor bağlantı hatası: $e");
      rethrow;
    }
  }

  // 9. Haftalık Raporu Çek
  Future<Map<String, dynamic>> getWeeklyReport() async {
    try {
      final url = Uri.parse('$baseUrl/api/reports/weekly');
      return await _get(url);
    } catch (e) {
      print("Haftalık rapor bağlantı hatası: $e");
      rethrow;
    }
  }

  // 10. Aylık Raporu Çek
  Future<Map<String, dynamic>> getMonthlyReport() async {
    try {
      final url = Uri.parse('$baseUrl/api/reports/monthly');
      return await _get(url);
    } catch (e) {
      print("Aylık rapor bağlantı hatası: $e");
      rethrow;
    }
  }

  // 11. Ayarları Çek
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final url = Uri.parse('$baseUrl/api/settings');
      return await _get(url);
    } catch (e) {
      print("Ayarlar bağlantı hatası: $e");
      rethrow;
    }
  }

  // 12. Ayarları Güncelle
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    try {
      final url = Uri.parse('$baseUrl/api/settings');
      final response = await _post(url, settings);
      return response['status'] == 'success';
    } catch (e) {
      print("Ayarlar güncellenemedi: $e");
      rethrow;
    }
  }

  // 13. Manuel Dozlama
  Future<bool> manualDose(String type, double amount) async {
    try {
      final url = Uri.parse('$baseUrl/api/manual_dose');
      final response = await _post(url, {"type": type, "amount": amount});
      return response['status'] == 'success';
    } catch (e) {
      print("Manuel dozlama hatası: $e");
      rethrow;
    }
  }

  // 14. İklim Kontrolü
  Future<bool> controlClimate(String device, bool isOn) async {
    try {
      final url = Uri.parse('$baseUrl/api/control_climate');
      final response = await _post(url, {"device": device, "is_on": isOn});
      return response['status'] == 'success';
    } catch (e) {
      print("İklim kontrol hatası: $e");
      rethrow;
    }
  }
}
