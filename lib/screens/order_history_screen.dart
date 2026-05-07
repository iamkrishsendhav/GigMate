import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gigmate/models/order_model.dart';
import 'package:gigmate/services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);

  final _orderService = OrderService();
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = "";
  String _dateFilter = "All";

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Please login again")));
    }

    return Scaffold(
      backgroundColor: _bg,
      body: StreamBuilder(
        stream: _orderService.getWorkerOrders(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Could not load orders"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allOrders = snapshot.data!.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .where((order) =>
                  order.status == 'delivered' ||
                  order.status == 'cancelled' ||
                  order.status == 'rejected')
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final filtered = _filtered(allOrders);
          final completed = allOrders.where((o) => o.status == 'delivered').length;
          final cancelled = allOrders.length - completed;
          final earned =
              allOrders.where((o) => o.status == 'delivered').fold<double>(
                    0,
                    (sum, order) => sum + order.payout,
                  );

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width < 600 ? 250 : 240,
                pinned: true,
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                title: const Text("Order History",
                    style: TextStyle(fontWeight: FontWeight.w900)),
                flexibleSpace: FlexibleSpaceBar(
                  background: _header(allOrders.length, completed, cancelled, earned),
                ),
              ),
            ],
            body: Column(
              children: [
                _searchBar(),
                _dateChips(),
                _tabBar(allOrders.length, completed, cancelled),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _orderList(filtered),
                      _orderList(filtered),
                      _orderList(filtered),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<OrderModel> _filtered(List<OrderModel> orders) {
    var result = List<OrderModel>.from(orders);
    final tab = _tabController.index;
    if (tab == 1) {
      result = result.where((o) => o.status == 'delivered').toList();
    } else if (tab == 2) {
      result = result.where((o) => o.status != 'delivered').toList();
    }

    final now = DateTime.now();
    if (_dateFilter == "Today") {
      result = result
          .where((o) =>
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day)
          .toList();
    } else if (_dateFilter == "This Week") {
      result = result
          .where((o) => o.createdAt.isAfter(now.subtract(const Duration(days: 7))))
          .toList();
    } else if (_dateFilter == "This Month") {
      result = result
          .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((o) =>
              o.id.toLowerCase().contains(_searchQuery) ||
              o.pickup.toLowerCase().contains(_searchQuery) ||
              o.drop.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return result;
  }

  Widget _header(int total, int completed, int cancelled, double earned) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 64, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Completed delivery performance",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Text("₹${earned.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _headerMetric("$total", "Total"),
                  _headerMetric("$completed", "Done"),
                  _headerMetric("$cancelled", "Cancelled"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerMetric(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by order, pickup or drop",
          prefixIcon: const Icon(Icons.search_rounded, color: _textLight),
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

  Widget _dateChips() {
    const filters = ["All", "Today", "This Week", "This Month"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = f == _dateFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: selected,
                selectedColor: _primary,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                labelStyle: TextStyle(
                    color: selected ? Colors.white : _textMid,
                    fontWeight: FontWeight.w700),
                onSelected: (_) => setState(() => _dateFilter = f),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tabBar(int total, int completed, int cancelled) {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {}),
      labelColor: _primary,
      unselectedLabelColor: _textLight,
      indicatorColor: _primary,
      tabs: [
        Tab(text: "All ($total)"),
        Tab(text: "Done ($completed)"),
        Tab(text: "Cancelled ($cancelled)"),
      ],
    );
  }

  Widget _orderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders found"));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _orderCard(orders[i]),
    );
  }

  Widget _orderCard(OrderModel order) {
    final completed = order.status == 'delivered';
    final color = completed ? _green : _red;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text("Order #${order.id}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
              ),
              _statusPill(order.statusText, color),
            ],
          ),
          const SizedBox(height: 12),
          _route("Pickup", order.pickup),
          const SizedBox(height: 8),
          _route("Drop", order.drop),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _meta(Icons.currency_rupee_rounded,
                  completed ? "Earned ₹${order.payout.toStringAsFixed(0)}" : "No payout"),
              _meta(Icons.near_me_outlined,
                  order.distance > 0 ? "${order.distance.toStringAsFixed(1)} km" : "--"),
              _meta(Icons.schedule_rounded,
                  order.eta > 0 ? "${order.eta.toStringAsFixed(0)} min" : "--"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _route(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(label,
              style: const TextStyle(color: _textLight, fontSize: 12)),
        ),
        Expanded(
          child: Text(value.isEmpty ? "Not provided" : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(color: _textDark, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primary),
          const SizedBox(width: 4),
          Text(text,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
