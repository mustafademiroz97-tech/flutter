/// Environment configuration for backend and MQTT connections
/// 
/// This file contains all configurable connection settings for the AgriMind app.
/// Update these values based on your deployment environment.
/// 
/// Network Architecture:
/// - Backend API runs on Pi device (192.168.1.169:5000)
/// - MQTT Broker runs locally on mobile device (127.0.0.1:1883)
///   or can be configured to point to remote broker

class Environment {
  // Backend API Configuration
  // The backend runs on a Raspberry Pi at the specified IP address
  static const String backendHost = '192.168.1.169';
  static const int backendPort = 5000;
  static const String backendProtocol = 'http';
  
  /// Full backend base URL
  static String get baseUrl => '$backendProtocol://$backendHost:$backendPort';
  
  // MQTT Broker Configuration
  // MQTT broker for real-time sensor data
  // Default: localhost (127.0.0.1) for local MQTT broker
  // Change to backend IP if using remote broker: '192.168.1.169'
  static const String mqttBrokerHost = '127.0.0.1';
  static const int mqttBrokerPort = 1883;
  
  // Timeout Configuration
  static const Duration apiTimeout = Duration(seconds: 5);
  static const Duration mqttKeepAlive = Duration(seconds: 60);
  
  // Retry Configuration
  static const int maxRetries = 3;
  static const int initialRetryDelayMs = 500;
  
  // Debug Settings
  static const bool enableMqttLogging = true;
}
