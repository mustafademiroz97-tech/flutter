import 'package:agrimind/models/agent_log.dart';

class MockService {
  List<AgentLog> getAgentLogs() {
    return [
      AgentLog(
        id: '1',
        agentId: 'ai',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        logType: 'message',
        message: 'Merhaba! Size nasıl yardımcı olabilirim?',
        data: {},
      ),
      AgentLog(
        id: '2',
        agentId: 'user',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 28)),
        logType: 'message',
        message: 'Topraksız tarım sistemimdeki sensör verilerini kontrol etmek istiyorum.',
        data: {},
      ),
      AgentLog(
        id: '3',
        agentId: 'ai',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 25)),
        logType: 'data_request',
        message: 'Elbette, hangi sensörün verilerini görmek istersiniz? (Örn: pH, Nem, Sıcaklık)',
        data: {'requestType': 'sensor_data', 'options': ['pH', 'Nem', 'Sıcaklık']},
      ),
      AgentLog(
        id: '4',
        agentId: 'ai',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        logType: 'message',
        message: 'Anladım. Başka nasıl yardımcı olabilirim?',
        data: {},
      ),
    ];
  }
}
