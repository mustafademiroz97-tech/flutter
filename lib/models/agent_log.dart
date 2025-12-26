import 'package:flutter/foundation.dart'; // debugPrint için

class AgentLog {
  final String id;
  final String agentId;
  final DateTime timestamp;
  final String logType;
  final String message;
  final Map<String, dynamic> data;

  AgentLog({
    required this.id,
    required this.agentId,
    required this.timestamp,
    required this.logType,
    required this.message,
    required this.data,
  });

  // fromJson ve toJson metodlarını ekleyebiliriz, ancak şimdilik bu kadar yeterli.
  factory AgentLog.fromJson(Map<String, dynamic> json) {
    return AgentLog(
      id: json['id'] as String,
      agentId: json['agentId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      logType: json['logType'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'timestamp': timestamp.toIso8601String(),
      'logType': logType,
      'message': message,
      'data': data,
    };
  }
}
