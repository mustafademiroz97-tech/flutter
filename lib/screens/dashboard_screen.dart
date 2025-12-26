import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../models/mqtt_payload.dart';
import '../config/environment.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- YEREL VERİ DEPOSU ---
  double ph = 0.0;
  double ec = 0.0;
  double waterTemp = 0.0;
  double airTemp = 0.0;
  double humidity = 0.0;

  bool isFanOn = false;
  bool isAcOn = false;
  bool isLightOn = true;

  // Raf Verileri (Sıcaklık ve Nem Eklendi)
  List<Map<String, dynamic>> shelves = [
    {'id': 1, 'dli': 14.5, 'lux': 0.0, 'temp': 0.0, 'hum': 0.0},
    {'id': 2, 'dli': 13.8, 'lux': 0.0, 'temp': 0.0, 'hum': 0.0},
    {'id': 3, 'dli': 15.0, 'lux': 0.0, 'temp': 0.0, 'hum': 0.0},
    {'id': 4, 'dli': 0.0,  'lux': 0.0, 'temp': 0.0, 'hum': 0.0},
  ];

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  void _setupMqtt() {
    // Use MQTT broker from environment configuration
    MqttManager().connect(Environment.mqttBrokerHost);

    MqttManager().dataStream.listen((MqttSensorData data) {
      if (mounted) {
        setState(() {
          _updateLocalState(data);
        });
      }
    });
  }

  void _updateLocalState(MqttSensorData data) {
    // 1. ANA SENSÖRLER (Hydro & Main Rack)
    if (data.layer == 'hydro') {
      if (data.metric == 'ph') ph = data.value;
      if (data.metric == 'ec') ec = data.value;
      if (data.metric == 'water_temp') waterTemp = data.value;
    }

    if (data.layer == 'rack' && data.device == 'main') {
      if (data.metric == 'temp') airTemp = data.value;
      if (data.metric == 'hum') humidity = data.value;
    }

    // 2. RAF SENSÖRLERİ (Device: shelf_1, shelf_2...)
    if (data.device.startsWith('shelf_')) {
      try {
        int shelfIndex = int.parse(data.device.split('_')[1]) - 1;
        if (shelfIndex >= 0 && shelfIndex < 4) {
          // Lux verisi kaldırıldı, sadece DLI, sıcaklık ve nem.
          // if (data.metric == 'lux') shelves[shelfIndex]['lux'] = data.value;
          if (data.metric == 'temp') shelves[shelfIndex]['temp'] = data.value;
          if (data.metric == 'hum') shelves[shelfIndex]['hum'] = data.value;
          // DLI verisi doğrudan ESP32'den geliyorsa
          if (data.metric == 'dli') shelves[shelfIndex]['dli'] = data.value;
        }
      } catch (e) {
        print("Raf verisi hatası: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: StreamBuilder<bool>(
        stream: MqttManager().connectionStream,
        initialData: false,
        builder: (context, snapshot) {
          bool isConnected = snapshot.data ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSystemHeader(isConnected),
                const SizedBox(height: 20),

                Text("ANA KABİN & SU", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSensorCard("pH", ph.toStringAsFixed(1), "Hedef: 5.8", Colors.greenAccent)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSensorCard("EC", ec.toStringAsFixed(1), "mS/cm", Colors.cyanAccent)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildSensorCard("Su Isısı", "${waterTemp.toStringAsFixed(1)}°C", "Stabil", Colors.blueAccent)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSensorCard("Kabin Isı", "${airTemp.toStringAsFixed(1)}°C", "Nem: %${humidity.toStringAsFixed(0)}", Colors.orangeAccent)),
                  ],
                ),

                const SizedBox(height: 25),

                // RAF ANALİZİ (GÜNCEL: DLI Doğrudan ESP32'den)
                Text("RAF DETAYLARI (MİKRO İKLİM)", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                _buildShelfGrid(),

                const SizedBox(height: 25),

                Text("AKTİF DONANIMLAR", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDeviceStatus("Dolaşım", true, Icons.water_drop, null),
                    _buildDeviceStatus("Fan", isFanOn, Icons.wind_power, () {
                      MqttManager().toggleRelay("rack", "fan", !isFanOn);
                      setState(() => isFanOn = !isFanOn);
                    }),
                    _buildDeviceStatus("Klima", isAcOn, Icons.ac_unit, () {
                      setState(() => isAcOn = !isAcOn);
                    }),
                    _buildDeviceStatus("Işıklar", isLightOn, Icons.lightbulb, () {
                      MqttManager().toggleRelay("rack", "light", !isLightOn);
                      setState(() => isLightOn = !isLightOn);
                    }),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemHeader(bool isConnected) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00FF41).withOpacity(0.15), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.hub, color: isConnected ? const Color(0xFF00FF41) : Colors.red, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TURBO-30 CORE", style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                        color: isConnected ? const Color(0xFF00FF41) : Colors.red,
                        shape: BoxShape.circle
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                      isConnected ? "SYSTEM ONLINE" : "BAĞLANTI BEKLENİYOR...",
                      style: TextStyle(color: isConnected ? Colors.green : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShelfGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3, // Kart boyunu ayarladım, hepsi sığsın
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: shelves.length,
      itemBuilder: (context, index) {
        final shelf = shelves[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("RAF ${shelf['id']}", style: GoogleFonts.orbitron(color: Colors.white70, fontWeight: FontWeight.bold)),

              // 3'lü Veri Satırı (Isı, Nem, DLI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat("Isı", "${shelf['temp']}°", Colors.orange),
                  _miniStat("Nem", "%${shelf['hum']}", Colors.blue),
                  _miniStat("DLI", shelf['dli'].toStringAsFixed(1), const Color(0xFF00FF41)), // DLI'yı buraya taşıdık
                ],
              ),

              // Eski DLI Büyük Göstergesi kaldırıldı
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const Text("DLI Skoru", style: TextStyle(color: Colors.grey, fontSize: 10)),
              //     Text(shelf['dli'].toStringAsFixed(1), style: const TextStyle(color: const Color(0xFF00FF41), fontWeight: FontWeight.bold, fontSize: 20)),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)), // Increased font size
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)), // Increased font size
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDeviceStatus(String name, bool isActive, IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00FF41).withOpacity(0.2) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? const Color(0xFF00FF41) : Colors.red.withOpacity(0.3), width: 2),
              boxShadow: isActive ? [BoxShadow(color: const Color(0xFF00FF41).withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Icon(icon, color: isActive ? const Color(0xFF00FF41) : Colors.red, size: 20),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}