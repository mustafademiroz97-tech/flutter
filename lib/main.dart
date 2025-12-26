import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agrimind/config/theme.dart'; // Import the new AppTheme
import 'screens/dashboard_screen.dart';
import 'screens/agent_list_screen.dart';
import 'screens/vision_screen.dart';
import 'screens/report_screen.dart';
import 'screens/control_screen.dart';

void main() {
  runApp(const AgriMindApp());
}

class AgriMindApp extends StatelessWidget {
  const AgriMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Mind AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Use the new AppTheme.darkTheme
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AgentListScreen(),
    const VisionScreen(),
    const ReportScreen(),
    const ControlScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: AppTheme.primaryColor), // Use theme color
            const SizedBox(width: 10),
            Text(
              "AGRI-MIND AI",
              style: Theme.of(context).textTheme.displayLarge, // Use theme text style
            ),
          ],
        ),
        // Remove hardcoded background and elevation, use theme values
        // backgroundColor: Colors.black,
        // elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1), // Use theme color
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.primaryColor), // Use theme color
            ),
            child: Text("ONLINE", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor)), // Use theme text style and color
          )
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        // Remove hardcoded theme data, use AppTheme.darkTheme's navigationBarTheme
        height: 70,
        // backgroundColor: const Color(0xFF0A0A0A),
        // indicatorColor: const Color(0xFF00FF41).withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Theme.of(context).colorScheme.primary), // Use theme color
            label: 'KOKPİT',
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum, color: Theme.of(context).colorScheme.secondary), // Use theme color
            label: 'AI KONSEYİ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.videocam_outlined),
            selectedIcon: Icon(Icons.videocam, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)), // Use theme color
            label: 'GÖZCÜ',
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)), // Use theme color
            label: 'RAPOR',
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)), // Use theme color
            label: 'KONTROL',
          ),
        ],
      ),
    );
  }
}