import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
//  AdminWorkersScreen — GigMate Pro
//  Features: Search · Status filter · Worker cards · Health / SOS
// ═══════════════════════════════════════════════════════════════════

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {

  static const Color _primary   = Color(0xFF0F766E);
  static const Color _textDark  = Color(0xFF0F172A);
  static const Color _textMid   = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _red       = Color(0xFFEF4444);
  static const Color _green     = Color(0xFF10B981);
  static const Color _amber     = Color(0xFFF59E0B);
  static const Color _blue      = Color(0xFF3B82F6);

  String _searchQuery    = "";
  String _selectedFilter = "All";
  final _searchCtrl = TextEditingController();

  final List<String> _filters = ["All", "Active", "On Break", "Offline", "SOS"];

  final List<_Worker> _workers = const [
    _Worker("W01", "Ravi Kumar",    "ravi@gigmate.com",  "+91 98765 43210",
        "Active",   "Bike",   "Sector 15",  4.8, 168, "Good",   false, "2.3 km"),
    _Worker("W02", "Priya Sharma",  "priya@gigmate.com", "+91 87654 32109",
        "On Break", "Scooter","Sector 22",  4.6, 142, "Good",   false, "0.0 km"),
    _Worker("W03", "Mohit Verma",   "mohit@gigmate.com", "+91 76543 21098",
        "Offline",  "Bike",   "—",          4.3, 98,  "Tired",  false, "—"),
    _Worker("W04", "Arjun Singh",   "arjun@gigmate.com", "+91 65432 10987",
        "Active",   "Cycle",  "Sector 8",   4.9, 210, "Good",   false, "1.1 km"),
    _Worker("W05", "Neha Gupta",    "neha@gigmate.com",  "+91 54321 09876",
        "SOS",      "Bike",   "Sector 30",  4.5, 87,  "Critical", true, "5.2 km"),
    _Worker("W06", "Deepak Yadav",  "deepak@gigmate.com","+91 43210 98765",
        "Active",   "Scooter","Sector 11",  4.7, 156, "Good",   false, "3.0 km"),
  ];

  List<_Worker> get _filtered {
    return _workers.where((w) {
      final matchFilter = _selectedFilter == "All" ||
          w.status == _selectedFilter;
      final matchSearch = _searchQuery.isEmpty ||
          w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case "Active":   return _green;
      case "On Break": return _amber;
      case "Offline":  return _textLight;
      case "SOS":      return _red;
      default:         return _textLight;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case "Active":   return Icons.check_circle_rounded;
      case "On Break": return Icons.coffee_rounded;
      case "Offline":  return Icons.wifi_off_rounded;
      case "SOS":      return Icons.emergency_rounded;
      default:         return Icons.circle_rounded;
    }
  }

  Color _healthColor(String h) {
    switch (h) {
      case "Good":     return _green;
      case "Tired":    return _amber;
      case "Critical": return _red;
      default:         return _textLight;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosList = _workers.where((w) => w.hasSOS).toList();

    return Column(
      children: [

        // ── SOS banner (if any)
        if (sosList.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emergency_rounded,
                    color: Color(0xFFEF4444), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "🚨 SOS from ${sosList.map((w) => w.name).join(', ')}",
                    style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _selectedFilter = "SOS"),
                  child: const Text("View",
                      style: TextStyle(color: Color(0xFFEF4444))),
                ),
              ],
            ),
          ),

        // ── Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: "Search workers by name or location...",
              hintStyle: const TextStyle(
                  fontSize: 13, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF94A3B8), size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = "");
                      })
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),

        // ── Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final sel = f == _selectedFilter;
                final hasSOS = f == "SOS" &&
                    _workers.any((w) => w.hasSOS);
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? (f == "SOS" ? _red : _primary)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: sel
                              ? Colors.transparent
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(f,
                            style: TextStyle(
                                color: sel ? Colors.white : _textMid,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        if (hasSOS) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Count row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_filtered.length} workers",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textMid)),
              GestureDetector(
                onTap: () => _showAddWorkerDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text("Add Worker",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Worker list
        Expanded(
          child: _filtered.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildWorkerCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(_Worker w) {
    final sColor = _statusColor(w.status);
    final hColor = _healthColor(w.health);
    final isSOS  = w.hasSOS;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isSOS
                ? _red.withOpacity(0.3)
                : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: isSOS
                ? _red.withOpacity(0.06)
                : const Color(0x07000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with status dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _primary.withOpacity(0.1),
                      child: Text(
                        w.name[0],
                        style: const TextStyle(
                            color: _primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 13, height: 13,
                        decoration: BoxDecoration(
                          color: sColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Name + info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(w.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark)),
                          if (isSOS) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _red,
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: const Text("SOS",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(_statusIcon(w.status),
                              size: 12, color: sColor),
                          const SizedBox(width: 4),
                          Text(w.status,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: sColor,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 10),
                          Icon(Icons.two_wheeler_rounded,
                              size: 12, color: _textLight),
                          const SizedBox(width: 4),
                          Text(w.vehicle,
                              style: const TextStyle(
                                  fontSize: 12, color: _textLight)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rating
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(w.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Stats strip
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _workerStat(Icons.receipt_long_rounded,
                    "${w.totalOrders}", "Orders"),
                _divider(),
                _workerStat(Icons.favorite_outline,
                    w.health, "Health",
                    color: hColor),
                _divider(),
                _workerStat(Icons.near_me_outlined,
                    w.distance, "Distance"),
                _divider(),
                _workerStat(Icons.place_outlined,
                    w.location, "Location"),
              ],
            ),
          ),

          // ── Actions
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _wActionBtn(
                    Icons.call_rounded, "Call", _green, onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Calling ${w.name}...")),
                  );
                }),
                const SizedBox(width: 8),
                _wActionBtn(
                    Icons.message_outlined, "Message", _blue,
                    onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Messaging ${w.name}...")),
                  );
                }),
                const SizedBox(width: 8),
                _wActionBtn(
                    Icons.info_outline, "Details", _primary,
                    filled: true, onTap: () {
                  _showWorkerDetails(w);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workerStat(IconData icon, String value, String label,
      {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 14,
              color: color ?? const Color(0xFF94A3B8)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color ?? _textDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 32, color: const Color(0xFFE2E8F0));

  Widget _wActionBtn(IconData icon, String label, Color color,
      {bool filled = false, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: filled
                ? color
                : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14,
                  color: filled ? Colors.white : color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text("No workers found",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8))),
          ],
        ),
      );

  void _showAddWorkerDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Add worker form coming soon")),
    );
  }

  void _showWorkerDetails(_Worker w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: ctrl,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999)),
                ),
              ),
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Text(w.name[0],
                      style: const TextStyle(
                          color: _primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(w.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                  Text(w.id,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 20),
              _detailRow("Email", w.email),
              _detailRow("Phone", w.phone),
              _detailRow("Status", w.status),
              _detailRow("Vehicle", w.vehicle),
              _detailRow("Rating", "${w.rating}"),
              _detailRow("Total Orders", "${w.totalOrders}"),
              _detailRow("Health", w.health),
              _detailRow("Location", w.location),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(key,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF94A3B8))),
          ),
          Expanded(
            child: Text(val,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }
}

// ── Worker model
class _Worker {
  final String  id, name, email, phone, status, vehicle,
      location, health, distance;
  final double  rating;
  final int     totalOrders;
  final bool    hasSOS;
  const _Worker(this.id, this.name, this.email, this.phone,
      this.status, this.vehicle, this.location, this.rating,
      this.totalOrders, this.health, this.hasSOS, this.distance);
}