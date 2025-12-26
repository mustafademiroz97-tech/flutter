import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/mqtt_payload.dart';
import '../config/environment.dart';

class MqttManager {
  // Singleton Yapısı
  static final MqttManager _instance = MqttManager._internal();
  factory MqttManager() => _instance;
  MqttManager._internal();

  MqttServerClient? client;

  // Veri Akış Kanalı
  final StreamController<MqttSensorData> _dataController = StreamController<MqttSensorData>.broadcast();
  Stream<MqttSensorData> get dataStream => _dataController.stream;

  // Bağlantı Durumu Kanalı
  final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionStateController.stream;

  Future<void> connect(String host) async {
    // Rastgele Client ID (Çakışmayı önler)
    String clientId = 'flutter_admin_${Random().nextInt(9999)}';

    client = MqttServerClient(host, clientId);
    client!.port = Environment.mqttBrokerPort;
    client!.logging(on: Environment.enableMqttLogging);
    client!.keepAlivePeriod = Environment.mqttKeepAlive.inSeconds;
    client!.onDisconnected = _onDisconnected;
    client!.onConnected = _onConnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client!.connectionMessage = connMess;

    try {
      print('MQTT: $host adresine bağlanılıyor...');
      await client!.connect();
    } catch (e) {
      print('MQTT: Bağlantı Hatası - $e');
      client!.disconnect();
    }
  }

  void _onConnected() {
    print('MQTT: BAĞLANDI! Dinleme Başlıyor...');
    _connectionStateController.add(true);

    // YENİ ABONELİK (WILDCARD)
    // Python'un gönderdiği tüm verileri tek kanaldan yakalar
    const topic = 'agrimind/turbo30/+/+/sensor/+';
    client!.subscribe(topic, MqttQos.atMostOnce);

    client!.updates!.listen(_onMessageReceived);
  }

  void _onDisconnected() {
    print('MQTT: Bağlantı Koptu');
    _connectionStateController.add(false);
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final payloadString = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = c[0].topic;

    print("DEBUG -> GELEN TOPIC: $topic | PAYLOAD: $payloadString"); // Bunu terminalde görmelisin

    try {
      // Python {"val": 123} gönderiyor, onu çözüyoruz
      final Map<String, dynamic> json = jsonDecode(payloadString);
      final double value = (json['val'] as num).toDouble();

      // Topic'i parçalayıp anlamlandırıyoruz
      // Örn: agrimind/turbo30/hydro/main/sensor/ph
      final parts = topic.split('/');

      if (parts.length >= 6) {
        String layer = parts[2];   // hydro
        String device = parts[3];  // main
        // parts[4] "sensor" kelimesi
        String metric = parts[5];  // ph

        final sensorData = MqttSensorData(
          rawTopic: topic,
          layer: layer,
          device: device,
          metric: metric,
          value: value,
        );

        _dataController.add(sensorData);
      }
    } catch (e) {
      print("MQTT Parse Hatası: $e");
    }
  }

  // Komut Gönderme Fonksiyonu
  void toggleRelay(String layer, String device, bool state) {
    String topic = 'agrimind/turbo30/$layer/$device/cmd';
    String payload = state ? "ON" : "OFF";
    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}