import 'package:agrimind/screens/vision_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agrimind/config/theme.dart';
import 'package:agrimind/models/agent_log.dart';
import 'package:agrimind/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:convert';

class IntelligenceScreen extends StatefulWidget {
  final String agentId;
  final String agentDisplayName;

  const IntelligenceScreen({
    super.key,
    required this.agentId,
    required this.agentDisplayName,
  });

  @override
  State<IntelligenceScreen> createState() => _IntelligenceScreenState();
}

class _IntelligenceScreenState extends State<IntelligenceScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatInputController = TextEditingController();
  final List<AgentLog> _chatMessages = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AgriApiService _apiService = AgriApiService();

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
    _connectMqttAndSubscribe();
    _loadInitialChatMessages();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _connectMqttAndSubscribe() async {
    try {
      await _apiService.connectMqtt();
      _apiService.mqttClient.subscribe('agrimind/camera/analysis', MqttQos.atLeastOnce);
      _apiService.mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _handleMqttMessage(message);
      });
    } catch (e) {
      _showSnackBar('MQTT bağlantı hatası: $e', isError: true);
    }
  }

  void _handleMqttMessage(String message) {
    try {
      final jsonMsg = jsonDecode(message);
      setState(() {
        // Assuming the MQTT message is a valid AgentLog JSON
        _chatMessages.add(AgentLog.fromJson(jsonMsg));
      });
      _scrollToBottom();
    } catch (e) {
      print('Error parsing MQTT message: $e');
    }
  }

  Future<void> _loadInitialChatMessages() async {
    try {
      final response = await _apiService.getCouncilLog();
      if (response['status'] == 'success' && response['log'] is List) {
        setState(() {
          _chatMessages.clear();
           _chatMessages.addAll(response['log']
              .map<AgentLog>((item) => AgentLog.fromJson(item))
              .where((log) => log.agentId == widget.agentId || log.agentId == 'user'));
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
    // UI update is handled by the MQTT listener, no need to add it here
    
    try {
      final bool success = await _apiService.sendCeoMessage(userMessage);
      if (success) {
        _chatInputController.clear();
        // After sending, trigger the council analysis
        await _apiService.analyzePlant();
      } else {
        _showSnackBar('Mesaj gönderilemedi, MQTT hatası.', isError: true);
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
    _apiService.disconnectMqtt();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agentDisplayName, style: Theme.of(context).textTheme.displayLarge),
         actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisionScreen()),
              );
            },
          ),
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
    final String agentDisplayName = _aiAgentDisplayNames[message.agentId] ?? widget.agentDisplayName;

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
