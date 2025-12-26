import 'package:flutter/material.dart';
import 'package:agrimind/config/theme.dart';
import 'package:agrimind/screens/intelligence_screen.dart'; // Will navigate to this screen
import 'package:agrimind/screens/council_chat_screen.dart'; // Yeni eklenen CouncilChatScreen

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({super.key});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  // Yapay zeka ajanları için güncel isim haritalaması
  final Map<String, String> _aiAgentDisplayNames = {
    'chairman': 'Meclis Başkanı',
    'dr_bio': 'Baş Ziraat Mühendisi',
    'prof_chem': 'Baş Kimyager',
    'muh_tech': 'Teknik Lider',
    'cfo': 'Finans Müdürü',
    'critic': 'Baş Denetçi',
    'secretary': 'Genel Sekreter',
  };

  // Bu kısım daha sonra gerçek zamanlı okunmamış mesaj sayısı ile güncellenecek
  final Map<String, int> _unreadMessageCounts = {
    'chairman': 0,
    'dr_bio': 0,
    'prof_chem': 0,
    'muh_tech': 0,
    'cfo': 0,
    'critic': 0,
    'secretary': 0,
    'council': 0, // Ortak sohbet için okunmamış mesaj sayısı
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akıllı Asistan Ajanları', style: Theme.of(context).textTheme.displayLarge),
      ),
      body: ListView.builder(
        itemCount: _aiAgentDisplayNames.length + 1, // +1 for the common chat entry
        itemBuilder: (context, index) {
          if (index == 0) {
            // Ortak sohbet girişi
            final unreadCount = _unreadMessageCounts['council'] ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: AppTheme.cardColorLight,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: const Icon(Icons.groups, color: Colors.white),
                ),
                title: Text(
                  'Tüm Konsey Sohbeti',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CouncilChatScreen(),
                    ),
                  );
                },
              ),
            );
          } else {
            // Bireysel ajan sohbetleri
            final agentId = _aiAgentDisplayNames.keys.elementAt(index - 1);
            final agentDisplayName = _aiAgentDisplayNames[agentId]!;
            final unreadCount = _unreadMessageCounts[agentId] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              color: AppTheme.cardColorLight,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    agentDisplayName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  agentDisplayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IntelligenceScreen(agentId: agentId, agentDisplayName: agentDisplayName),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
