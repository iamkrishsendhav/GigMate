import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
//  AdminLiveTrackingScreen — GigMate
//  Firestore-based real-time worker tracking
//  Features:
//   • Live worker list with online/offline status
//   • Current order & location info
//   • SOS alert banner
//   • Quick stats (online, on-delivery, idle)
//   • Search & filter workers
//   • Worker detail bottom sheet
// ─────────────────────────────────────────────

class AdminLiveTrackingScreen extends StatefulWidget {
  const AdminLiveTrackingScreen({super.key});

  @override
  State<AdminLiveTrackingScreen> createState() =>
      _AdminLiveTrackingScreenState();
}

class _AdminLiveTrackingScreenState extends State<AdminLiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  // ── Colors (GigMate theme)
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primaryLight = Color(0xFF14B8A6);
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _red = Color(0xFFEF4444);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _orange = Color(0xFFEA580C);

  // ── Tab controller
  late TabController _tabController;

  // ── Search & Filter
  final _searchCtrl = TextEditingController();
  String _searchQuery = "";
  String _filterStatus = "All"; // All, Online, Offline, On Delivery, SOS

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: Column(
          children: [
            // SOS Banner — streams from Firestore
            _buildSOSBanner(),
            _buildSearchBar(),
            _buildFilterChips(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWorkerList("all"),
                  _buildWorkerList("online"),
                  _buildWorkerList("offline"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SLIVER APP BAR
  // ─────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Live Tracking",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => setState(() {}),
          tooltip: "Refresh",
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: _buildStatsRow(),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  LIVE STATS ROW — from Firestore stream
  // ─────────────────────────────────────────
  Widget _buildStatsRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('workers').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int online = 0;
        int onDelivery = 0;
        int idle = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length;
          online =
              docs.where((d) => (d.data() as Map)['isOnline'] == true).length;
          onDelivery = docs
              .where((d) =>
                  (d.data() as Map)['currentOrderId'] != null &&
                  (d.data() as Map)['isOnline'] == true)
              .length;
          idle = online - onDelivery;
        }

        return Row(
          children: [
            _statPill("Total", total.toString(), Icons.people_outline_rounded,
                Colors.white70),
            _statDivider(),
            _statPill(
                "Online", online.toString(), Icons.circle, Colors.greenAccent),
            _statDivider(),
            _statPill("Delivering", onDelivery.toString(),
                Icons.delivery_dining_rounded, Colors.white),
            _statDivider(),
            _statPill(
                "Idle", idle.toString(), Icons.coffee_outlined, Colors.white70),
          ],
        );
      },
    );
  }

  Widget _statPill(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.25));

  // ─────────────────────────────────────────
  //  SOS ALERT BANNER — live stream
  // ─────────────────────────────────────────
  Widget _buildSOSBanner() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('alerts')
        .where('type', isEqualTo: 'SOS')
        .where('resolved', isEqualTo: false)
        .orderBy('time', descending: true)
        .limit(3)
        .snapshots(),
    builder: (context, snapshot) {

      // 🔄 Loading state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      // ❌ Error state
      if (snapshot.hasError) {
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Error loading SOS alerts",
            style: TextStyle(color: Colors.red),
          ),
        );
      }

      // 📭 Empty state
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const SizedBox.shrink();
      }

      final alerts = snapshot.data!.docs;

      return Container(
        color: _red.withOpacity(0.08),
        child: Column(
          children: [
            ...alerts.map((alert) {
              final data = alert.data() as Map<String, dynamic>;

              final lat = (data['lat'] ?? 0.0).toDouble();
              final lng = (data['lng'] ?? 0.0).toDouble();

              final time = data['time'] is Timestamp
                  ? (data['time'] as Timestamp).toDate()
                  : DateTime.now();

              return Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    // 🚨 Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: _red,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 📍 Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🚨 SOS ALERT",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _red,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Lat: ${lat.toStringAsFixed(4)}, "
                            "Lng: ${lng.toStringAsFixed(4)} • "
                            "${_timeAgo(time)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: _red,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Resolve Button
                    TextButton(
                      onPressed: () => _resolveSOSAlert(alert.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        backgroundColor: _red.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Resolve",
                        style: TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // 👇 spacing bottom
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

  Future<void> _resolveSOSAlert(String alertId) async {
    await FirebaseFirestore.instance
        .collection('alerts')
        .doc(alertId)
        .update({'resolved': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("SOS alert resolved ✅"),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ─────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "Search worker by name or ID...",
          hintStyle: const TextStyle(fontSize: 13, color: _textLight),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: _textLight),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = "");
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  FILTER CHIPS
  // ─────────────────────────────────────────
  Widget _buildFilterChips() {
    final filters = [
      {"label": "All", "icon": Icons.people_outline},
      {"label": "Online", "icon": Icons.circle},
      {"label": "On Delivery", "icon": Icons.delivery_dining_rounded},
      {"label": "Idle", "icon": Icons.coffee_outlined},
      {"label": "SOS", "icon": Icons.warning_amber_rounded},
    ];

    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final label = f["label"] as String;
            final icon = f["icon"] as IconData;
            final selected = _filterStatus == label;
            Color chipColor = _primary;
            if (label == "Online") chipColor = _green;
            if (label == "On Delivery") chipColor = _blue;
            if (label == "Idle") chipColor = _amber;
            if (label == "SOS") chipColor = _red;

            return GestureDetector(
              onTap: () => setState(() => _filterStatus = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? chipColor : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 13, color: selected ? Colors.white : _textMid),
                    const SizedBox(width: 5),
                    Text(label,
                        style: TextStyle(
                            color: selected ? Colors.white : _textMid,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _card,
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        labelColor: _primary,
        unselectedLabelColor: _textMid,
        indicatorColor: _primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: const [
          Tab(text: "All Workers"),
          Tab(text: "Online"),
          Tab(text: "Offline"),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WORKER LIST — Firestore StreamBuilder
  // ─────────────────────────────────────────
  Widget _buildWorkerList(String tabFilter) {
    Query query = FirebaseFirestore.instance.collection('workers');

    // Tab filter
    if (tabFilter == "online") {
      query = query.where('isOnline', isEqualTo: true);
    } else if (tabFilter == "offline") {
      query = query.where('isOnline', isEqualTo: false);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _primary));
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(tabFilter);
        }

        var workers =
            snapshot.data!.docs.map((d) => _WorkerData.fromDoc(d)).toList();

        // Apply chip filter
        if (_filterStatus == "Online") {
          workers = workers.where((w) => w.isOnline).toList();
        } else if (_filterStatus == "On Delivery") {
          workers = workers
              .where((w) => w.isOnline && w.currentOrderId != null)
              .toList();
        } else if (_filterStatus == "Idle") {
          workers = workers
              .where((w) => w.isOnline && w.currentOrderId == null)
              .toList();
        } else if (_filterStatus == "SOS") {
          workers = workers.where((w) => w.hasSOS).toList();
        }

        // Apply search
        if (_searchQuery.isNotEmpty) {
          workers = workers
              .where((w) =>
                  w.name.toLowerCase().contains(_searchQuery) ||
                  w.uid.toLowerCase().contains(_searchQuery))
              .toList();
        }

        // Sort: SOS first, then online, then offline
        workers.sort((a, b) {
          if (a.hasSOS && !b.hasSOS) return -1;
          if (!a.hasSOS && b.hasSOS) return 1;
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return a.name.compareTo(b.name);
        });

        if (workers.isEmpty) {
          return _buildEmptyState(tabFilter);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: workers.length,
          itemBuilder: (_, i) => _buildWorkerCard(workers[i]),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  WORKER CARD
  // ─────────────────────────────────────────
  Widget _buildWorkerCard(_WorkerData w) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (w.hasSOS) {
      statusColor = _red;
      statusText = "SOS Alert!";
      statusIcon = Icons.warning_amber_rounded;
    } else if (w.isOnline && w.currentOrderId != null) {
      statusColor = _blue;
      statusText = "On Delivery";
      statusIcon = Icons.delivery_dining_rounded;
    } else if (w.isOnline) {
      statusColor = _green;
      statusText = "Online • Idle";
      statusIcon = Icons.circle;
    } else {
      statusColor = _textLight;
      statusText = "Offline";
      statusIcon = Icons.circle_outlined;
    }

    return GestureDetector(
      onTap: () => _showWorkerDetail(w),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: w.hasSOS
              ? Border.all(color: _red.withOpacity(0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: w.hasSOS ? _red.withOpacity(0.1) : const Color(0x0A000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // ── Avatar
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor.withOpacity(0.12),
                        ),
                        child: w.photoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  w.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _avatarFallback(w.name, statusColor),
                                ),
                              )
                            : _avatarFallback(w.name, statusColor),
                      ),
                      // Online indicator dot
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // ── Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                w.name.isEmpty ? "Worker" : w.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: _textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _statusPill(statusText, statusColor, statusIcon),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          w.email.isEmpty ? "No email" : w.email,
                          style:
                              const TextStyle(fontSize: 12, color: _textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Vehicle & order row
                        Row(
                          children: [
                            _infoChip(Icons.two_wheeler_rounded, w.vehicleType),
                            const SizedBox(width: 8),
                            if (w.currentOrderId != null)
                              _infoChip(Icons.receipt_long_outlined,
                                  "#${w.currentOrderId}"),
                            if (w.lastSeen != null) ...[
                              const SizedBox(width: 8),
                              _infoChip(Icons.access_time_rounded,
                                  _timeAgo(w.lastSeen!)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right_rounded, color: _textLight),
                ],
              ),
            ),

            // ── Location bar (if online and has location)
            if (w.isOnline && w.lat != null && w.lng != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: _primary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "Lat: ${w.lat!.toStringAsFixed(4)}, "
                      "Lng: ${w.lng!.toStringAsFixed(4)}",
                      style: const TextStyle(fontSize: 11, color: _primary),
                    ),
                    const Spacer(),
                    // Open in Google Maps
                    GestureDetector(
                      onTap: () => _openInMaps(w.lat!, w.lng!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("Open Maps",
                            style: TextStyle(
                                fontSize: 10,
                                color: _primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── SOS bar
            if (w.hasSOS)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_rounded, color: _red, size: 14),
                    const SizedBox(width: 6),
                    const Text("Emergency SOS triggered!",
                        style: TextStyle(
                            fontSize: 11,
                            color: _red,
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _callWorker(w.phone),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("Call Now",
                            style: TextStyle(
                                fontSize: 10,
                                color: _red,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WORKER DETAIL BOTTOM SHEET
  // ─────────────────────────────────────────
  void _showWorkerDetail(_WorkerData w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: ctrl,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primary.withOpacity(0.1),
                    ),
                    child: w.photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(w.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarFallback(w.name, _primary)))
                        : _avatarFallback(w.name, _primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.name.isEmpty ? "Worker" : w.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: _textDark),
                        ),
                        Text(w.email,
                            style: const TextStyle(
                                fontSize: 13, color: _textLight)),
                      ],
                    ),
                  ),
                  _statusPill(
                    w.isOnline ? "Online" : "Offline",
                    w.isOnline ? _green : _textLight,
                    w.isOnline ? Icons.circle : Icons.circle_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // ── Stats
              Row(
                children: [
                  _detailStatCard("Orders", w.totalOrders.toString(), _primary),
                  const SizedBox(width: 10),
                  _detailStatCard(
                      "Rating", "${w.rating.toStringAsFixed(1)}⭐", _amber),
                  const SizedBox(width: 10),
                  _detailStatCard("Days", w.totalDays.toString(), _green),
                ],
              ),

              const SizedBox(height: 20),

              // ── Info rows
              _detailRow(Icons.phone_outlined, "Phone",
                  w.phone.isEmpty ? "Not added" : w.phone),
              _gap(),
              _detailRow(Icons.two_wheeler_rounded, "Vehicle",
                  "${w.vehicleType} ${w.vehicleNo.isNotEmpty ? '• ${w.vehicleNo}' : ''}"),
              _gap(),
              _detailRow(Icons.alternate_email_rounded, "UPI ID",
                  w.upiId.isEmpty ? "Not added" : w.upiId),
              _gap(),
              _detailRow(Icons.home_outlined, "Address",
                  w.address.isEmpty ? "Not added" : w.address),

              if (w.lat != null && w.lng != null) ...[
                _gap(),
                _detailRow(
                    Icons.location_on_outlined,
                    "Last Location",
                    "Lat: ${w.lat!.toStringAsFixed(5)}, "
                        "Lng: ${w.lng!.toStringAsFixed(5)}"),
              ],

              if (w.currentOrderId != null) ...[
                _gap(),
                _detailRow(Icons.receipt_long_outlined, "Current Order",
                    "#${w.currentOrderId}"),
              ],

              const SizedBox(height: 24),

              // ── Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callWorker(w.phone),
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text("Call",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleWorkerStatus(w),
                      icon: Icon(
                        w.isOnline
                            ? Icons.wifi_off_rounded
                            : Icons.wifi_rounded,
                        size: 18,
                      ),
                      label: Text(
                        w.isOnline ? "Go Offline" : "Go Online",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: w.isOnline ? _orange : _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),

              if (w.lat != null && w.lng != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openInMaps(w.lat!, w.lng!),
                    icon: const Icon(Icons.map_outlined,
                        color: _primary, size: 18),
                    label: const Text("Open Location in Maps",
                        style: TextStyle(
                            color: _primary, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: _primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  ADMIN ACTIONS
  // ─────────────────────────────────────────
  Future<void> _toggleWorkerStatus(_WorkerData w) async {
    Navigator.pop(context);
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(w.uid)
        .update({'isOnline': !w.isOnline});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("${w.name} marked as ${!w.isOnline ? 'Online' : 'Offline'}"),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  void _callWorker(String phone) {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No phone number available")),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Calling $phone..."),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openInMaps(double lat, double lng) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Opening maps: $lat, $lng"),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    // ✅ Add url_launcher for real maps:
    // final uri = Uri.parse(
    //   "https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    // launchUrl(uri);
  }

  // ─────────────────────────────────────────
  //  EMPTY & ERROR STATES
  // ─────────────────────────────────────────
  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: _primary, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            filter == "online"
                ? "No workers online right now"
                : filter == "offline"
                    ? "All workers are online!"
                    : "No workers found",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try changing the filter or search query",
            style: TextStyle(fontSize: 13, color: _textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: _textLight, size: 48),
          const SizedBox(height: 12),
          const Text("Failed to load workers",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => setState(() {}),
            child: const Text("Retry", style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  REUSABLE WIDGETS
  // ─────────────────────────────────────────
  Widget _avatarFallback(String name, Color color) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "W",
        style:
            TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _statusPill(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: _textLight),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: _textMid)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: _textLight)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 18, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 11, color: _textLight)),
          ],
        ),
      ),
    );
  }

  Widget _gap() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
      );

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}

// ─────────────────────────────────────────
//  WORKER DATA MODEL
// ─────────────────────────────────────────
class _WorkerData {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String vehicleType;
  final String vehicleNo;
  final String upiId;
  final String address;
  final bool isOnline;
  final bool hasSOS;
  final String? currentOrderId;
  final double? lat;
  final double? lng;
  final DateTime? lastSeen;
  final double rating;
  final int totalOrders;
  final int totalDays;

  const _WorkerData({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.vehicleType,
    required this.vehicleNo,
    required this.upiId,
    required this.address,
    required this.isOnline,
    required this.hasSOS,
    required this.rating,
    required this.totalOrders,
    required this.totalDays,
    this.currentOrderId,
    this.lat,
    this.lng,
    this.lastSeen,
  });

  factory _WorkerData.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _WorkerData(
      uid: doc.id,
      name: d['name'] ?? "",
      email: d['email'] ?? "",
      phone: d['phone'] ?? "",
      photoUrl: d['photoUrl'] ?? "",
      vehicleType: d['vehicleType'] ?? "Bike",
      vehicleNo: d['vehicleNo'] ?? "",
      upiId: d['upiId'] ?? "",
      address: d['address'] ?? "",
      isOnline: d['isOnline'] ?? false,
      hasSOS: d['hasSOS'] ?? false,
      currentOrderId: d['currentOrderId'],
      lat: (d['lat'] as num?)?.toDouble(),
      lng: (d['lng'] as num?)?.toDouble(),
      lastSeen: d['lastSeen'] is Timestamp
          ? (d['lastSeen'] as Timestamp).toDate()
          : null,
      rating: (d['rating'] ?? 4.8).toDouble(),
      totalOrders: d['totalOrders'] ?? 0,
      totalDays: d['totalDays'] ?? 0,
    );
  }
}
