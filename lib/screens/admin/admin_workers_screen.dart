import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _red = Color(0xFFEF4444);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _blue = Color(0xFF3B82F6);

  final _searchCtrl = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";
  final List<String> _filters = ["All", "Active", "On Break", "Offline", "SOS"];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _stateMessage(Icons.error_outline, "Failed to load workers");
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

        final workers = snapshot.data!.docs
            .map((doc) => _Worker.fromDoc(doc.id, doc.data()))
            .where(_matches)
            .toList();
        final sosList = workers.where((w) => w.hasSOS).toList();

          return Column(
            children: [
            if (sosList.isNotEmpty) _sosBanner(sosList),
            _searchBar(),
            _filterRow(snapshot.data!.docs
                .map((doc) => _Worker.fromDoc(doc.id, doc.data()))
                .any((w) => w.hasSOS)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${workers.length} workers",
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _textMid)),
                  TextButton.icon(
                    onPressed: () => _showAddWorkerDialog(),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    label: const Text("Add Worker"),
                    style: TextButton.styleFrom(foregroundColor: _primary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: workers.isEmpty
                  ? _stateMessage(Icons.people_outline_rounded,
                      "No workers found")
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: workers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _workerCard(workers[i]),
                    ),
            ),
            ],
          );
        },
      ),
    );
  }

  bool _matches(_Worker w) {
    final matchFilter = _selectedFilter == "All" || w.status == _selectedFilter;
    final q = _searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        w.name.toLowerCase().contains(q) ||
        w.id.toLowerCase().contains(q) ||
        w.location.toLowerCase().contains(q) ||
        w.phone.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }

  Widget _sosBanner(List<_Worker> workers) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: _red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "SOS active: ${workers.map((w) => w.name).join(', ')}",
              style: const TextStyle(
                  color: _red, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedFilter = "SOS"),
            child: const Text("View", style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        decoration: InputDecoration(
          hintText: "Search workers by name, phone or location",
          prefixIcon: const Icon(Icons.search_rounded, color: _textLight),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = "");
                  },
                ),
          filled: true,
          fillColor: Colors.white,
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
    );
  }

  Widget _filterRow(bool hasSOS) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((f) {
            final selected = f == _selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(f),
                    if (f == "SOS" && hasSOS) ...[
                      const SizedBox(width: 5),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: _red, shape: BoxShape.circle),
                      ),
                    ],
                  ],
                ),
                selected: selected,
                selectedColor: f == "SOS" ? _red : _primary,
                labelStyle: TextStyle(
                    color: selected ? Colors.white : _textMid,
                    fontWeight: FontWeight.w700),
                onSelected: (_) => setState(() => _selectedFilter = f),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _workerCard(_Worker w) {
    final statusColor = _statusColor(w.status);
    final healthColor = _healthColor(w.health);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: w.hasSOS ? _red.withOpacity(0.35) : const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _primary.withOpacity(0.1),
                      backgroundImage:
                          w.photoUrl.isNotEmpty ? NetworkImage(w.photoUrl) : null,
                      child: w.photoUrl.isEmpty
                          ? Text(w.initial,
                              style: const TextStyle(
                                  color: _primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(w.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: _textDark)),
                          ),
                          if (w.hasSOS) _badge("SOS", _red),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _inlineMeta(_statusIcon(w.status), w.status, statusColor),
                          _inlineMeta(Icons.two_wheeler_rounded, w.vehicle, _textLight),
                        ],
                      ),
                    ],
                  ),
                ),
                _ratingPill(w.rating),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _workerStat(Icons.receipt_long_rounded, "${w.totalOrders}", "Orders"),
                _divider(),
                _workerStat(Icons.favorite_outline, w.health, "Health",
                    color: healthColor),
                _divider(),
                _workerStat(Icons.place_outlined, w.location, "Location"),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _actionBtn(Icons.call_rounded, "Call", _green),
                const SizedBox(width: 8),
                _actionBtn(Icons.message_outlined, "Message", _blue),
                const SizedBox(width: 8),
                _actionBtn(Icons.info_outline, "Details", _primary,
                    filled: true, onTap: () => _showWorkerDetails(w)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineMeta(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(text,
            style:
                TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _ratingPill(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 13, color: _amber),
          const SizedBox(width: 3),
          Text(rating.toStringAsFixed(1),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: _amber)),
        ],
      ),
    );
  }

  Widget _workerStat(IconData icon, String value, String label, {Color? color}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 15, color: color ?? _textLight),
          const SizedBox(height: 4),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color ?? _textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: _textLight)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: const Color(0xFFE2E8F0));

  Widget _actionBtn(IconData icon, String label, Color color,
      {bool filled = false, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: filled ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: filled ? Colors.white : color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: filled ? Colors.white : color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateMessage(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(text,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: _textLight)),
        ],
      ),
    );
  }

  void _showAddWorkerDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Create workers from the Add Worker action on Dashboard")),
    );
  }

  void _showWorkerDetails(_Worker w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.58,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: ctrl,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
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
                  backgroundImage:
                      w.photoUrl.isNotEmpty ? NetworkImage(w.photoUrl) : null,
                  child: w.photoUrl.isEmpty
                      ? Text(w.initial,
                          style: const TextStyle(
                              color: _primary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900))
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                        Text(w.id,
                            style:
                                const TextStyle(color: _textLight, fontSize: 12)),
                      ]),
                ),
              ]),
              const SizedBox(height: 20),
              _detailRow("Email", w.email),
              _detailRow("Phone", w.phone),
              _detailRow("Status", w.status),
              _detailRow("Vehicle", w.vehicle),
              _detailRow("Rating", w.rating.toStringAsFixed(1)),
              _detailRow("Total Orders", "${w.totalOrders}"),
              _detailRow("Health", w.health),
              _detailRow("Location", w.location),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(key,
                style: const TextStyle(fontSize: 13, color: _textLight)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Active":
        return _green;
      case "On Break":
        return _amber;
      case "SOS":
        return _red;
      default:
        return _textLight;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "Active":
        return Icons.check_circle_rounded;
      case "On Break":
        return Icons.coffee_rounded;
      case "SOS":
        return Icons.emergency_rounded;
      default:
        return Icons.wifi_off_rounded;
    }
  }

  Color _healthColor(String health) {
    switch (health) {
      case "Good":
        return _green;
      case "Tired":
        return _amber;
      case "Critical":
        return _red;
      default:
        return _textLight;
    }
  }
}

class _Worker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String vehicle;
  final String location;
  final String health;
  final double rating;
  final int totalOrders;
  final bool hasSOS;
  final String photoUrl;

  const _Worker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.vehicle,
    required this.location,
    required this.health,
    required this.rating,
    required this.totalOrders,
    required this.hasSOS,
    required this.photoUrl,
  });

  String get initial => name.isEmpty ? "W" : name[0].toUpperCase();

  factory _Worker.fromDoc(String id, Map<String, dynamic> data) {
    final hasSOS = data['hasSOS'] == true || data['sos'] == true;
    final isOnBreak = data['isOnBreak'] == true || data['status'] == 'break';
    final isOnline = data['isOnline'] == true;
    final status = hasSOS
        ? "SOS"
        : isOnBreak
            ? "On Break"
            : isOnline
                ? "Active"
                : "Offline";
    return _Worker(
      id: id,
      name: (data['name'] ?? data['displayName'] ?? 'Worker').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? data['mobile'] ?? '').toString(),
      status: status,
      vehicle: (data['vehicle'] ?? data['vehicleType'] ?? 'Vehicle').toString(),
      location: (data['location'] ?? data['area'] ?? 'Not shared').toString(),
      health: (data['health'] ?? data['healthStatus'] ?? 'Good').toString(),
      rating: _double(data['rating'], fallback: 5),
      totalOrders: _int(data['totalOrders']),
      hasSOS: hasSOS,
      photoUrl: (data['photoUrl'] ?? data['profileImageUrl'] ?? '').toString(),
    );
  }

  static double _double(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int _int(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
