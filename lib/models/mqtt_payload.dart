class MqttSensorData {
  final String rawTopic;
  final String layer;     // Örn: hydro, rack
  final String device;    // Örn: main, fan, dosing (Varsa)
  final String metric;    // Örn: ph, ec, temp
  final double value;     // Örn: 24.5

  MqttSensorData({
    required this.rawTopic,
    required this.layer,
    required this.device,
    required this.metric,
    required this.value,
  });

  @override
  String toString() => '$layer/$metric : $value';
}