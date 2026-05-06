import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_orders_screen.dart';
import 'admin_workers_screen.dart';
// import 'admin_analytics_screen.dart';
import 'admin_live_tracking_screen.dart';
import 'admin_analytics_screen.dart' hide AdminLiveTrackingScreen;
import 'package:gigmate/services/order_service.dart';
import 'package:gigmate/services/user_service.dart';
import 'package:gigmate/models/order_model.dart';
import 'package:gigmate/models/user_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  AdminDashboard — GigMate Pro
//  Fully functional: Overview · Orders · Workers · Analytics · Live
// ═══════════════════════════════════════════════════════════════════

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // ── Tokens
  static const _primary = Color(0xFF0F766E);
  static const _bg = Color(0xFFF0F4F8);
  static const _textDark = Color(0xFF0F172A);
  static const _textLight = Color(0xFF94A3B8);
  static const _red = Color(0xFFEF4444);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);

  int _tab = 0;
  int _alertCount = 0;

  static const _navItems = [
    _NavItem(Icons.dashboard_rounded, 'Overview'),
    _NavItem(Icons.receipt_long_rounded, 'Orders'),
    _NavItem(Icons.people_alt_rounded, 'Workers'),
    _NavItem(Icons.bar_chart_rounded, 'Analytics'),
    _NavItem(Icons.location_on_rounded, 'Tracking'),
  ];

  @override
  void initState() {
    super.initState();
    _listenAlerts();
  }

  void _listenAlerts() {
    FirebaseFirestore.instance
        .collection('alerts')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _alertCount = snap.docs.length);
    });
  }

  Widget _screen(int i) {
    switch (i) {
      case 0:
        return const _OverviewTab();
      case 1:
        return const AdminOrdersScreen();
      case 2:
        return const AdminWorkersScreen();
      case 3:
        return const AdminAnalyticsScreen();
      case 4:
        return const AdminLiveTrackingScreen();
      default:
        return const _OverviewTab();
    }
  }

  // ═══ BUILD ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 900;

    return Scaffold(
      backgroundColor: _bg,
      drawer: isMobile ? Drawer(child: _sidebar(compact: false)) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile) _sidebar(compact: w < 1100),
            Expanded(
              child: Column(
                children: [
                  _topBar(isMobile),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (c, a) =>
                          FadeTransition(opacity: a, child: c),
                      child: KeyedSubtree(
                          key: ValueKey(_tab), child: _screen(_tab)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile ? _bottomNav() : null,
    );
  }

  // ═══ SIDEBAR ═════════════════════════════════════════════════════
  Widget _sidebar({required bool compact}) {
    return Container(
      width: compact ? 68 : 236,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF093D38), Color(0xFF0F766E), Color(0xFF0EA5E9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          if (!compact) ...[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            const Text("GigMate",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900)),
            const Text("Admin Panel",
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 32),
          ] else ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.local_shipping_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(height: 24),
          ],
          ...List.generate(
              _navItems.length, (i) => _sideItem(_navItems[i], i, compact)),
          const Spacer(),
          if (!compact)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text("System Online",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                    ]),
                    const SizedBox(height: 6),
                    const Text("All services active",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _logout,
                      child: const Row(children: [
                        Icon(Icons.logout_rounded,
                            color: Colors.white54, size: 15),
                        SizedBox(width: 6),
                        Text("Logout",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12)),
                      ]),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _logout,
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white54, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sideItem(_NavItem item, int idx, bool compact) {
    final sel = _tab == idx;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: 3),
      child: InkWell(
        onTap: () {
          setState(() => _tab = idx);
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: sel ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border:
                sel ? Border.all(color: Colors.white.withOpacity(0.3)) : null,
          ),
          child: compact
              ? Icon(item.icon, color: Colors.white, size: 22)
              : Row(children: [
                  Icon(item.icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item.label,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w500)),
                  ),
                  if (idx == 1 && _alertCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(999)),
                      child: Text("$_alertCount",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                ]),
        ),
      ),
    );
  }

  // ═══ TOP BAR ═════════════════════════════════════════════════════
  Widget _topBar(bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
                builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu_rounded),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    )),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_navItems[_tab].label,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.3)),
                const Text("GigMate Admin Panel",
                    style: TextStyle(fontSize: 11, color: _textLight)),
              ],
            ),
          ),
          _chip("● Live", _green, null),
          const SizedBox(width: 8),
          _chip("🔔 $_alertCount", _alertCount > 0 ? _red : _textLight,
              _showAlerts),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _adminMenu,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                shape: BoxShape.circle,
                border:
                    Border.all(color: _primary.withOpacity(0.25), width: 1.5),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: _primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t, Color c, VoidCallback? fn) => GestureDetector(
        onTap: fn,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: c.withOpacity(0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.withOpacity(0.2)),
          ),
          child: Text(t,
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      );

  // ═══ BOTTOM NAV ══════════════════════════════════════════════════
  Widget _bottomNav() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          selectedItemColor: _primary,
          unselectedItemColor: _textLight,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle:
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: _navItems
              .map((n) => BottomNavigationBarItem(
                  icon: Icon(n.icon, size: 22), label: n.label))
              .toList(),
        ),
      );

  // ═══ DIALOGS ═════════════════════════════════════════════════════
  void _showAlerts() {
    showDialog(
      context: context,
      builder: (_) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('time', descending: true)
            .limit(10)
            .snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 8),
              Text("Alerts", style: TextStyle(fontWeight: FontWeight.w800)),
            ]),
            content: SizedBox(
              width: 320,
              child: docs.isEmpty
                  ? const Text("No active alerts 🎉")
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: docs.map((d) {
                        final data = d.data() as Map;
                        final type = data['type'] ?? 'Alert';
                        final time = data['time'];
                        return ListTile(
                          leading: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle),
                          ),
                          title: Text(type,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              time != null ? "Reported recently" : "—",
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF94A3B8))),
                          trailing: TextButton(
                            onPressed: () {
                              d.reference.update({'read': true});
                            },
                            child: const Text("Dismiss",
                                style: TextStyle(fontSize: 11)),
                          ),
                        );
                      }).toList(),
                    ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    for (final d in docs) {
                      d.reference.update({'read': true});
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Clear all")),
            ],
          );
        },
      ),
    );
  }

  void _adminMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999)),
            ),
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFF0F766E),
              child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            const Text("Admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? "admin@gigmate.com",
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              title: const Text("Logout",
                  style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout?",
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text("Sure you want to logout?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI cards (real-time from Firestore)
          _RealtimeKpiGrid(),

          const SizedBox(height: 24),

          // ── Recent activity
          const _SectionTitle("Recent Activity"),
          const SizedBox(height: 12),
          _RecentActivity(),

          const SizedBox(height: 24),

          // ── Quick actions
          const _SectionTitle("Quick Actions"),
          const SizedBox(height: 12),
          _QuickActionsGrid(),
        ],
      ),
    );
  }
}

// ── Real-time KPI grid
class _RealtimeKpiGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (_, ordSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'worker')
              .snapshots(),
          builder: (_, wrkSnap) {
            final orders = ordSnap.data?.docs ?? [];
            final workers = wrkSnap.data?.docs ?? [];

            final totalOrders = orders.length;
            final delivered = orders
                .where((o) => (o.data() as Map)['status'] == 'delivered')
                .length;
            final activeWorkers = workers
                .where((w) => (w.data() as Map)['isOnline'] == true)
                .length;
            final onBreak = workers
                .where((w) => (w.data() as Map)['currentOrderId'] == null)
                .length;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _KpiCard(
                  icon: Icons.receipt_long_rounded,
                  label: "Total Orders",
                  value: "$totalOrders",
                  sub: "All time",
                  gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                _KpiCard(
                  icon: Icons.people_alt_rounded,
                  label: "Active Workers",
                  value: "$activeWorkers",
                  sub: "$onBreak on break",
                  gradient: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                ),
                _KpiCard(
                  icon: Icons.check_circle_outline,
                  label: "Delivered",
                  value: "$delivered",
                  sub: totalOrders > 0
                      ? "${((delivered / totalOrders) * 100).toStringAsFixed(0)}% success"
                      : "0%",
                  gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                ),
                _KpiCard(
                  icon: Icons.people_outline_rounded,
                  label: "Total Workers",
                  value: "${workers.length}",
                  sub: "Registered",
                  gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Recent activity (real Firestore alerts + orders)
class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('alerts')
          .orderBy('time', descending: true)
          .limit(5)
          .snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text("No recent activity",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            ),
          );
        }
        return Column(
          children: docs.map((d) {
            final data = d.data() as Map;
            final type = data['type'] ?? 'Alert';
            final isSOS = type == 'SOS';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSOS
                        ? const Color(0xFFEF4444).withOpacity(0.2)
                        : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSOS
                          ? const Color(0xFFEF4444).withOpacity(0.1)
                          : const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSOS
                          ? Icons.emergency_rounded
                          : Icons.warning_amber_rounded,
                      color: isSOS
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFF59E0B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSOS ? "🚨 SOS Alert" : type,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Lat: ${(data['lat'] ?? 0.0).toStringAsFixed(3)}, "
                          "Lng: ${(data['lng'] ?? 0.0).toStringAsFixed(3)}",
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8), size: 18),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Quick actions grid — functional
class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.add_box_rounded, "New Order", const Color(0xFF0F766E),
          () => _newOrder(context)),
      _QA(Icons.person_add_rounded, "Add Worker", const Color(0xFF1D4ED8),
          () => _addWorker(context)),
      _QA(Icons.download_rounded, "Export", const Color(0xFF10B981),
          () => _snack(context, "Export coming soon")),
      _QA(Icons.notifications_active_rounded, "Broadcast",
          const Color(0xFFF59E0B), () => _broadcast(context)),
      _QA(Icons.map_rounded, "Live Map", const Color(0xFFEA580C),
          () => _snack(context, "Open maps")),
      _QA(Icons.settings_rounded, "Settings", const Color(0xFF6366F1),
          () => _snack(context, "Settings coming soon")),
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions
          .map((a) => GestureDetector(
                onTap: a.fn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(a.icon, color: a.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(a.label,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  static void _snack(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));

  static void _newOrder(BuildContext context) {
    final pickupCtrl = TextEditingController();
    final dropCtrl = TextEditingController();
    String priority = "Normal";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const Text("Create New Order",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                _inputField(
                    "Pickup Location", pickupCtrl, Icons.location_on_outlined),
                const SizedBox(height: 12),
                _inputField("Drop Location", dropCtrl, Icons.flag_outlined),
                const SizedBox(height: 16),
                const Text("Priority",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Row(
                  children: ["Low", "Normal", "High"].map((p) {
                    final sel = priority == p;
                    final c = p == "High"
                        ? const Color(0xFFEF4444)
                        : p == "Low"
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F766E);
                    return GestureDetector(
                      onTap: () => setSt(() => priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? c : c.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                color: sel ? Colors.white : c,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (pickupCtrl.text.isEmpty || dropCtrl.text.isEmpty)
                        return;
                      // await FirebaseFirestore.instance
                      //     .collection('orders')
                      //     .add({
                      //   'pickup': pickupCtrl.text.trim(),
                      //   'drop': dropCtrl.text.trim(),
                      //   'priority': priority,
                      //   'status': 'Pending',
                      //   'worker': 'Unassigned',
                      //   'payment': 'Unpaid',
                      //   'createdAt': FieldValue.serverTimestamp(),
                      //   'eta': '—',
                      //   'distance': '—',
                      //   'progress': 0.0,
                      // });
                      await OrderService().createOrder(
                        pickup: pickupCtrl.text.trim(),
                        drop: dropCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      _snack(context, "✅ Order created successfully!");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Create Order",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  static void _addWorker(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String vehicle = "Bike";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const Text("Add New Worker",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                _inputField("Full Name", nameCtrl, Icons.person_outline),
                const SizedBox(height: 12),
                _inputField("Email", emailCtrl, Icons.email_outlined,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _inputField("Phone", phoneCtrl, Icons.phone_outlined,
                    type: TextInputType.phone),
                const SizedBox(height: 16),
                const Text("Vehicle Type",
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569))),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        ["Bike", "Scooter", "Cycle", "Car", "Van"].map((v) {
                      final sel = vehicle == v;
                      return GestureDetector(
                        onTap: () => setSt(() => vehicle = v),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF0F766E)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(v,
                              style: TextStyle(
                                  color: sel
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty)
                        return;
                      // await FirebaseFirestore.instance
                      //     .collection('workers')
                      //     .add({
                      //   'name': nameCtrl.text.trim(),
                      //   'email': emailCtrl.text.trim(),
                      //   'phone': phoneCtrl.text.trim(),
                      //   'vehicleType': vehicle,
                      //   'status': 'Active',
                      //   'rating': 5.0,
                      //   'totalOrders': 0,
                      //   'health': 'Good',
                      //   'joinDate': 'May 2026',
                      //   'photoUrl': '',
                      //   'role': 'worker',
                      //   'createdAt': FieldValue.serverTimestamp(),
                      // });
                      await UserService().createUser(
                        uid: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        role: "worker",
                      );
                      Navigator.pop(ctx);
                      _snack(context, "✅ Worker added successfully!");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Add Worker",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  static void _broadcast(BuildContext context) {
    final msgCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const Text("Broadcast Message",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text("Send a message to all active workers",
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              const SizedBox(height: 20),
              TextField(
                controller: msgCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Type your message here...",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (msgCtrl.text.isEmpty) return;
                    await FirebaseFirestore.instance
                        .collection('broadcasts')
                        .add({
                      'message': msgCtrl.text.trim(),
                      'time': FieldValue.serverTimestamp(),
                      'sentBy': 'Admin',
                    });
                    Navigator.pop(context);
                    _snack(context, "📢 Broadcast sent to all workers!");
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text("Send Broadcast",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sheetHandle() => Center(
        child: Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999)),
        ),
      );

  static Widget _inputField(
      String hint, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: const Color(0xFF0F766E), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ── Section title
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.2));
}

// ── KPI card
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final List<Color> gradient;
  const _KpiCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.sub,
      required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: gradient.last.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const Icon(Icons.trending_up_rounded,
                  color: Colors.white54, size: 16),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(sub,
                  style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick action model
class _QA {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback fn;
  const _QA(this.icon, this.label, this.color, this.fn);
}

// ── Nav item model
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
