import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  EarningsWalletScreen — GigMate
//  Swiggy / Zomato style earnings tracker
// ─────────────────────────────────────────────

class EarningsWalletScreen extends StatefulWidget {
  const EarningsWalletScreen({super.key});

  @override
  State<EarningsWalletScreen> createState() => _EarningsWalletScreenState();
}

class _EarningsWalletScreenState extends State<EarningsWalletScreen>
    with SingleTickerProviderStateMixin {

  // ── Tab controller (Today / Weekly / Monthly)
  late TabController _tabController;

  // ── Dummy data — replace with Firestore streams
  final double walletBalance   = 1240.50;
  final double todayEarnings   = 342.00;
  final double weeklyEarnings  = 2185.00;
  final double monthlyEarnings = 8740.00;
  final double bonusEarned     = 150.00;
  final double totalDeductions = 45.00;

  // Weekly bar chart data (Mon–Sun)
  final List<_DayEarning> weekData = [
    _DayEarning("M", 280),
    _DayEarning("T", 420),
    _DayEarning("W", 190),
    _DayEarning("T", 510),
    _DayEarning("F", 342),
    _DayEarning("S", 620),
    _DayEarning("S", 180),
  ];

  // Today's transaction log
  final List<_Transaction> transactions = [
    _Transaction(
      orderId: "#108",
      customer: "Rahul Sharma",
      amount: 85.0,
      tip: 20.0,
      time: "02:45 PM",
      type: TxType.delivery,
    ),
    _Transaction(
      orderId: "#107",
      customer: "Priya Singh",
      amount: 65.0,
      tip: 0.0,
      time: "01:10 PM",
      type: TxType.delivery,
    ),
    _Transaction(
      orderId: "Bonus",
      customer: "Peak Hour Bonus",
      amount: 50.0,
      tip: 0.0,
      time: "12:00 PM",
      type: TxType.bonus,
    ),
    _Transaction(
      orderId: "#106",
      customer: "Amit Verma",
      amount: 92.0,
      tip: 30.0,
      time: "11:20 AM",
      type: TxType.delivery,
    ),
    _Transaction(
      orderId: "Deduction",
      customer: "Late delivery penalty",
      amount: -45.0,
      tip: 0.0,
      time: "10:05 AM",
      type: TxType.deduction,
    ),
  ];

  // UPI controller
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ── Colors consistent with GigMate theme
  static const Color _primary    = Color(0xFF0F766E);
  static const Color _primaryLight = Color(0xFF14B8A6);
  static const Color _accent     = Color(0xFF0EA5E9);
  static const Color _bg         = Color(0xFFF4F7FB);
  static const Color _card       = Colors.white;
  static const Color _textDark   = Color(0xFF0F172A);
  static const Color _textMid    = Color(0xFF475569);
  static const Color _textLight  = Color(0xFF94A3B8);
  static const Color _green      = Color(0xFF10B981);
  static const Color _red        = Color(0xFFEF4444);
  static const Color _amber      = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(),
                  _buildWeeklyTab(),
                  _buildMonthlyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildWithdrawBar(),
    );
  }

  // ─────────────────────────────────────────
  //  SLIVER APP BAR — Wallet Balance Card
  // ─────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Earnings & Wallet",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          onPressed: () => _showFullHistory(),
          tooltip: "Full History",
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildWalletCard(),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Wallet Balance",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Available",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _walletMiniStat(
                      "Today", "₹${todayEarnings.toStringAsFixed(0)}"),
                  _divider(),
                  _walletMiniStat(
                      "This Week", "₹${weeklyEarnings.toStringAsFixed(0)}"),
                  _divider(),
                  _walletMiniStat(
                      "Bonus", "₹${bonusEarned.toStringAsFixed(0)}"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
        width: 1, height: 30, color: Colors.white.withOpacity(0.25));
  }

  // ─────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _card,
      child: TabBar(
        controller: _tabController,
        labelColor: _primary,
        unselectedLabelColor: _textMid,
        indicatorColor: _primary,
        indicatorWeight: 3,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: const [
          Tab(text: "Today"),
          Tab(text: "Weekly"),
          Tab(text: "Monthly"),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TODAY TAB
  // ─────────────────────────────────────────
  Widget _buildTodayTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: "Gross Earned",
                value: "₹${(todayEarnings + totalDeductions).toStringAsFixed(0)}",
                icon: Icons.attach_money_rounded,
                color: _green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                label: "Deductions",
                value: "-₹${totalDeductions.toStringAsFixed(0)}",
                icon: Icons.remove_circle_outline,
                color: _red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: "Tips Earned",
                value: "₹50",
                icon: Icons.favorite_rounded,
                color: _amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                label: "Net Earned",
                value: "₹${todayEarnings.toStringAsFixed(0)}",
                icon: Icons.account_balance_wallet_outlined,
                color: _primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Performance banner
        _performanceBanner(),

        const SizedBox(height: 22),

        // Transactions
        const Text(
          "Today's Transactions",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark),
        ),
        const SizedBox(height: 12),
        ...transactions.map((tx) => _transactionTile(tx)),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color),
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: _textLight)),
        ],
      ),
    );
  }

  Widget _performanceBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.emoji_events_rounded, color: _amber, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Peak Hour Bonus Unlocked 🎉",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                      fontSize: 14),
                ),
                SizedBox(height: 3),
                Text(
                  "You earned ₹50 bonus for delivering during peak hours",
                  style:
                      TextStyle(fontSize: 12, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(_Transaction tx) {
    Color iconBg;
    Color iconColor;
    IconData icon;
    String prefix = "+";

    switch (tx.type) {
      case TxType.delivery:
        iconBg = _green.withOpacity(0.12);
        iconColor = _green;
        icon = Icons.delivery_dining_rounded;
        break;
      case TxType.bonus:
        iconBg = _amber.withOpacity(0.12);
        iconColor = _amber;
        icon = Icons.bolt_rounded;
        break;
      case TxType.deduction:
        iconBg = _red.withOpacity(0.12);
        iconColor = _red;
        icon = Icons.remove_circle_outline;
        prefix = "";
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.customer,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _textDark)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text("Order ${tx.orderId}",
                        style: const TextStyle(
                            fontSize: 12, color: _textLight)),
                    const SizedBox(width: 6),
                    Text("• ${tx.time}",
                        style: const TextStyle(
                            fontSize: 12, color: _textLight)),
                    if (tx.tip > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "+₹${tx.tip.toInt()} tip",
                          style: const TextStyle(
                              fontSize: 10,
                              color: _amber,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            "$prefix₹${tx.amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: tx.type == TxType.deduction ? _red : _green,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WEEKLY TAB — Bar Chart
  // ─────────────────────────────────────────
  Widget _buildWeeklyTab() {
    final double maxVal =
        weekData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Weekly summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("This Week",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                "₹${weeklyEarnings.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _weeklyStatPill(
                      "Orders", "34", Icons.inventory_2_outlined),
                  _weeklyStatPill(
                      "Avg/Day", "₹312", Icons.show_chart_rounded),
                  _weeklyStatPill(
                      "Best Day", "Sat", Icons.star_outline_rounded),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Bar Chart
        const Text("Daily Breakdown",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 12,
                  offset: Offset(0, 4)),
            ],
          ),
          child: SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                final ratio = d.amount / maxVal;
                final isToday = i == 4; // Friday = today (demo)
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isToday)
                          Text(
                            "₹${d.amount.toInt()}",
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _primary),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 80),
                          curve: Curves.easeOut,
                          height: 120 * ratio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isToday
                                  ? [_primary, _primaryLight]
                                  : [
                                      const Color(0xFFE2E8F0),
                                      const Color(0xFFCBD5E1)
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d.day,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color:
                                    isToday ? _primary : _textLight)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Per-day list
        const Text("Day Summary",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark)),
        const SizedBox(height: 12),
        ...weekData.asMap().entries.map((entry) {
          final days = [
            "Monday", "Tuesday", "Wednesday",
            "Thursday", "Friday", "Saturday", "Sunday"
          ];
          return _dayRow(days[entry.key], entry.value.amount,
              entry.key == 4);
        }),
      ],
    );
  }

  Widget _weeklyStatPill(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _dayRow(String day, double amount, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: isToday
            ? Border.all(color: _primary.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(day,
              style: TextStyle(
                  fontWeight:
                      isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday ? _primary : _textDark,
                  fontSize: 14)),
          if (isToday)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text("Today",
                  style: TextStyle(
                      fontSize: 10,
                      color: _primary,
                      fontWeight: FontWeight.w700)),
            ),
          const Spacer(),
          Text("₹${amount.toInt()}",
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _textDark)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  MONTHLY TAB
  // ─────────────────────────────────────────
  Widget _buildMonthlyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // Monthly hero card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("May 2026",
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("In Progress",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "₹${monthlyEarnings.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1),
              ),
              const SizedBox(height: 6),
              const Text("Total Earnings This Month",
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 18),
              // Progress toward monthly target
              const Text("Target: ₹10,000",
                  style:
                      TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: monthlyEarnings / 10000,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${((monthlyEarnings / 10000) * 100).toStringAsFixed(0)}% of monthly target",
                style: const TextStyle(
                    color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _monthlyStatCard("Total Orders", "168",
                Icons.inventory_2_outlined, _primary),
            _monthlyStatCard(
                "Avg Daily", "₹291", Icons.show_chart_rounded, _green),
            _monthlyStatCard(
                "Total Bonus", "₹620", Icons.bolt_rounded, _amber),
            _monthlyStatCard("Deductions", "-₹180",
                Icons.remove_circle_outline, _red),
          ],
        ),

        const SizedBox(height: 22),

        // Weekly breakdown in month
        const Text("Weekly Breakdown",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark)),
        const SizedBox(height: 12),
        _weekBreakdownRow("Week 1 (May 1–7)", 2100),
        _weekBreakdownRow("Week 2 (May 8–14)", 2450),
        _weekBreakdownRow("Week 3 (May 15–21)", 2005),
        _weekBreakdownRow("Week 4 (May 22–28)", 2185),
      ],
    );
  }

  Widget _monthlyStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: _textLight)),
        ],
      ),
    );
  }

  Widget _weekBreakdownRow(String label, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _textMid,
                    fontSize: 13)),
          ),
          Text("₹${amount.toInt()}",
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _textDark)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BOTTOM WITHDRAW BAR
  // ─────────────────────────────────────────
  Widget _buildWithdrawBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Available to Withdraw",
                    style: TextStyle(fontSize: 11, color: _textLight)),
                Text(
                  "₹${walletBalance.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: _textDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _showWithdrawSheet(),
            icon: const Icon(Icons.account_balance_rounded, size: 18),
            label: const Text("Withdraw",
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  WITHDRAW BOTTOM SHEET
  // ─────────────────────────────────────────
  void _showWithdrawSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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

              Row(
                children: const [
                  Icon(Icons.account_balance_wallet_rounded,
                      color: _primary),
                  SizedBox(width: 10),
                  Text("Withdraw to UPI",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textDark)),
                ],
              ),

              const SizedBox(height: 6),
              Text("Available: ₹${walletBalance.toStringAsFixed(2)}",
                  style:
                      const TextStyle(fontSize: 13, color: _textLight)),

              const SizedBox(height: 20),

              // UPI ID field
              TextField(
                controller: _upiController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Enter UPI ID (e.g. name@upi)",
                  prefixIcon: const Icon(Icons.alternate_email,
                      color: _primary),
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
                ),
              ),

              const SizedBox(height: 12),

              // Amount field
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  prefixIcon:
                      const Icon(Icons.currency_rupee, color: _primary),
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
                ),
              ),

              const SizedBox(height: 10),

              // Quick amount chips
              Row(
                children: [100, 200, 500, 1000].map((amt) {
                  return GestureDetector(
                    onTap: () => setState(
                        () => _amountController.text = amt.toString()),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _primary.withOpacity(0.2)),
                      ),
                      child: Text("₹$amt",
                          style: const TextStyle(
                              color: _primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showWithdrawSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Send Money",
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text("Powered by UPI • Instant Transfer",
                    style:
                        TextStyle(fontSize: 11, color: _textLight)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text("Withdrawal request sent! 🎉",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showFullHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Full history coming soon")),
    );
  }
}

// ─────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────

enum TxType { delivery, bonus, deduction }

class _Transaction {
  final String orderId;
  final String customer;
  final double amount;
  final double tip;
  final String time;
  final TxType type;

  const _Transaction({
    required this.orderId,
    required this.customer,
    required this.amount,
    required this.tip,
    required this.time,
    required this.type,
  });
}

class _DayEarning {
  final String day;
  final double amount;
  const _DayEarning(this.day, this.amount);
}