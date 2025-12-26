import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class FullScreenControlPage extends StatefulWidget {
  const FullScreenControlPage({super.key});

  @override
  State<FullScreenControlPage> createState() => _FullScreenControlPageState();
}

class _FullScreenControlPageState extends State<FullScreenControlPage> {
  final AgriApiService api = AgriApiService();
  Timer? _joystickTimer;
  String _currentDirection = 'stop';

  @override
  void dispose() {
    // Ensure the timer is cancelled and a final 'stop' command is sent
    _joystickTimer?.cancel();
    if (_currentDirection != 'stop') {
      api.moveCamera('stop');
    }
    super.dispose();
  }

  // A helper function to show a snackbar message
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Function to handle the analysis request
  void _handleAnalysis() async {
    try {
      final response = await api.analyzePlant();
      if (!mounted) return;
      if (response['status'] == 'success') {
        _showSnackBar('Analiz başlatıldı ve konseye gönderildi.');
        Navigator.pop(context); // Go back to the previous screen after starting analysis
      } else {
        _showSnackBar(response['message'] ?? 'Bilinmeyen bir hata oluştu.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Analiz başlatılamadı: $e', isError: true);
    }
  }

  // Starts a timer to repeatedly send movement commands
  void _startJoystickMovement(String direction) {
    // If the direction is the same, do nothing
    if (_currentDirection == direction) return;
    
    _currentDirection = direction;
    // Cancel any existing timer
    _joystickTimer?.cancel();
    // Send the command immediately
    if(direction != 'stop') {
      api.moveCamera(direction);
    }
    // Then start a timer to send it repeatedly every 500ms
    _joystickTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentDirection != 'stop') {
        api.moveCamera(_currentDirection);
      } else {
        timer.cancel();
      }
    });
  }

  // Stops the movement timer
  void _stopJoystickMovement() {
     if (_currentDirection == 'stop') return;
    _joystickTimer?.cancel();
    _currentDirection = 'stop';
    // Send one final stop command to the server to be safe
    api.moveCamera('stop'); 
  }

  // Determines the direction from joystick details
  void _onJoystickMove(StickDragDetails details) {
    String newDirection = 'stop';
    if (details.x.abs() > details.y.abs()) {
      if (details.x > 0.5) newDirection = 'right';
      else if (details.x < -0.5) newDirection = 'left';
    } else {
      if (details.y > 0.5) newDirection = 'down'; // Joystick's y is inverted
      else if (details.y < -0.5) newDirection = 'up';
    }
    _startJoystickMovement(newDirection);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen MJPEG stream, ensuring it covers the screen
          Positioned.fill(
            child: Mjpeg(
              isLive: true,
              stream: api.videoStreamUrl,
              fit: BoxFit.cover, // Use BoxFit.cover to fill the entire screen
              error: (context, error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videocam_off, color: Colors.grey, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      'Video akışı yüklenemedi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button and Title
          Positioned(
            top: 40, // Adjusted for SafeArea
            left: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00FF41), size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                Text("CANLI KONTROL",
                    style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          
          // --- CONTROLS ---
          // Main analysis button at the bottom center
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: _buildAnalysisButton(),
            ),
          ),

          // Joystick for control
          Positioned(
            bottom: 80,
            right: 30,
            child: Joystick(
              listener: _onJoystickMove,
              onStickDragEnd: (_) => _stopJoystickMovement(),
              stick: const JoystickStick(
                decoration: BoxDecoration(
                  color: Color(0xFF00FF41),
                  shape: BoxShape.circle
                )
              ),
              base: const JoystickBase(
                 decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                     border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFF00FF41), width: 2)
                    )
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the analysis button for cleaner code
  Widget _buildAnalysisButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _handleAnalysis,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00FF41),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 35),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "ANALİZ ET",
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [const Shadow(blurRadius: 2.0, color: Colors.black)]
          ),
        )
      ],
    );
  }
}
