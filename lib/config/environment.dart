/// Environment configuration for backend and MQTT connections
/// 
/// This file contains all configurable connection settings for the AgriMind app.
/// Update these values based on your deployment environment.

class Environment {
  // Backend API Configuration
  static const String backendHost = '192.168.1.169';
  static const int backendPort = 5000;
  static const String backendProtocol = 'http';
  
  /// Full backend base URL
  static String get baseUrl => '$backendProtocol://$backendHost:$backendPort';
  
  // MQTT Broker Configuration
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
  static const bool enableApiLogging = true;
}
