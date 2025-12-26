import 'package:mqtt5_client/mqtt_client.dart';
import 'package:mqtt5_client/mqtt_server_client.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Represents sensor data received from MQTT topics
class SensorData {
  final String sensorId;
  final String sensorType;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  SensorData({
    required this.sensorId,
    required this.sensorType,
    required this.value,
    required this.timestamp,
    this.metadata = const {},
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensorId: json['sensorId'] ?? 'unknown',
      sensorType: json['sensorType'] ?? 'unknown',
      value: (json['value'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'sensorId': sensorId,
        'sensorType': sensorType,
        'value': value,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() =>
      'SensorData(id: $sensorId, type: $sensorType, value: $value, time: $timestamp)';
}

/// MQTT connection states
enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// MQTT Service for handling sensor data streaming
class MqttService extends ChangeNotifier {
  late MqttServerClient _client;
  
  final String broker;
  final int port;
  final String clientId;
  
  MqttConnectionState _connectionState = MqttConnectionState.disconnected;
  String _lastError = '';
  
  final StreamController<SensorData> _sensorDataController =
      StreamController<SensorData>.broadcast();
  final StreamController<MqttConnectionState> _connectionStateController =
      StreamController<MqttConnectionState>.broadcast();
  
  final Map<String, List<Function(SensorData)>> _topicSubscriptions = {};
  
  bool _isDisposed = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  /// Stream of sensor data updates
  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  /// Stream of connection state changes
  Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Current connection state
  MqttConnectionState get connectionState => _connectionState;

  /// Last error message
  String get lastError => _lastError;

  /// Is client connected
  bool get isConnected =>
      _connectionState == MqttConnectionState.connected &&
      _client.connectionStatus?.state == MqttConnectionState.connected.index;

  MqttService({
    this.broker = 'test.mosquitto.org',
    this.port = 1883,
    this.clientId = 'flutter_mqtt_client',
  }) {
    _initializeClient();
  }

  /// Initialize MQTT client
  void _initializeClient() {
    _client = MqttServerClient(broker, clientId);
    _client.port = port;
    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;
    _client.resubscribeOnAutoReconnect = true;
    
    // Set up logging
    _client.logging(on: false);
    
    // Connection callbacks
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnectAborted = _onAutoReconnectAborted;
    
    // Message received callback
    _client.updates!.listen(_onMessageReceived);
  }

  /// Connect to MQTT broker
  Future<bool> connect({String? username, String? password}) async {
    try {
      _updateConnectionState(MqttConnectionState.connecting);
      
      if (username != null && password != null) {
        _client.authentication(username: username, password: password);
      }

      final result = await _client.connect();
      
      if (result?.state == MqttConnectionState.connected.index) {
        _reconnectAttempts = 0;
        _updateConnectionState(MqttConnectionState.connected);
        return true;
      } else {
        _lastError = 'Connection failed with state: ${result?.state}';
        _updateConnectionState(MqttConnectionState.error);
        return false;
      }
    } catch (e) {
      _lastError = 'Connection error: $e';
      _updateConnectionState(MqttConnectionState.error);
      _scheduleReconnect();
      return false;
    }
  }

  /// Subscribe to a topic for sensor data
  void subscribe(String topic) {
    try {
      if (!isConnected) {
        _lastError = 'Not connected to MQTT broker';
        return;
      }

      _client.subscribe(topic, MqttQos.atMostOnce);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      _lastError = 'Subscription error: $e';
      debugPrint('Error subscribing to $topic: $e');
    }
  }

  /// Subscribe to multiple topics
  void subscribeToTopics(List<String> topics) {
    for (final topic in topics) {
      subscribe(topic);
    }
  }

  /// Unsubscribe from a topic
  void unsubscribe(String topic) {
    try {
      if (isConnected) {
        _client.unsubscribe(topic);
        _topicSubscriptions.remove(topic);
        debugPrint('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      _lastError = 'Unsubscribe error: $e';
      debugPrint('Error unsubscribing from $topic: $e');
    }
  }

  /// Register a callback for a specific topic
  void onSensorData(String topic, Function(SensorData) callback) {
    _topicSubscriptions.putIfAbsent(topic, () => []).add(callback);
  }

  /// Publish sensor data to a topic
  Future<void> publishSensorData(
    String topic,
    SensorData data, {
    bool retain = false,
  }) async {
    try {
      if (!isConnected) {
        _lastError = 'Not connected to MQTT broker';
        return;
      }

      final payload = utf8.encode(jsonEncode(data.toJson()));
      _client.publishMessage(
        topic,
        MqttQos.atMostOnce,
        payload,
        retain: retain,
      );

      debugPrint('Published to $topic: $data');
    } catch (e) {
      _lastError = 'Publish error: $e';
      debugPrint('Error publishing to $topic: $e');
    }
  }

  /// Disconnect from MQTT broker
  Future<void> disconnect() async {
    try {
      _reconnectTimer?.cancel();
      _client.disconnect();
      _updateConnectionState(MqttConnectionState.disconnected);
      debugPrint('Disconnected from MQTT broker');
    } catch (e) {
      _lastError = 'Disconnect error: $e';
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Handle incoming MQTT messages
  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = message.payload;

      try {
        if (payload is MqttPublishMessage) {
          final data = utf8.decode(payload.payload.message);
          final json = jsonDecode(data) as Map<String, dynamic>;
          final sensorData = SensorData.fromJson(json);

          // Emit to stream
          if (!_isDisposed) {
            _sensorDataController.add(sensorData);
          }

          // Call registered callbacks
          if (_topicSubscriptions.containsKey(topic)) {
            for (final callback in _topicSubscriptions[topic]!) {
              callback(sensorData);
            }
          }

          debugPrint('Received from $topic: $sensorData');
        }
      } catch (e) {
        _lastError = 'Error processing message: $e';
        debugPrint('Error processing message from $topic: $e');
      }
    }
  }

  /// Connection established callback
  void _onConnected() {
    debugPrint('MQTT Connected');
    _updateConnectionState(MqttConnectionState.connected);
    _reconnectAttempts = 0;
  }

  /// Connection disconnected callback
  void _onDisconnected() {
    debugPrint('MQTT Disconnected');
    _updateConnectionState(MqttConnectionState.disconnected);
    _scheduleReconnect();
  }

  /// Subscription successful callback
  void _onSubscribed(String topic) {
    debugPrint('Subscribed to: $topic');
  }

  /// Subscription failed callback
  void _onSubscribeFail(String topic) {
    _lastError = 'Subscription failed for: $topic';
    debugPrint(_lastError);
  }

  /// Auto reconnect initiated callback
  void _onAutoReconnect() {
    debugPrint('MQTT Auto-reconnecting');
    _updateConnectionState(MqttConnectionState.reconnecting);
  }

  /// Auto reconnect aborted callback
  void _onAutoReconnectAborted() {
    _lastError = 'Auto-reconnect aborted';
    debugPrint(_lastError);
    _scheduleReconnect();
  }

  /// Schedule a reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _lastError = 'Max reconnection attempts reached';
      _updateConnectionState(MqttConnectionState.error);
      return;
    }

    _reconnectAttempts++;
    debugPrint(
        'Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isDisposed && !isConnected) {
        connect();
      }
    });
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(MqttConnectionState newState) {
    if (_connectionState != newState && !_isDisposed) {
      _connectionState = newState;
      _connectionStateController.add(_connectionState);
      notifyListeners();
    }
  }

  /// Get connection statistics
  Map<String, dynamic> getConnectionStats() {
    return {
      'broker': broker,
      'port': port,
      'clientId': clientId,
      'connected': isConnected,
      'state': _connectionState.toString(),
      'lastError': _lastError,
      'reconnectAttempts': _reconnectAttempts,
    };
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _sensorDataController.close();
    _connectionStateController.close();
    _client.disconnect();
    super.dispose();
  }
}
