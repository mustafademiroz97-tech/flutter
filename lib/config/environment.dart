class Environment {
  // Flask server and MQTT broker (Pi)
  static const String backendUrl = 'http://192.168.1.10:5000';
  static const String mqttBroker = '192.168.1.10';
  
  // Kamera IP
  static const String kameraIp = '192.168.1.169';
  
  // Other configurations
  static const int mqttPort = 1883;
  static const String mqttClientId = 'flutter_app';
}
