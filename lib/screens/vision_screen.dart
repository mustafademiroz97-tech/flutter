import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import '../services/api_service.dart';
import 'full_screen_control_page.dart';

/// A screen to display the camera preview, a gallery, and trigger analysis.
class VisionScreen extends StatelessWidget {
  const VisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgriApiService api = AgriApiService();

    // A helper function to show a snackbar message
    void _showSnackBar(String message, {bool isError = false}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }

    // Function to handle the analysis request
    void _handleAnalysis() async {
      try {
        final response = await api.analyzePlant();
        if (response['status'] == 'success') {
          _showSnackBar('Analiz başlatıldı ve konseye gönderildi.');
        } else {
          _showSnackBar(response['message'] ?? 'Bilinmeyen bir hata oluştu.', isError: true);
        }
      } catch (e) {
        _showSnackBar('Analiz başlatılamadı: $e', isError: true);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Text(
                "GÖZCÜ KULESİ",
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Canlı yayın ve drone kontrol merkezi.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // --- LIVE CAMERA PREVIEW ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FullScreenControlPage(),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00FF41), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Mjpeg(
                      isLive: true,
                      stream: api.videoStreamUrl,
                      fit: BoxFit.cover,
                      error: (context, error, stack) {
                        print("MJPEG Error: $error");
                        print("MJPEG Stack: $stack");
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Yayın hatası: $error",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- CAPTURE & ANALYZE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleAnalysis,
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  label: Text(
                    "FOTOĞRAF ÇEK & ANALİZ ET",
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF41),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- PHOTO GALLERY ---
              Text(
                "FOTOĞRAF ARŞİVİ",
                style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: api.fetchGallery(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Hata: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "Arşivde fotoğraf yok.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    final gallery = snapshot.data!;
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            gallery[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
