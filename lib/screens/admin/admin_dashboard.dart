import 'package:flutter/material.dart';
import 'admin_orders_screen.dart';
import 'admin_workers_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    AdminOrdersScreen(),
    AdminWorkersScreen(),
    AdminAnalyticsScreen(),
  ];

  final List<String> titles = const [
    "Orders",
    "Workers",
    "Analytics",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 900)
              _buildSideMenu(context),

            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: screens[selectedIndex],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 900
          ? _buildBottomNav()
          : null,
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            "Admin Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Delivery_plus",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),
          _sideItem(Icons.inventory_2_outlined, "Orders", 0),
          _sideItem(Icons.people_alt_outlined, "Workers", 1),
          _sideItem(Icons.analytics_outlined, "Analytics", 2),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "System Status",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "All services active",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideItem(IconData icon, String label, int index) {
    final bool selected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => selectedIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white.withOpacity(0.20) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Container(
      padding: EdgeInsets.fromLTRB(isCompact ? 16 : 24, 18, isCompact ? 16 : 24, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          if (isCompact)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF0D9488),
                child: Text(
                  titles[selectedIndex][0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[selectedIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Monitor deliveries, workers and performance in real time",
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          if (!isCompact) ...[
            _topChip("Live", Colors.green),
            const SizedBox(width: 10),
            _topChip("3 Alerts", Colors.red),
            const SizedBox(width: 10),
          ],
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE2E8F0),
            child: const Icon(Icons.person, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _topChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, -4)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: const Color(0xFF0D9488),
        unselectedItemColor: const Color(0xFF94A3B8),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: "Workers"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Analytics"),
        ],
      ),
    );
  }
}