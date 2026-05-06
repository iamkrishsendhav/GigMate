import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  OrderHistoryScreen — GigMate
//  Completed / Cancelled orders with search & filter
// ─────────────────────────────────────────────

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {

  // ── Tab controller
  late TabController _tabController;

  // ── Search & Filter state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All"; // All, Today, This Week, This Month
  String _selectedStatus = "All"; // All, Completed, Cancelled, Pending

  // ── Dummy order data — replace with Firestore
  final List<_Order> _allOrders = [
    _Order(
      id: "108",
      customer: "Rahul Sharma",
      address: "Sector 15, Noida",
      pickup: "McDonald's, Sector 18",
      amount: 85.0,
      tip: 20.0,
      distance: "3.2 km",
      duration: "18 min",
      date: DateTime(2026, 5, 3, 14, 45),
      status: OrderStatus.completed,
      rating: 5,
    ),
    _Order(
      id: "107",
      customer: "Priya Singh",
      address: "Rajpur Road, Dehradun",
      pickup: "Domino's, Clock Tower",
      amount: 65.0,
      tip: 0.0,
      distance: "2.1 km",
      duration: "12 min",
      date: DateTime(2026, 5, 3, 13, 10),
      status: OrderStatus.completed,
      rating: 4,
    ),
    _Order(
      id: "106",
      customer: "Amit Verma",
      address: "Green Park, Delhi",
      pickup: "Burger King, CP",
      amount: 92.0,
      tip: 30.0,
      distance: "4.5 km",
      duration: "25 min",
      date: DateTime(2026, 5, 3, 11, 20),
      status: OrderStatus.completed,
      rating: 5,
    ),
    _Order(
      id: "105",
      customer: "Sneha Gupta",
      address: "Vasant Kunj, Delhi",
      pickup: "Subway, Saket",
      amount: 55.0,
      tip: 0.0,
      distance: "6.2 km",
      duration: "35 min",
      date: DateTime(2026, 5, 3, 9, 30),
      status: OrderStatus.cancelled,
      rating: 0,
      cancelReason: "Customer not available",
    ),
    _Order(
      id: "104",
      customer: "Vikram Nair",
      address: "Koramangala, Bangalore",
      pickup: "KFC, Indiranagar",
      amount: 120.0,
      tip: 50.0,
      distance: "5.8 km",
      duration: "30 min",
      date: DateTime(2026, 5, 2, 19, 15),
      status: OrderStatus.completed,
      rating: 5,
    ),
    _Order(
      id: "103",
      customer: "Anjali Mehta",
      address: "Bandra, Mumbai",
      pickup: "Pizza Hut, Andheri",
      amount: 78.0,
      tip: 15.0,
      distance: "3.9 km",
      duration: "22 min",
      date: DateTime(2026, 5, 2, 15, 40),
      status: OrderStatus.completed,
      rating: 4,
    ),
    _Order(
      id: "102",
      customer: "Rohit Joshi",
      address: "Powai, Mumbai",
      pickup: "Biryani Blues, Hiranandani",
      amount: 145.0,
      tip: 0.0,
      distance: "7.1 km",
      duration: "40 min",
      date: DateTime(2026, 5, 2, 12, 55),
      status: OrderStatus.cancelled,
      rating: 0,
      cancelReason: "Restaurant delay — order auto-cancelled",
    ),
    _Order(
      id: "101",
      customer: "Deepa Iyer",
      address: "Indiranagar, Bangalore",
      pickup: "Meghana Foods, Koramangala",
      amount: 98.0,
      tip: 25.0,
      distance: "4.3 km",
      duration: "20 min",
      date: DateTime(2026, 5, 1, 20, 10),
      status: OrderStatus.completed,
      rating: 5,
    ),
  ];

  // ── Colors
  static const Color _primary     = Color(0xFF0F766E);
  static const Color _primaryLight = Color(0xFF14B8A6);
  static const Color _bg          = Color(0xFFF4F7FB);
  static const Color _card        = Colors.white;
  static const Color _textDark    = Color(0xFF0F172A);
  static const Color _textMid     = Color(0xFF475569);
  static const Color _textLight   = Color(0xFF94A3B8);
  static const Color _green       = Color(0xFF10B981);
  static const Color _red         = Color(0xFFEF4444);
  static const Color _amber       = Color(0xFFF59E0B);

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

  // ── Filter logic
  List<_Order> get _filteredOrders {
    List<_Order> orders = List.from(_allOrders);

    // Status filter from tab
    final tabIndex = _tabController.index;
    if (tabIndex == 1) {
      orders = orders.where((o) => o.status == OrderStatus.completed).toList();
    } else if (tabIndex == 2) {
      orders = orders.where((o) => o.status == OrderStatus.cancelled).toList();
    }

    // Date filter
    final now = DateTime.now();
    if (_selectedFilter == "Today") {
      orders = orders.where((o) =>
          o.date.year == now.year &&
          o.date.month == now.month &&
          o.date.day == now.day).toList();
    } else if (_selectedFilter == "This Week") {
      final weekAgo = now.subtract(const Duration(days: 7));
      orders = orders.where((o) => o.date.isAfter(weekAgo)).toList();
    } else if (_selectedFilter == "This Month") {
      orders = orders
          .where((o) => o.date.year == now.year && o.date.month == now.month)
          .toList();
    }

    // Search by order ID or customer name
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((o) =>
          o.id.toLowerCase().contains(_searchQuery) ||
          o.customer.toLowerCase().contains(_searchQuery)).toList();
    }

    return orders;
  }

  // ── Summary counts
  int get _completedCount =>
      _allOrders.where((o) => o.status == OrderStatus.completed).length;
  int get _cancelledCount =>
      _allOrders.where((o) => o.status == OrderStatus.cancelled).length;
  double get _totalEarned => _allOrders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0, (sum, o) => sum + o.amount + o.tip);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildAppBar(),
        ],
        body: Column(
          children: [
            _buildSearchBar(),
            _buildDateFilterChips(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(_filteredOrders),
                  _buildOrderList(_filteredOrders),
                  _buildOrderList(_filteredOrders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  APP BAR
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
        "Order History",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
      ),
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
              child: Row(
                children: [
                  _headerStat("Total Orders",
                      _allOrders.length.toString(), Icons.inventory_2_outlined),
                  _vDivider(),
                  _headerStat("Completed",
                      _completedCount.toString(), Icons.check_circle_outline),
                  _vDivider(),
                  _headerStat("Earned",
                      "₹${_totalEarned.toStringAsFixed(0)}", Icons.account_balance_wallet_outlined),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 40, color: Colors.white.withOpacity(0.25));

  // ─────────────────────────────────────────
  //  SEARCH BAR
  // ─────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search by Order ID or Customer name...",
          hintStyle: const TextStyle(fontSize: 13, color: _textLight),
          prefixIcon: const Icon(Icons.search_rounded, color: _primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: _textLight),
                  onPressed: () {
                    _searchController.clear();
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
  //  DATE FILTER CHIPS
  // ─────────────────────────────────────────
  Widget _buildDateFilterChips() {
    final filters = ["All", "Today", "This Week", "This Month"];
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? _primary : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textMid,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
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
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          Tab(text: "All (${_allOrders.length})"),
          Tab(text: "Done ($_completedCount)"),
          Tab(text: "Cancelled ($_cancelledCount)"),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  ORDER LIST
  // ─────────────────────────────────────────
  Widget _buildOrderList(List<_Order> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    // Group by date
    final Map<String, List<_Order>> grouped = {};
    for (final order in orders) {
      final key = _dateLabel(order.date);
      grouped.putIfAbsent(key, () => []).add(order);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                        height: 1,
                        color: const Color(0xFFE2E8F0)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${entry.value.length} orders",
                    style: const TextStyle(
                        fontSize: 12, color: _textLight),
                  ),
                ],
              ),
            ),
            ...entry.value.map((order) => _orderCard(order)),
          ],
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────
  //  ORDER CARD
  // ─────────────────────────────────────────
  Widget _orderCard(_Order order) {
    final isCompleted = order.status == OrderStatus.completed;
    final statusColor = isCompleted ? _green : _red;
    final statusText = isCompleted ? "Completed" : "Cancelled";
    final statusIcon = isCompleted
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return GestureDetector(
      onTap: () => _showOrderDetail(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  // Order icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Order #${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusPill(statusText, statusColor),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          order.customer,
                          style: const TextStyle(
                              fontSize: 13, color: _textMid),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCompleted
                            ? "+₹${(order.amount + order.tip).toStringAsFixed(0)}"
                            : "₹0",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isCompleted ? _green : _textLight,
                        ),
                      ),
                      if (order.tip > 0)
                        Text(
                          "+₹${order.tip.toInt()} tip",
                          style: const TextStyle(
                              fontSize: 11, color: _amber),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Route info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked,
                      color: _primary, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.pickup,
                      style: const TextStyle(
                          fontSize: 12, color: _textMid),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 3, bottom: 4),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 5),
                    width: 2,
                    height: 14,
                    color: const Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: _red, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.address,
                      style: const TextStyle(
                          fontSize: 12, color: _textMid),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Bottom info bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  _infoChip(Icons.access_time_rounded,
                      _timeStr(order.date)),
                  const SizedBox(width: 12),
                  _infoChip(
                      Icons.straighten_rounded, order.distance),
                  const SizedBox(width: 12),
                  _infoChip(Icons.timer_outlined, order.duration),
                  const Spacer(),
                  if (isCompleted && order.rating > 0)
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < order.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: _amber,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Cancel reason (if cancelled)
            if (!isCompleted && order.cancelReason != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: _red, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      order.cancelReason!,
                      style: const TextStyle(
                          fontSize: 12, color: _red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: _textLight),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: _textMid)),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────
  Widget _buildEmptyState() {
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
            child: const Icon(Icons.inventory_2_outlined,
                color: _primary, size: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            "No orders found",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark),
          ),
          const SizedBox(height: 6),
          const Text(
            "Try changing the filter or search term",
            style: TextStyle(fontSize: 13, color: _textLight),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  ORDER DETAIL BOTTOM SHEET
  // ─────────────────────────────────────────
  void _showOrderDetail(_Order order) {
    final isCompleted = order.status == OrderStatus.completed;
    final statusColor = isCompleted ? _green : _red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
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

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #${order.id}",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _fullDateStr(order.date),
                          style: const TextStyle(
                              fontSize: 13, color: _textLight),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(
                      isCompleted ? "Completed" : "Cancelled",
                      statusColor),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Customer
              _detailRow(Icons.person_outline, "Customer",
                  order.customer),
              const SizedBox(height: 14),
              _detailRow(Icons.radio_button_checked, "Pickup",
                  order.pickup),
              const SizedBox(height: 14),
              _detailRow(
                  Icons.location_on_outlined, "Drop", order.address),
              const SizedBox(height: 14),
              _detailRow(Icons.straighten_rounded, "Distance",
                  order.distance),
              const SizedBox(height: 14),
              _detailRow(
                  Icons.timer_outlined, "Duration", order.duration),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Earnings breakdown
              const Text("Earnings Breakdown",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _textDark)),
              const SizedBox(height: 14),
              _earningRow("Delivery Charge",
                  "₹${order.amount.toStringAsFixed(0)}",
                  isGreen: isCompleted),
              if (order.tip > 0) ...[
                const SizedBox(height: 8),
                _earningRow(
                    "Tip", "+₹${order.tip.toInt()}", isGreen: true),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? _green.withOpacity(0.08)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      "Total Earned",
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isCompleted ? _green : _textLight),
                    ),
                    const Spacer(),
                    Text(
                      isCompleted
                          ? "+₹${(order.amount + order.tip).toStringAsFixed(0)}"
                          : "₹0",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isCompleted ? _green : _textLight),
                    ),
                  ],
                ),
              ),

              // Rating
              if (isCompleted && order.rating > 0) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                const Text("Customer Rating",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _textDark)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < order.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 28,
                          color: _amber,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${order.rating}.0",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: _textDark),
                    ),
                  ],
                ),
              ],

              // Cancel reason
              if (!isCompleted && order.cancelReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _red.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: _red, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Reason: ${order.cancelReason}",
                          style: const TextStyle(
                              fontSize: 13, color: _red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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
                  style: const TextStyle(
                      fontSize: 11, color: _textLight)),
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

  Widget _earningRow(String label, String value,
      {bool isGreen = false}) {
    return Row(
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 14, color: _textMid)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isGreen ? _green : _textDark)),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────
  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) return "Today";
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) return "Yesterday";
    return "${date.day} ${_monthName(date.month)} ${date.year}";
  }

  String _fullDateStr(DateTime date) {
    return "${date.day} ${_monthName(date.month)} ${date.year} • ${_timeStr(date)}";
  }

  String _timeStr(DateTime date) {
    final h = date.hour;
    final m = date.minute.toString().padLeft(2, "0");
    final suffix = h >= 12 ? "PM" : "AM";
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return "$hour:$m $suffix";
  }

  String _monthName(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }
}

// ─────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────

enum OrderStatus { completed, cancelled }

class _Order {
  final String id;
  final String customer;
  final String address;
  final String pickup;
  final double amount;
  final double tip;
  final String distance;
  final String duration;
  final DateTime date;
  final OrderStatus status;
  final int rating;
  final String? cancelReason;

  const _Order({
    required this.id,
    required this.customer,
    required this.address,
    required this.pickup,
    required this.amount,
    required this.tip,
    required this.distance,
    required this.duration,
    required this.date,
    required this.status,
    required this.rating,
    this.cancelReason,
  });
}