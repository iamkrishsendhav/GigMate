import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EarningsWalletScreen extends StatefulWidget {
  const EarningsWalletScreen({super.key});

  @override
  State<EarningsWalletScreen> createState() => _EarningsWalletScreenState();
}

class _EarningsWalletScreenState extends State<EarningsWalletScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primaryLight = Color(0xFF14B8A6);
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);
  static const Color _amber = Color(0xFFF59E0B);

  late TabController _tabController;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Please login again")));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('earnings')
          .where('workerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Could not load earnings")),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final earnings = snapshot.data!.docs
            .map((doc) => _Earning.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final summary = _Summary(earnings);

        return Scaffold(
          backgroundColor: _bg,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                title: const Text("Earnings & Wallet",
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                flexibleSpace: FlexibleSpaceBar(
                  background: _walletHeader(summary),
                ),
              ),
            ],
            body: Column(
              children: [
                _tabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _periodView(summary.today, "Today"),
                      _periodView(summary.week, "This Week"),
                      _periodView(summary.month, "This Month"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _withdrawBar(summary.walletBalance),
        );
      },
    );
  }

  Widget _walletHeader(_Summary summary) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, _primaryLight, Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Available balance",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text("₹${summary.walletBalance.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Row(
                children: [
                  _headerMetric("Today", summary.today.total),
                  _headerMetric("Week", summary.week.total),
                  _headerMetric("Bonus", summary.bonus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerMetric(String label, double value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text("₹${value.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: _primary,
        unselectedLabelColor: _textLight,
        indicatorColor: _primary,
        tabs: const [
          Tab(text: "Today"),
          Tab(text: "Weekly"),
          Tab(text: "Monthly"),
        ],
      ),
    );
  }

  Widget _periodView(_PeriodSummary period, String title) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _statCard("Net earning", "₹${period.total.toStringAsFixed(0)}",
                Icons.account_balance_wallet_outlined, _primary),
            const SizedBox(width: 12),
            _statCard("${period.orders}", "Orders",
                Icons.receipt_long_rounded, _green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard("Bonus", "₹${period.bonus.toStringAsFixed(0)}",
                Icons.bolt_rounded, _amber),
            const SizedBox(width: 12),
            _statCard("Deductions", "₹${period.deduction.toStringAsFixed(0)}",
                Icons.remove_circle_outline, _red),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Recent transactions",
            style: TextStyle(
                color: _textDark, fontSize: 17, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        if (period.items.isEmpty)
          _empty("No earnings recorded for $title")
        else
          ...period.items.map(_transactionTile),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: _textLight, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(_Earning earning) {
    final isPositive = earning.amount >= 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isPositive ? _green : _red).withOpacity(0.1),
            child: Icon(
              isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isPositive ? _green : _red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order #${earning.orderId}",
                    style: const TextStyle(
                        color: _textDark, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(_formatDate(earning.createdAt),
                    style: const TextStyle(color: _textLight, fontSize: 12)),
              ],
            ),
          ),
          Text(
            "${isPositive ? '+' : '-'}₹${earning.amount.abs().toStringAsFixed(0)}",
            style: TextStyle(
                color: isPositive ? _green : _red,
                fontWeight: FontWeight.w900,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _empty(String text) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 42, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: _textLight)),
        ],
      ),
    );
  }

  Widget _withdrawBar(double balance) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: ElevatedButton.icon(
          onPressed: balance <= 0 ? null : () => _showWithdrawSheet(balance),
          icon: const Icon(Icons.payments_outlined),
          label: Text("Withdraw ₹${balance.toStringAsFixed(0)}"),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet(double balance) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Withdraw request",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text("Available balance: ₹${balance.toStringAsFixed(2)}",
                style: const TextStyle(color: _textMid)),
            const SizedBox(height: 18),
            const Text(
              "Withdrawal payout flow can now be connected to your payment provider.",
              style: TextStyle(color: _textMid),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final suffix = date.hour >= 12 ? "PM" : "AM";
    return "${date.day}/${date.month}/${date.year} ${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $suffix";
  }
}

class _Summary {
  final List<_Earning> earnings;
  late final _PeriodSummary today;
  late final _PeriodSummary week;
  late final _PeriodSummary month;

  _Summary(this.earnings) {
    final now = DateTime.now();
    today = _period((e) =>
        e.createdAt.year == now.year &&
        e.createdAt.month == now.month &&
        e.createdAt.day == now.day);
    week = _period((e) => e.createdAt.isAfter(now.subtract(const Duration(days: 7))));
    month = _period(
        (e) => e.createdAt.year == now.year && e.createdAt.month == now.month);
  }

  double get walletBalance => earnings.fold(0.0, (sum, e) => sum + e.amount);
  double get bonus => earnings.fold(0.0, (sum, e) => sum + e.bonus);

  _PeriodSummary _period(bool Function(_Earning earning) test) {
    final items = earnings.where(test).toList();
    return _PeriodSummary(items);
  }
}

class _PeriodSummary {
  final List<_Earning> items;

  const _PeriodSummary(this.items);

  double get total => items.fold(0.0, (sum, e) => sum + e.amount);
  double get bonus => items.fold(0.0, (sum, e) => sum + e.bonus);
  double get deduction => items.fold(0.0, (sum, e) => sum + e.deduction);
  int get orders => items.where((e) => e.type == 'delivery').length;
}

class _Earning {
  final String id;
  final String orderId;
  final double amount;
  final double bonus;
  final double deduction;
  final String type;
  final DateTime createdAt;

  const _Earning({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.bonus,
    required this.deduction,
    required this.type,
    required this.createdAt,
  });

  factory _Earning.fromMap(String id, Map<String, dynamic> data) {
    return _Earning(
      id: id,
      orderId: (data['orderId'] ?? id).toString(),
      amount: _num(data['amount']),
      bonus: _num(data['bonus']),
      deduction: _num(data['deduction']),
      type: (data['type'] ?? 'delivery').toString(),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
