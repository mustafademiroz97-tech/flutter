import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart'; // AppTheme için eklendi
import '../services/api_service.dart'; // Rapor verilerini çekmek için eklendi

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AgriApiService _apiService = AgriApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 sekme: Saatlik, Günlük, Haftalık, Aylık
    // _loadReports(); // Raporları yüklemek için metod eklenecek
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Raporlar', style: Theme.of(context).textTheme.displayLarge), // Başlık
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelStyle: Theme.of(context).textTheme.displaySmall,
          unselectedLabelStyle: Theme.of(context).textTheme.headlineMedium,
          tabs: const [
            Tab(text: 'Saatlik'),
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHourlyReport(), // Saatlik Rapor Sekmesi
          _buildDailyReport(),  // Günlük Rapor Sekmesi
          _buildWeeklyReport(), // Haftalık Rapor Sekmesi
          _buildMonthlyReport(),// Aylık Rapor Sekmesi
        ],
      ),
    );
  }

  Widget _buildHourlyReport() {
    // Saatlik rapor içeriği burada olacak
    return const Center(
      child: Text('Saatlik Rapor İçeriği', style: TextStyle(color: Colors.white))
    );
  }

  Widget _buildDailyReport() {
    // Günlük rapor içeriği (mevcut günlük raporu adapte edebiliriz)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("GÜNLÜK AI RAPORU (Dinamik Tarih)", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              border: Border(left: BorderSide(color: AppTheme.primaryColor, width: 4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    Text("GENEL SAĞLIK SKORU: %98", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sistem stabil. Gece döngüsünde Raf-2'de %2 nem artışı gözlendi ancak fan müdahalesiyle giderildi. Yaprak genişleme hızı nominal değerlerin üzerinde.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // FOTOĞRAF GALERİSİ VE ANALİZLER (Dinamik hale gelecek)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("GÖRSEL HASAT (KAYDEDİLENLER)", style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12)),
              const Icon(Icons.filter_list, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),

          // Burada gerçek fotoğrafları ve analizleri API'den çekip göstereceğiz
          // Şimdilik boş bırakalım veya yer tutucu kullanalım.
          const Center(
            child: Text('Günlük Fotoğraf Arşivi ve Analizler', style: TextStyle(color: Colors.white70))
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    // Haftalık rapor içeriği burada olacak
    return const Center(
      child: Text('Haftalık Rapor İçeriği', style: TextStyle(color: Colors.white))
    );
  }

  Widget _buildMonthlyReport() {
    // Aylık rapor içeriği burada olacak
    return const Center(
      child: Text('Aylık Rapor İçeriği', style: TextStyle(color: Colors.white))
    );
  }
}
