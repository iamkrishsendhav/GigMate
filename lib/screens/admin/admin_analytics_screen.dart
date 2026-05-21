import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gigmate/models/order_model.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _red = Color(0xFFEF4444);

  String _period = "Today";
  final List<String> _periods = ["Today", "This Week", "This Month"];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, orderSnap) {
        if (orderSnap.hasError) {
          return _state("Failed to load analytics");
        }
        if (!orderSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('workers').snapshots(),
          builder: (context, workerSnap) {
            if (!workerSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final allOrders = orderSnap.data!.docs
                .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
                .toList();
            final workers = workerSnap.data!.docs;
            final orders = allOrders.where(_inSelectedPeriod).toList();
            final delivered =
                orders.where((o) => o.status == 'delivered').toList();
            final revenue =
                delivered.fold<double>(0, (sum, o) => sum + o.payout);
            final successRate =
                orders.isEmpty ? 0 : (delivered.length / orders.length * 100);
            final avgEta = orders.isEmpty
                ? 0
                : orders.fold<double>(0, (sum, o) => sum + o.eta) /
                    orders.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _periodSelector(),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 360;
                      return GridView.count(
                        crossAxisCount: narrow ? 1 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 116,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _AnalyticKpi(
                              "₹${revenue.toStringAsFixed(0)}",
                              "Revenue",
                              "Live",
                              _primary,
                              Icons.currency_rupee_rounded),
                          _AnalyticKpi("${orders.length}", "Total Orders",
                              "Live", _blue, Icons.receipt_long_rounded),
                          _AnalyticKpi(
                              "${successRate.toStringAsFixed(0)}%",
                              "Success Rate",
                              "Live",
                              _green,
                              Icons.check_circle_outline),
                          _AnalyticKpi(
                              "${avgEta.toStringAsFixed(1)} min",
                              "Avg ETA",
                              "Live",
                              _amber,
                              Icons.schedule_rounded),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Orders by Status"),
                  const SizedBox(height: 12),
                  _breakdownCard(_orderBreakdown(orders)),
                  const SizedBox(height: 24),
                  _sectionTitle("Top Performers"),
                  const SizedBox(height: 12),
                  _topWorkersCard(allOrders, workers),
                  const SizedBox(height: 24),
                  _sectionTitle("Worker Health Summary"),
                  const SizedBox(height: 12),
                  _breakdownCard(_healthBreakdown(workers), suffix: " workers"),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _periodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _periods.map((p) {
          final selected = p == _period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p),
              selected: selected,
              selectedColor: _primary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              labelStyle: TextStyle(
                  color: selected ? Colors.white : _textMid,
                  fontWeight: FontWeight.w700),
              onSelected: (_) => setState(() => _period = p),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _inSelectedPeriod(OrderModel order) {
    final now = DateTime.now();
    final created = order.createdAt;
    if (_period == "Today") {
      return created.year == now.year &&
          created.month == now.month &&
          created.day == now.day;
    }
    if (_period == "This Week") {
      return created.isAfter(now.subtract(const Duration(days: 7)));
    }
    return created.year == now.year && created.month == now.month;
  }

  List<_BreakdownItem> _orderBreakdown(List<OrderModel> orders) {
    final total = orders.isEmpty ? 1 : orders.length;
    final delivered = orders.where((o) => o.status == 'delivered').length;
    final active = orders
        .where((o) => o.isActiveDelivery || o.status == 'assigned')
        .length;
    final pending = orders.where((o) => o.status == 'pending').length;
    final cancelled = orders
        .where((o) => o.status == 'cancelled' || o.status == 'rejected')
        .length;
    return [
      _BreakdownItem("Delivered", delivered, _green, delivered / total),
      _BreakdownItem("Active", active, _primary, active / total),
      _BreakdownItem("Pending", pending, _amber, pending / total),
      _BreakdownItem("Cancelled", cancelled, _red, cancelled / total),
    ];
  }

  List<_BreakdownItem> _healthBreakdown(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> workers) {
    final total = workers.isEmpty ? 1 : workers.length;
    int count(String status) => workers
        .where((w) =>
            (w.data()['health'] ?? w.data()['healthStatus'] ?? 'Good')
                .toString() ==
            status)
        .length;
    final good = count("Good");
    final tired = count("Tired");
    final critical = count("Critical");
    return [
      _BreakdownItem("Good", good, _green, good / total),
      _BreakdownItem("Tired", tired, _amber, tired / total),
      _BreakdownItem("Critical", critical, _red, critical / total),
    ];
  }

  Widget _topWorkersCard(
    List<OrderModel> allOrders,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> workers,
  ) {
    final workerMap = {
      for (final w in workers) w.id: (w.data()['name'] ?? 'Worker').toString()
    };
    final counts = <String, int>{};
    for (final order in allOrders.where((o) => o.status == 'delivered')) {
      final id = order.workerId;
      if (id == null || id.isEmpty) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    final top = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (top.isEmpty) {
      return _card(child: const Text("No completed orders yet"));
    }

    return _card(
      child: Column(
        children: top.take(5).toList().asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final item = entry.value;
          final name = workerMap[item.key] ?? "Worker";
          return Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: _primary.withOpacity(0.1),
                  child: Text("#$rank",
                      style: const TextStyle(
                          color: _primary, fontWeight: FontWeight.w900)),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: _textDark)),
                subtitle: Text("${item.value} delivered orders"),
                trailing:
                    const Icon(Icons.emoji_events_outlined, color: _amber),
              ),
              if (rank < top.take(5).length)
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _breakdownCard(List<_BreakdownItem> items, {String suffix = ""}) {
    return _card(
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 82,
                  child: Text(item.label,
                      style: const TextStyle(fontSize: 12, color: _textMid)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: item.pct.clamp(0.0, 1.0).toDouble(),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("${item.count}$suffix",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _textDark)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w900, color: _textDark));

  Widget _state(String text) => Center(
        child: Text(text,
            style: const TextStyle(
                color: _textLight, fontWeight: FontWeight.w800)),
      );
}

class _AnalyticKpi extends StatelessWidget {
  final String value;
  final String label;
  final String change;
  final Color color;
  final IconData icon;

  const _AnalyticKpi(
      this.value, this.label, this.change, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4)),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Text(change,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: color, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  final String label;
  final int count;
  final Color color;
  final double pct;

  const _BreakdownItem(this.label, this.count, this.color, this.pct);
}
