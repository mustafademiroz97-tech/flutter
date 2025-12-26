import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrimind/config/theme.dart';
import 'package:agrimind/models/agent_log.dart';
import 'package:agrimind/services/api_service.dart';

class CouncilChatScreen extends StatefulWidget {
  const CouncilChatScreen({super.key});

  @override
  State<CouncilChatScreen> createState() => _CouncilChatScreenState();
}

class _CouncilChatScreenState extends State<CouncilChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();
  final List<AgentLog> _chatMessages = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AgriApiService _apiService = AgriApiService();

  // Color and name mappings for agents
  final Map<String, Color> _aiAgentColors = {
    'chairman': Colors.grey.shade800, 'dr_bio': Colors.grey.shade800,
    'prof_chem': Colors.grey.shade800, 'muh_tech': Colors.grey.shade800,
    'cfo': Colors.grey.shade800, 'critic': Colors.grey.shade800,
    'secretary': Colors.grey.shade800, 'user': Colors.blue.shade700,
    'default_ai': Colors.grey.shade800,
  };

  final Map<String, String> _aiAgentDisplayNames = {
    'chairman': 'Meclis Başkanı', 'dr_bio': 'Baş Ziraat Mühendisi',
    'prof_chem': 'Baş Kimyager', 'muh_tech': 'Teknik Lider',
    'cfo': 'Finans Müdürü', 'critic': 'Baş Denetçi',
    'secretary': 'Genel Sekreter', 'user': 'Ben',
  };

  @override
  void initState() {
    super.initState();
    _loadInitialChatMessages();
  }

  // Helper to show snackbar messages
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _loadInitialChatMessages() async {
    try {
      final response = await _apiService.getCouncilLog();
      if (response['status'] == 'success' && response['log'] is List) {
        setState(() {
          _chatMessages.clear();
          _chatMessages.addAll(response['log']
              .map<AgentLog>((item) => AgentLog.fromJson(item)));
        });
        _scrollToBottom();
      } else if (response['status'] != 'empty') {
        _showSnackBar('Konsey geçmişi yüklenemedi.', isError: true);
      }
    } catch (e) {
      _showSnackBar('API bağlantı hatası: $e', isError: true);
    }
  }

  void _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    final String userMessage = _chatInputController.text;
    // Add user message to UI immediately using the correct constructor
    setState(() {
       _chatMessages.add(AgentLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        agentId: 'user',
        timestamp: DateTime.now(),
        logType: 'message',
        message: userMessage,
        data: {},
      ));
      _chatInputController.clear();
    });
    _scrollToBottom();

    try {
      final bool success = await _apiService.sendCeoMessage(userMessage);
      if (success) {
        // After sending the message, trigger the council analysis
        _showSnackBar('Mesaj gönderildi, konsey tetikleniyor...');
        await _apiService.analyzePlant();
      } else {
        _showSnackBar('Mesaj gönderilemedi, API hatası.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Mesaj gönderme bağlantı hatası: $e', isError: true);
    }
  }
  
  void _scrollToBottom() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tüm Konsey Sohbeti', style: Theme.of(context).textTheme.displayLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialChatMessages,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) => _bubble(context, _chatMessages[index]),
            ),
          ),
          _buildChatInput(context),
        ],
      ),
    );
  }

  Widget _bubble(BuildContext context, AgentLog message) {
    final bool isUser = message.agentId == 'user';
    final Color bubbleColor = _aiAgentColors[message.agentId] ?? _aiAgentColors['default_ai']!;
    final String agentDisplayName = _aiAgentDisplayNames[message.agentId] ?? 'Bilinmeyen Ajan';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              agentDisplayName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4.0),
            Text(message.message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: AppTheme.cardColorLight,
      child: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _chatInputController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Mesajınızı yazın...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
                validator: (value) => (value == null || value.isEmpty) ? '' : null,
              ),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: _sendMessage,
              backgroundColor: AppTheme.primaryColor,
              mini: true,
              child: Icon(Icons.send, color: AppTheme.backgroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
