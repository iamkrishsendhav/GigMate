import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../core/responsive.dart';
import 'delivery_list_screen.dart';
import 'navigation_screen.dart';
import 'health_status_screen.dart';
import 'break_reminder_screen.dart';

class WorkerDashboard extends StatelessWidget {
  const WorkerDashboard({super.key});

  static const String emergencyPhone = "tel:+919876543210";
  static const String emergencySmsNumber = "sms:+919876543210";

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildActiveDeliveryCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: "Today Orders",
                        value: "12",
                        icon: Icons.local_shipping_outlined,
                        gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: "Completed",
                        value: "08",
                        icon: Icons.check_circle_outline,
                        gradient: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: "Break Left",
                        value: "18m",
                        icon: Icons.timer_outlined,
                        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: "Health",
                        value: "Good",
                        icon: Icons.favorite_outline,
                        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GridView.count(
                  crossAxisCount: isMobile ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _actionCard(
                      context,
                      title: "Deliveries",
                      subtitle: "My orders",
                      icon: Icons.inventory_2_outlined,
                      screen: const DeliveryListScreen(),
                    ),
                    _actionCard(
                      context,
                      title: "Navigation",
                      subtitle: "Live route",
                      icon: Icons.route_outlined,
                      screen: const NavigationScreen(),
                    ),
                    _actionCard(
                      context,
                      title: "Health",
                      subtitle: "Body stats",
                      icon: Icons.favorite_outline,
                      screen: const HealthStatusScreen(),
                    ),
                    _actionCard(
                      context,
                      title: "Break",
                      subtitle: "Rest timer",
                      icon: Icons.coffee_outlined,
                      screen: const BreakReminderScreen(),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Alerts",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    _alertTile(
                      title: "Take a short break",
                      subtitle: "You have been active for 1h 45m",
                      icon: Icons.timer_outlined,
                      color: const Color(0xFFEA580C),
                    ),
                    const SizedBox(height: 12),
                    _alertTile(
                      title: "Traffic ahead",
                      subtitle: "Route may take 10 min extra",
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Container(
      //   margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      //   height: 62,
      //   decoration: BoxDecoration(
      //     gradient: const LinearGradient(
      //       colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
      //     ),
      //     borderRadius: BorderRadius.circular(18),
      //     boxShadow: const [
      //       BoxShadow(
      //         color: Color(0x33DC2626),
      //         blurRadius: 18,
      //         offset: Offset(0, 8),
      //       ),
      //     ],
      //   ),
      //   child: TextButton.icon(
      //     onPressed: () => _showSOSDialog(context),
      //     icon: const Icon(Icons.emergency_outlined, color: Colors.white),
      //     label: const Text(
      //       "SOS Emergency",
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         fontWeight: FontWeight.w700,
      //       ),
      //     ),
      //   ),
      // ),
      bottomNavigationBar: Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  child: SizedBox(
    height: 56,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
      ),
      onPressed: () => _showSOSDialog(context),
      icon: const Icon(Icons.emergency, color: Colors.white),
      label: const Text(
        "SOS Emergency",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
  ),
),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Morning, Worker 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Ready for today's deliveries",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You are 2 orders away from today's target",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDeliveryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
  BoxShadow(
    color: Color(0x12000000),
    blurRadius: 12,
    offset: Offset(0, 6),
  ),
],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF0F766E)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Active Delivery",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Order #108 • Restaurant A to Sector 15",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              _statusPill("On the way", const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: _MiniInfo(title: "ETA", value: "15 min")),
              SizedBox(width: 10),
              Expanded(child: _MiniInfo(title: "Distance", value: "3.2 km")),
              SizedBox(width: 10),
              Expanded(child: _MiniInfo(title: "Stops", value: "1")),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: 0.62,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _statCard({
  //   required String title,
  //   required String value,
  //   required IconData icon,
  //   required List<Color> gradient,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(colors: gradient),
  //       borderRadius: BorderRadius.circular(22),
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Color(0x22000000),
  //           blurRadius: 14,
  //           offset: Offset(0, 8),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 40,
  //           height: 40,
  //           decoration: BoxDecoration(
  //             color: Colors.white.withOpacity(0.16),
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           child: Icon(icon, color: Colors.white),
  //         ),
  //         const SizedBox(height: 18),
  //         Text(
  //           value,
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 24,
  //             fontWeight: FontWeight.w900,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             color: Colors.white70,
  //             fontSize: 13,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _statCard({
  required String title,
  required String value,
  required IconData icon,
  required List<Color> gradient,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget screen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 10,
  offset: Offset(0, 4),
),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF0F766E)),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

  Future<void> _showSOSDialog(BuildContext context) async {
    final position = await _getCurrentLocation();
    final latitude = position?.latitude ?? 0.0;
    final longitude = position?.longitude ?? 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("SOS Emergency"),
            ],
          ),
          content: const Text(
            "Emergency options are available. Choose one action below.",
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final uri = Uri.parse(emergencyPhone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.call, color: Colors.red),
              label: const Text("Call"),
            ),
            TextButton.icon(
              onPressed: () async {
                final message =
                    "Emergency alert from Delivery Plus worker.\nLocation: https://www.google.com/maps?q=$latitude,$longitude";
                final uri = Uri.parse("$emergencySmsNumber?body=${Uri.encodeComponent(message)}");
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.sms, color: Colors.red),
              label: const Text("SMS"),
            ),
            TextButton.icon(
              onPressed: () async {
                final shareText =
                    "My current location: https://www.google.com/maps?q=$latitude,$longitude";
                final uri = Uri.parse(
                  "https://wa.me/?text=${Uri.encodeComponent(shareText)}",
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.share, color: Colors.red),
              label: const Text("Share"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Admin alert sent successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text("Alert Admin"),
            ),
          ],
        );
      },
    );
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {
      return null;
    }
  }
}

class _MiniInfo extends StatelessWidget {
  final String title;
  final String value;

  const _MiniInfo({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}