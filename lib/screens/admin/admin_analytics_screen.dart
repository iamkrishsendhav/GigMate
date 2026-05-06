import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
//  AdminAnalyticsScreen — GigMate Pro
// ═══════════════════════════════════════════════════════════════════

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {

  static const Color _primary   = Color(0xFF0F766E);
  static const Color _textDark  = Color(0xFF0F172A);
  static const Color _textMid   = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green     = Color(0xFF10B981);
  static const Color _amber     = Color(0xFFF59E0B);
  static const Color _blue      = Color(0xFF3B82F6);
  static const Color _red       = Color(0xFFEF4444);

  String _period = "Today";
  final List<String> _periods = ["Today", "This Week", "This Month"];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Period selector
          Row(
            children: _periods.map((p) {
              final sel = p == _period;
              return GestureDetector(
                onTap: () => setState(() => _period = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: sel
                            ? Colors.transparent
                            : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(p,
                      style: TextStyle(
                          color: sel ? Colors.white : _textMid,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Summary KPIs
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _AnalyticKpi("₹18,420",   "Revenue",         "+12%", Color(0xFF0F766E), Icons.currency_rupee_rounded),
              _AnalyticKpi("248",        "Total Orders",    "+18",  Color(0xFF1D4ED8), Icons.receipt_long_rounded),
              _AnalyticKpi("74%",        "Success Rate",    "+3%",  Color(0xFF10B981), Icons.check_circle_outline),
              _AnalyticKpi("13.4 min",   "Avg Delivery",    "-2m",  Color(0xFFF59E0B), Icons.schedule_rounded),
            ],
          ),

          const SizedBox(height: 24),

          // ── Bar chart section: Orders by hour
          _sectionTitle("Orders by Hour"),
          const SizedBox(height: 12),
          _buildBarChart(),

          const SizedBox(height: 24),

          // ── Top workers
          _sectionTitle("Top Performers"),
          const SizedBox(height: 12),
          _buildTopWorkers(),

          const SizedBox(height: 24),

          // ── Order breakdown
          _sectionTitle("Order Breakdown"),
          const SizedBox(height: 12),
          _buildOrderBreakdown(),

          const SizedBox(height: 24),

          // ── Health summary
          _sectionTitle("Worker Health Summary"),
          const SizedBox(height: 12),
          _buildHealthSummary(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.2));

  // ── Bar chart (custom painted)
  Widget _buildBarChart() {
    final data = [
      _Bar("9AM",  14, _primary),
      _Bar("10AM", 22, _primary),
      _Bar("11AM", 18, _primary),
      _Bar("12PM", 38, _primary),
      _Bar("1PM",  32, _amber),
      _Bar("2PM",  28, _primary),
      _Bar("3PM",  24, _primary),
      _Bar("4PM",  20, _primary),
    ];
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((b) {
                final pct = b.value / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${b.value}",
                            style: const TextStyle(
                                fontSize: 9, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          height: 130 * pct,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data
                .map((b) => Expanded(
                      child: Text(b.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF94A3B8))),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Top workers leaderboard
  Widget _buildTopWorkers() {
    final workers = [
      _TopWorker("Arjun Singh",  "210 orders", 4.9, 1),
      _TopWorker("Ravi Kumar",   "168 orders", 4.8, 2),
      _TopWorker("Deepak Yadav", "156 orders", 4.7, 3),
      _TopWorker("Priya Sharma", "142 orders", 4.6, 4),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: workers.asMap().entries.map((e) {
          final i = e.key;
          final w = e.value;
          final colors = [
            const Color(0xFFF59E0B),
            const Color(0xFF94A3B8),
            const Color(0xFFEA580C),
            _textLight,
          ];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: colors[i].withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text("#${w.rank}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: colors[i])),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _primary.withOpacity(0.1),
                      child: Text(w.name[0],
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A))),
                          Text(w.orders,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(w.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF59E0B))),
                    ]),
                  ],
                ),
              ),
              if (i < workers.length - 1)
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Order status breakdown
  Widget _buildOrderBreakdown() {
    final items = [
      _BreakdownItem("Delivered",  183, _green, 0.74),
      _BreakdownItem("On the way", 38,  _primary, 0.15),
      _BreakdownItem("Pending",    18,  _amber, 0.07),
      _BreakdownItem("Cancelled",  9,   _red, 0.04),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(item.label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF475569))),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.pct,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(item.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("${item.count}",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ── Health summary
  Widget _buildHealthSummary() {
    final items = [
      _BreakdownItem("Good",     28, _green, 0.82),
      _BreakdownItem("Tired",    5,  _amber, 0.15),
      _BreakdownItem("Critical", 1,  _red,   0.03),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 12,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Container(
                width: 10, height: 10,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: item.color, shape: BoxShape.circle),
              ),
              SizedBox(
                width: 70,
                child: Text(item.label,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF475569))),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: item.pct,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(item.color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("${item.count} workers",
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A))),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

// ── Analytics KPI card
class _AnalyticKpi extends StatelessWidget {
  final String value, label, change;
  final Color  color;
  final IconData icon;
  const _AnalyticKpi(this.value, this.label, this.change,
      this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    final isUp = change.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 4)),
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
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isUp
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(change,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isUp
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Models
class _Bar {
  final String label;
  final int    value;
  final Color  color;
  const _Bar(this.label, this.value, this.color);
}

class _TopWorker {
  final String name, orders;
  final double rating;
  final int    rank;
  const _TopWorker(this.name, this.orders, this.rating, this.rank);
}

class _BreakdownItem {
  final String label;
  final int    count;
  final Color  color;
  final double pct;
  const _BreakdownItem(this.label, this.count, this.color, this.pct);
}


// ═══════════════════════════════════════════════════════════════════
//  AdminLiveTrackingScreen — GigMate Pro
// ═══════════════════════════════════════════════════════════════════

class AdminLiveTrackingScreen extends StatelessWidget {
  const AdminLiveTrackingScreen({super.key});

  static const Color _primary   = Color(0xFF0F766E);
  static const Color _textDark  = Color(0xFF0F172A);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green     = Color(0xFF10B981);
  static const Color _amber     = Color(0xFFF59E0B);
  static const Color _red       = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Map placeholder
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F4F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB2DFDB)),
            ),
            child: Stack(
              children: [
                // Grid lines to simulate map
                CustomPaint(
                  size: const Size(double.infinity, 220),
                  painter: _MapGridPainter(),
                ),
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_rounded,
                          size: 48, color: Color(0xFF0F766E)),
                      SizedBox(height: 8),
                      Text("Live Map View",
                          style: TextStyle(
                              color: Color(0xFF0F766E),
                              fontWeight: FontWeight.w800,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text("Integrate Google Maps here",
                          style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12)),
                    ],
                  ),
                ),
                // Worker pins
                Positioned(
                    top: 60, left: 80,
                    child: _mapPin("R", _green)),
                Positioned(
                    top: 100, left: 180,
                    child: _mapPin("P", _primary)),
                Positioned(
                    top: 40, right: 80,
                    child: _mapPin("!", _red)),
                Positioned(
                    bottom: 50, left: 140,
                    child: _mapPin("A", _amber)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text("Active Workers on Map",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.2)),

          const SizedBox(height: 12),

          // ── Live worker tiles
          ...[
            _LiveWorkerTile("Ravi Kumar",   "Order #108", "Sector 15",
                "2.3 km", "12 min", _green, false),
            _LiveWorkerTile("Priya Sharma", "Order #106", "Sector 11",
                "1.0 km", "8 min",  _primary, false),
            _LiveWorkerTile("Neha Gupta",   "SOS Active", "Sector 30",
                "5.2 km", "—",      _red, true),
            _LiveWorkerTile("Arjun Singh",  "Order #104", "Sector 8",
                "1.1 km", "18 min", _amber, false),
          ].map((t) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: t,
          )),
        ],
      ),
    );
  }

  Widget _mapPin(String label, Color color) {
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Center(
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _LiveWorkerTile extends StatelessWidget {
  final String name, order, location, distance, eta;
  final Color  color;
  final bool   isSOS;
  const _LiveWorkerTile(this.name, this.order, this.location,
      this.distance, this.eta, this.color, this.isSOS);

  static const Color _textDark  = Color(0xFF0F172A);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _primary   = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isSOS
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000),
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.1),
                child: Text(name[0],
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                  if (isSOS) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text("SOS",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800)),
                    ),
                  ]
                ]),
                const SizedBox(height: 3),
                Text("$order • $location",
                    style: const TextStyle(
                        fontSize: 11, color: _textLight)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(distance,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textDark)),
              const SizedBox(height: 2),
              Text(eta,
                  style: const TextStyle(
                      fontSize: 11, color: _textLight)),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.my_location_rounded,
                color: _primary, size: 16),
          ),
        ],
      ),
    );
  }
}

// ── Map grid painter
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB2DFDB).withOpacity(0.4)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}