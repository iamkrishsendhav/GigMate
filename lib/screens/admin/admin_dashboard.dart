import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_orders_screen.dart';
import 'admin_workers_screen.dart';
import 'admin_profile_screen.dart';
// import 'admin_analytics_screen.dart';
import 'admin_live_tracking_screen.dart';
import 'admin_analytics_screen.dart';
import 'package:gigmate/services/order_service.dart';
import 'package:gigmate/services/user_service.dart';

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
    late final Widget child;
    switch (i) {
      case 0:
        child = const _OverviewTab();
        break;
      case 1:
        child = const AdminOrdersScreen();
        break;
      case 2:
        child = const AdminWorkersScreen();
        break;
      case 3:
        child = const AdminAnalyticsScreen();
        break;
      case 4:
        child = const AdminLiveTrackingScreen();
        break;
      default:
        child = const _OverviewTab();
    }

    return Material(color: Colors.transparent, child: child);
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
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Column(
                  children: [
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
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 28),
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
                      const SizedBox(height: 22),
                    ],
                    ...List.generate(_navItems.length,
                        (i) => _sideItem(_navItems[i], i, compact)),
                  ],
                ),
              ),
            ),
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
                    mainAxisSize: MainAxisSize.min,
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
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
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
              _showDetailedAlerts),
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

  void _showDetailedAlerts() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('time', descending: true)
            .limit(10)
            .snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: _red, size: 23),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Worker Alerts",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _textDark)),
                      SizedBox(height: 2),
                      Text("Worker, SOS and live location details",
                          style: TextStyle(
                              fontSize: 12,
                              color: _textLight,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: "Close",
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            content: SizedBox(
              width: 620,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 520),
                child: docs.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Center(
                          child: Text("No active alerts",
                              style: TextStyle(
                                  color: _textLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final doc = docs[i];
                          final data = doc.data() as Map;
                          final workerId =
                              (data['workerId'] ?? '').toString().trim();
                          if (workerId.isEmpty) {
                            return _alertCard(
                              alertRef: doc.reference,
                              alert: data,
                              workerId: null,
                              worker: null,
                            );
                          }
                          return StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('workers')
                                .doc(workerId)
                                .snapshots(),
                            builder: (_, workerSnap) => _alertCard(
                              alertRef: doc.reference,
                              alert: data,
                              workerId: workerId,
                              worker: workerSnap.data?.data(),
                            ),
                          );
                        },
                      ),
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
                child: const Text("Mark all read"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _alertCard({
    required DocumentReference alertRef,
    required Map alert,
    required String? workerId,
    required Map<String, dynamic>? worker,
  }) {
    final type = (alert['type'] ?? 'Alert').toString();
    final isSOS = type.toUpperCase() == 'SOS';
    final read = alert['read'] == true;
    final resolved = alert['resolved'] == true;
    final name = (worker?['name'] ??
            worker?['displayName'] ??
            worker?['fullName'] ??
            (workerId == null ? 'Unknown worker' : 'Worker'))
        .toString();
    final phone =
        (worker?['phone'] ?? worker?['mobile'] ?? 'Not available').toString();
    final email = (worker?['email'] ?? 'Not available').toString();
    final vehicle =
        (worker?['vehicleNo'] ?? worker?['vehicleNumber'] ?? 'Not available')
            .toString();
    final online = worker?['isOnline'] == true;
    final orderId =
        (alert['orderId'] ?? worker?['currentOrderId'] ?? '').toString();
    final lat = _doubleValue(worker?['lat']) ?? _doubleValue(alert['lat']);
    final lng = _doubleValue(worker?['lng']) ?? _doubleValue(alert['lng']);
    final locationText = lat != null && lng != null
        ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}'
        : 'Location not available';
    final accent = resolved ? _green : (isSOS ? _red : const Color(0xFFF59E0B));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: resolved ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isSOS ? Icons.emergency_rounded : Icons.warning_amber_rounded,
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${isSOS ? 'SOS Alert' : type} - $name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _miniStatus(
                          resolved ? 'Resolved' : (read ? 'Read' : 'New'),
                          resolved ? _green : (read ? _textLight : _red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _timeText(alert['time']),
                      style: const TextStyle(
                          color: _textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _alertInfoChip(
                  Icons.circle,
                  online ? 'Online now' : 'Offline/unknown',
                  online ? _green : _textLight),
              _alertInfoChip(Icons.location_on_rounded, locationText, _primary),
              if (orderId.isNotEmpty)
                _alertInfoChip(Icons.receipt_long_rounded, '#$orderId',
                    const Color(0xFF1D4ED8)),
            ],
          ),
          const SizedBox(height: 12),
          _alertDetailRow(Icons.badge_outlined, 'Worker ID',
              workerId?.isNotEmpty == true ? workerId! : 'Not attached'),
          _alertDetailRow(Icons.phone_outlined, 'Phone', phone),
          _alertDetailRow(Icons.mail_outline_rounded, 'Email', email),
          _alertDetailRow(Icons.two_wheeler_rounded, 'Vehicle', vehicle),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: lat == null || lng == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          setState(() => _tab = 4);
                        },
                  icon: const Icon(Icons.my_location_rounded, size: 17),
                  label: const Text('Live Tracking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => alertRef.update({'read': true}),
                child: const Text('Mark read'),
              ),
              TextButton(
                onPressed: () => _resolveAlert(alertRef, workerId),
                child: const Text('Resolve'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatus(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _alertInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _alertDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: _textLight, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 74,
            child: Text(label,
                style: const TextStyle(
                    color: _textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: _textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveAlert(DocumentReference alertRef, String? workerId) async {
    await alertRef.update({'read': true, 'resolved': true});
    if (workerId != null && workerId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .set({'hasSOS': false}, SetOptions(merge: true));
    }
  }

  static double? _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }

  static String _timeText(dynamic value) {
    DateTime? date;
    if (value is Timestamp) date = value.toDate();
    if (value is DateTime) date = value;
    if (date == null) return 'Time not available';
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year}, $hour:$minute $period';
  }

  void _adminMenu() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "admin@gigmate.com";

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF093D38), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          child: const Icon(Icons.admin_panel_settings_rounded,
                              color: Colors.white, size: 34),
                        ),
                        const SizedBox(height: 12),
                        const Text("Admin",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _adminMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: "Admin Profile",
                    subtitle: "View profile, role and access details",
                    color: _primary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AdminProfileScreen()));
                    },
                  ),
                  _adminMenuTile(
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    subtitle: "Manage admin controls",
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Navigator.pop(context);
                      _QuickActionsGrid.openSettings(context);
                    },
                  ),
                  _adminMenuTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out from this admin session",
                    color: _red,
                    onTap: () {
                      Navigator.pop(context);
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 20),
            ],
          ),
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
          _RecentActivityV2(),

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
          stream: FirebaseFirestore.instance.collection('workers').snapshots(),
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
            final onBreak = workers.where((w) {
              final data = w.data() as Map;
              return data['isOnBreak'] == true || data['status'] == 'break';
            }).length;
            final assignedOrders = orders.where((o) {
              final data = o.data() as Map;
              final workerId = data['assignedWorkerId'] ??
                  data['workerId'] ??
                  data['acceptedBy'];
              return workerId != null && workerId.toString().isNotEmpty;
            }).length;
            final pendingOrders = orders
                .where((o) => (o.data() as Map)['status'] == 'pending')
                .length;
            final offlineWorkers = workers.length - activeWorkers;

            final width = MediaQuery.of(context).size.width;
            final crossAxisCount = width < 680 ? 1 : 2;
            final aspectRatio = width < 680
                ? 2.7
                : width < 1100
                    ? 2.8
                    : 3.3;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _KpiCard(
                  icon: Icons.receipt_long_rounded,
                  label: "Total Orders",
                  value: "$totalOrders",
                  sub: "All time",
                  gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  onTap: () => _showKpiDetails(
                    context,
                    title: "Total Orders",
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF0F766E),
                    rows: [
                      _KpiDetail("All orders", "$totalOrders"),
                      _KpiDetail("Pending", "$pendingOrders"),
                      _KpiDetail("Assigned", "$assignedOrders"),
                      _KpiDetail("Delivered", "$delivered"),
                    ],
                  ),
                ),
                _KpiCard(
                  icon: Icons.people_alt_rounded,
                  label: "Active Workers",
                  value: "$activeWorkers",
                  sub: "$onBreak on break",
                  gradient: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  onTap: () => _showKpiDetails(
                    context,
                    title: "Active Workers",
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF1D4ED8),
                    rows: [
                      _KpiDetail("Online now", "$activeWorkers"),
                      _KpiDetail("On break", "$onBreak"),
                      _KpiDetail("Offline", "$offlineWorkers"),
                      _KpiDetail("Registered workers", "${workers.length}"),
                    ],
                  ),
                ),
                _KpiCard(
                  icon: Icons.check_circle_outline,
                  label: "Delivered",
                  value: "$delivered",
                  sub: totalOrders > 0
                      ? "${((delivered / totalOrders) * 100).toStringAsFixed(0)}% success"
                      : "0%",
                  gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                  onTap: () => _showKpiDetails(
                    context,
                    title: "Delivered Orders",
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF10B981),
                    rows: [
                      _KpiDetail("Delivered", "$delivered"),
                      _KpiDetail(
                        "Success rate",
                        totalOrders > 0
                            ? "${((delivered / totalOrders) * 100).toStringAsFixed(0)}%"
                            : "0%",
                      ),
                      _KpiDetail("Total orders", "$totalOrders"),
                      _KpiDetail("Still open", "${totalOrders - delivered}"),
                    ],
                  ),
                ),
                _KpiCard(
                  icon: Icons.people_outline_rounded,
                  label: "Total Workers",
                  value: "${workers.length}",
                  sub: "Registered",
                  gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  onTap: () => _showKpiDetails(
                    context,
                    title: "Total Workers",
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    rows: [
                      _KpiDetail("Registered", "${workers.length}"),
                      _KpiDetail("Active", "$activeWorkers"),
                      _KpiDetail("On break", "$onBreak"),
                      _KpiDetail("Offline", "$offlineWorkers"),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void _showKpiDetails(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_KpiDetail> rows,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...rows.map((row) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                row.label,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              row.value,
                              style: TextStyle(
                                color: color,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiDetail {
  final String label;
  final String value;
  const _KpiDetail(this.label, this.value);
}

// ── Recent activity (real Firestore alerts + orders)
class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('alerts')
          .orderBy('time', descending: true)
          .limit(3)
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
class _RecentActivityV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('alerts')
          .orderBy('time', descending: true)
          .limit(5)
          .snapshots(),
      builder: (_, alertSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .limit(3)
              .snapshots(),
          builder: (_, orderSnap) {
            final activities = <_ActivityItem>[
              ...(alertSnap.data?.docs ?? []).map((doc) {
                final data = doc.data() as Map;
                final type = (data['type'] ?? 'Alert').toString();
                final isSOS = type.toUpperCase() == 'SOS';
                return _ActivityItem(
                  title: isSOS ? 'SOS Alert' : type,
                  subtitle:
                      'Lat: ${_numText(data['lat'])}, Lng: ${_numText(data['lng'])}',
                  icon: isSOS
                      ? Icons.emergency_rounded
                      : Icons.warning_amber_rounded,
                  color:
                      isSOS ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                  time: _asDate(data['time']),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AdminLiveTrackingScreen())),
                );
              }),
              ...(orderSnap.data?.docs ?? []).map((doc) {
                final data = doc.data() as Map;
                final status = (data['status'] ?? 'pending').toString();
                final pickup = (data['pickup'] ?? 'Pickup pending').toString();
                final drop = (data['drop'] ?? 'Drop pending').toString();
                return _ActivityItem(
                  title: 'Order ${_niceStatus(status)}',
                  subtitle: '$pickup -> $drop',
                  icon: Icons.receipt_long_rounded,
                  color: _statusColor(status),
                  time: _asDate(data['createdAt']),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AdminOrdersScreen())),
                );
              }),
            ]..sort((a, b) => b.time.compareTo(a.time));

            final visible = activities.take(3).toList();
            if (visible.isEmpty) return _emptyActivity();
            return Column(
              children: visible.map((item) => _activityTile(item)).toList(),
            );
          },
        );
      },
    );
  }

  static Widget _emptyActivity() {
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

  static Widget _activityTile(_ActivityItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withOpacity(0.18)),
      ),
      child: ListTile(
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.color, size: 21),
        ),
        title: Text(item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A))),
        subtitle: Text(item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF94A3B8), size: 18),
      ),
    );
  }

  static DateTime _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _numText(dynamic value) {
    if (value is num) return value.toStringAsFixed(3);
    return '0.000';
  }

  static String _niceStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'picked':
      case 'on_the_way':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF0F766E);
    }
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime time;
  final VoidCallback onTap;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
    required this.onTap,
  });
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.add_box_rounded, "New Order", const Color(0xFF0F766E),
          () => _newOrder(context)),
      _QA(Icons.person_add_rounded, "Add Worker", const Color(0xFF1D4ED8),
          () => _addWorker(context)),
      _QA(Icons.download_rounded, "Export", const Color(0xFF10B981),
          () => _exportData(context)),
      _QA(Icons.notifications_active_rounded, "Broadcast",
          const Color(0xFFF59E0B), () => _broadcast(context)),
      _QA(
          Icons.map_rounded,
          "Live Map",
          const Color(0xFFEA580C),
          () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AdminLiveTrackingScreen()))),
      _QA(Icons.settings_rounded, "Settings", const Color(0xFF6366F1),
          () => openSettings(context)),
    ];

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 640
        ? 2
        : width < 1000
            ? 3
            : 3;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: width < 640 ? 1.28 : 2.0,
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
    final distanceCtrl = TextEditingController();
    final etaCtrl = TextEditingController();
    final chargeCtrl = TextEditingController();
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _inputField("Distance (km)", distanceCtrl,
                          Icons.near_me_outlined),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _inputField(
                          "ETA (min)", etaCtrl, Icons.schedule_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _inputField("Delivery charge", chargeCtrl,
                    Icons.currency_rupee_rounded),
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
                      if (pickupCtrl.text.isEmpty || dropCtrl.text.isEmpty) {
                        return;
                      }
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
                        distance: double.tryParse(distanceCtrl.text.trim()),
                        eta: int.tryParse(etaCtrl.text.trim()),
                        deliveryCharge: double.tryParse(chargeCtrl.text.trim()),
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
                      if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) {
                        return;
                      }
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
                      final workerId =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      await UserService().createUser(
                        uid: workerId,
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        role: "worker",
                      );
                      await FirebaseFirestore.instance
                          .collection('workers')
                          .doc(workerId)
                          .set({
                        'phone': phoneCtrl.text.trim(),
                        'vehicleType': vehicle,
                        'status': 'Active',
                        'updatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
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

  static Future<void> _exportData(BuildContext context) async {
    String exportType = 'Worker details';
    final types = [
      'Worker details',
      'Worker history',
      'Order history',
      'Payments summary',
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const Text("Export Center",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text("Generate CSV-style operational reports.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              const SizedBox(height: 18),
              ...types.map((type) => RadioListTile<String>(
                    value: type,
                    groupValue: exportType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF0F766E),
                    title: Text(type,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(_exportSubtitle(type),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B))),
                    onChanged: (value) => setSt(() => exportType = value!),
                  )),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final csv = await _buildExport(exportType);
                    await Clipboard.setData(ClipboardData(text: csv));
                    await FirebaseFirestore.instance
                        .collection('admin_exports')
                        .add({
                      'type': exportType,
                      'rows': csv.split('\n').length - 1,
                      'createdAt': FieldValue.serverTimestamp(),
                      'createdBy':
                          FirebaseAuth.instance.currentUser?.email ?? 'Admin',
                    });
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                    _snack(context, "$exportType copied and logged");
                  },
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.white, size: 18),
                  label: const Text("Generate Export",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _exportSubtitle(String type) {
    switch (type) {
      case 'Worker history':
        return 'Orders, online state, ratings and last activity.';
      case 'Order history':
        return 'Pickup, drop, status, charge and assignment data.';
      case 'Payments summary':
        return 'Delivery charge, tips, bonus and deductions.';
      default:
        return 'Name, email, phone, vehicle and account status.';
    }
  }

  static Future<String> _buildExport(String type) async {
    if (type == 'Order history' || type == 'Payments summary') {
      final snap = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();
      final header = type == 'Payments summary'
          ? 'orderId,workerId,charge,tip,bonus,deduction,status'
          : 'orderId,pickup,drop,status,workerId,distance,eta,charge';
      final rows = snap.docs.map((doc) {
        final d = doc.data();
        if (type == 'Payments summary') {
          return [
            doc.id,
            d['assignedWorkerId'] ?? d['workerId'] ?? '',
            d['deliveryCharge'] ?? d['charge'] ?? 0,
            d['tip'] ?? 0,
            d['bonus'] ?? 0,
            d['deduction'] ?? 0,
            d['status'] ?? '',
          ].map(_csv).join(',');
        }
        return [
          doc.id,
          d['pickup'] ?? '',
          d['drop'] ?? '',
          d['status'] ?? '',
          d['assignedWorkerId'] ?? d['workerId'] ?? '',
          d['distance'] ?? 0,
          d['eta'] ?? 0,
          d['deliveryCharge'] ?? d['charge'] ?? 0,
        ].map(_csv).join(',');
      });
      return ([header, ...rows]).join('\n');
    }

    final snap = await FirebaseFirestore.instance
        .collection('workers')
        .orderBy('name')
        .limit(500)
        .get();
    final header = type == 'Worker history'
        ? 'workerId,name,totalOrders,rating,isOnline,currentOrderId,lastSeen'
        : 'workerId,name,email,phone,vehicleType,vehicleNo,status';
    final rows = snap.docs.map((doc) {
      final d = doc.data();
      if (type == 'Worker history') {
        return [
          doc.id,
          d['name'] ?? '',
          d['totalOrders'] ?? 0,
          d['rating'] ?? 0,
          d['isOnline'] ?? false,
          d['currentOrderId'] ?? '',
          d['lastSeen'] ?? d['updatedAt'] ?? '',
        ].map(_csv).join(',');
      }
      return [
        doc.id,
        d['name'] ?? '',
        d['email'] ?? '',
        d['phone'] ?? '',
        d['vehicleType'] ?? '',
        d['vehicleNo'] ?? '',
        d['status'] ?? '',
      ].map(_csv).join(',');
    });
    return ([header, ...rows]).join('\n');
  }

  static String _csv(Object? value) {
    final text =
        value is Timestamp ? value.toDate().toIso8601String() : '$value';
    return '"${text.replaceAll('"', '""')}"';
  }

  static void openSettings(BuildContext context) {
    bool autoAssign = true;
    bool sosAlerts = true;
    bool maintenance = false;
    bool requireId = true;
    bool liveTracking = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        Widget tile(String title, String sub, bool value, ValueChanged<bool> fn,
            IconData icon) {
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF0F766E),
            secondary: Icon(icon, color: const Color(0xFF0F766E)),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(sub,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            value: value,
            onChanged: (v) => setSt(() => fn(v)),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const Text("Admin Settings",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                tile(
                    "Auto assign orders",
                    "Assign new orders to available workers.",
                    autoAssign,
                    (v) => autoAssign = v,
                    Icons.route_rounded),
                tile("SOS alert escalation", "Keep emergency alerts prominent.",
                    sosAlerts, (v) => sosAlerts = v, Icons.sos_rounded),
                tile("Live tracking", "Show online workers on the live map.",
                    liveTracking, (v) => liveTracking = v, Icons.map_rounded),
                tile("ID verification", "Require worker ID and profile checks.",
                    requireId, (v) => requireId = v, Icons.badge_rounded),
                tile(
                    "Maintenance mode",
                    "Pause worker actions during maintenance.",
                    maintenance,
                    (v) => maintenance = v,
                    Icons.build_rounded),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('admin_settings')
                          .doc('global')
                          .set({
                        'autoAssign': autoAssign,
                        'sosAlerts': sosAlerts,
                        'maintenance': maintenance,
                        'requireId': requireId,
                        'liveTracking': liveTracking,
                        'updatedAt': FieldValue.serverTimestamp(),
                        'updatedBy':
                            FirebaseAuth.instance.currentUser?.email ?? 'Admin',
                      }, SetOptions(merge: true));
                      if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                      _snack(context, "Settings saved");
                    },
                    icon: const Icon(Icons.save_rounded,
                        color: Colors.white, size: 18),
                    label: const Text("Save Settings",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
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
                    final workers = await FirebaseFirestore.instance
                        .collection('workers')
                        .get();
                    final batch = FirebaseFirestore.instance.batch();
                    final broadcastRef = FirebaseFirestore.instance
                        .collection('broadcasts')
                        .doc();
                    batch.set(broadcastRef, {
                      'message': msgCtrl.text.trim(),
                      'time': FieldValue.serverTimestamp(),
                      'sentBy': 'Admin',
                      'sentByEmail':
                          FirebaseAuth.instance.currentUser?.email ?? '',
                      'audience': 'all_workers',
                      'workerCount': workers.docs.length,
                    });
                    for (final worker in workers.docs) {
                      batch.set(
                        FirebaseFirestore.instance
                            .collection('workers')
                            .doc(worker.id)
                            .collection('notifications')
                            .doc(broadcastRef.id),
                        {
                          'broadcastId': broadcastRef.id,
                          'message': msgCtrl.text.trim(),
                          'type': 'broadcast',
                          'read': false,
                          'createdAt': FieldValue.serverTimestamp(),
                        },
                      );
                    }
                    await batch.commit();
                    Navigator.pop(context);
                    _snack(context,
                        "Broadcast sent to ${workers.docs.length} workers");
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
  final VoidCallback? onTap;
  const _KpiCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.sub,
      required this.gradient,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
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
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(sub,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
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
