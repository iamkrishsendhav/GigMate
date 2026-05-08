import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/responsive.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/user_service.dart';
import '../services/worker_wellness_service.dart';
import 'break_reminder_screen.dart';
import 'delivery_list_screen.dart';
import 'earnings_wallet_screen.dart';
import 'health_status_screen.dart';
import 'navigation_screen.dart';
import 'order_history_screen.dart';
import 'worker_profile_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _bg = Color(0xFFF0F4F8);
  static const Color _card = Colors.white;
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMid = Color(0xFF475569);
  static const Color _textLight = Color(0xFF94A3B8);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _red = Color(0xFFEF4444);
  static const Color _orange = Color(0xFFEA580C);
  static const Color _blue = Color(0xFF3B82F6);

  final _orderService = OrderService();
  final _userService = UserService();
  final _wellnessService = WorkerWellnessService();

  String _workerName = 'Worker';
  WorkerWellnessSnapshot _wellness = WorkerWellnessSnapshot.empty();
  StreamSubscription<WorkerWellnessSnapshot>? _wellnessSub;
  Timer? _clockTimer;
  String? currentOrderId;

  final String _emergencyPhone = 'tel:+919876543210';
  final String _emergencySms = 'sms:+919876543210';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadWorkerName();
    _markWorkerOnline();
    _listenWellness();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    final uid = _uid;
    if (uid != null) {
      _userService.updateOnlineStatus(uid: uid, isOnline: false);
    }
    _wellnessSub?.cancel();
    _clockTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenWellness() {
    final uid = _uid;
    if (uid == null) return;
    _wellnessSub = _wellnessService.stream(uid).listen((snapshot) {
      if (mounted) setState(() => _wellness = snapshot);
    });
  }

  Future<void> _markWorkerOnline() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _userService.updateOnlineStatus(uid: uid, isOnline: true);
    } catch (e) {
      debugPrint('Online status error: $e');
    }
  }

  Future<void> _loadWorkerName() async {
    try {
      final uid = _uid;
      if (uid == null) return;

      final workerDoc =
          await FirebaseFirestore.instance.collection('workers').doc(uid).get();
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final authName = FirebaseAuth.instance.currentUser?.displayName;

      final name = workerDoc.data()?['name'] ??
          userDoc.data()?['name'] ??
          authName ??
          'Worker';

      if (mounted) setState(() => _workerName = name.toString());
    } catch (e) {
      debugPrint('Name load error: $e');
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Assigned':
        return _amber;
      case 'Accepted':
      case 'Picked':
        return _blue;
      case 'On the way':
      case 'Delivered':
        return _green;
      case 'Rejected':
      case 'Cancelled':
        return _red;
      default:
        return _primary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Assigned':
        return Icons.assignment_outlined;
      case 'Accepted':
        return Icons.task_alt_rounded;
      case 'Picked':
        return Icons.shopping_bag_outlined;
      case 'On the way':
        return Icons.delivery_dining_rounded;
      case 'Delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  String _nextActionLabel(String status) {
    switch (status) {
      case 'Accepted':
        return 'Mark Picked Up';
      case 'Picked':
        return 'Start Delivery';
      case 'On the way':
        return 'Mark Delivered';
      default:
        return 'Update';
    }
  }

  String _nextStatus(String status) {
    switch (status) {
      case 'Accepted':
        return 'picked';
      case 'Picked':
        return 'on_the_way';
      case 'On the way':
        return 'delivered';
      default:
        return status.toLowerCase().replaceAll(' ', '_');
    }
  }

  Future<void> _openMap({OrderModel? order}) async {
    final query = order == null
        ? '28.61,77.20'
        : '${order.pickup} to ${order.drop}'.trim();
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final uid = _uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Please login to continue')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _orderService.getWorkerOrders(uid),
          builder: (context, snapshot) {
            final orders = _ordersFromSnapshot(snapshot);
            final openOrders = orders.where((o) {
              return o.status == 'assigned' ||
                  o.status == 'accepted' ||
                  o.status == 'picked' ||
                  o.status == 'on_the_way';
            }).toList();
            final activeOrder = openOrders.isEmpty ? null : openOrders.first;
            currentOrderId = activeOrder?.id;

            final todayOrders = _todayOrders(orders);
            final todayCompleted = _todayCompletedOrders(orders);
            final todayEarnings = _todayEarnings(orders);
            final completedOrders =
                orders.where((o) => o.status == 'delivered').length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    todayOrders: todayOrders,
                    completedOrders: completedOrders,
                    activeOrder: activeOrder,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: _buildShiftSummary(
                      todayOrders: todayOrders,
                      todayCompleted: todayCompleted,
                      todayEarnings: todayEarnings,
                      activeOrder: activeOrder,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _buildActiveOrderCard(
                      snapshot: snapshot,
                      activeOrder: activeOrder,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _sectionHeader("Today's Overview"),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildStatsGrid(
                      todayOrders: todayOrders,
                      completedOrders: completedOrders,
                      activeOrder: activeOrder,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _sectionHeader('Quick Actions'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildQuickActionsGrid(isMobile),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: _sectionHeader('Alerts',
                        trailing: _alertBadge(activeOrder == null ? 1 : 2)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: _buildAlerts(activeOrder, orders),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildSOSBar(),
    );
  }

  List<OrderModel> _ordersFromSnapshot(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    if (!snapshot.hasData) return [];
    final orders = snapshot.data!.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  int _todayOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    return orders.where((order) {
      final date = order.createdAt;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  int _todayCompletedOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    return orders.where((order) {
      final date = order.createdAt;
      return order.status == 'delivered' &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  double _todayEarnings(List<OrderModel> orders) {
    final now = DateTime.now();
    return orders.where((order) {
      final date = order.createdAt;
      return order.status == 'delivered' &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).fold<double>(0, (sum, order) => sum + order.payout);
  }

  Widget _buildHeader({
    required int todayOrders,
    required int completedOrders,
    required OrderModel? activeOrder,
  }) {
    final hour = DateTime.now().hour;
    final greeting = _greetingForHour(hour);
    final target = 10;
    final pct = (completedOrders / target).clamp(0.0, 1.0);
    final remaining = (target - completedOrders).clamp(0, target);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkerProfileScreen(),
                  ),
                ).then((_) => _loadWorkerName()),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _workerName.isNotEmpty
                          ? _workerName[0].toUpperCase()
                          : 'W',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _workerName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _headerStatus(activeOrder),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        remaining > 0
                            ? "$remaining orders to hit today's target"
                            : 'Daily target completed',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$completedOrders / $target',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _headerMini('Today', todayOrders.toString()),
                    _headerMini('Completed', completedOrders.toString()),
                    _headerMini(
                      'Mode',
                      activeOrder == null ? 'Idle' : 'Busy',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greetingForHour(int hour) {
    if (hour >= 4 && hour < 12) return 'Good Morning 🌅 ';
    if (hour >= 12 && hour < 18) return 'Good Afternoon ☀️ ';
    if (hour >= 18) return 'Good Evening 🌆 ';
    return 'Good Night 🌙';
  }

  Widget _buildShiftSummary({
    required int todayOrders,
    required int todayCompleted,
    required double todayEarnings,
    required OrderModel? activeOrder,
  }) {
    final completion = todayOrders == 0
        ? 0
        : ((todayCompleted / todayOrders) * 100).clamp(0, 100).round();
    final items = [
      _ShiftMetric(
          Icons.task_alt_rounded, '$completion%', 'Completion', _green),
      _ShiftMetric(Icons.currency_rupee_rounded,
          todayEarnings.toStringAsFixed(0), 'Today', _amber),
      _ShiftMetric(
        activeOrder == null ? Icons.pause_circle_outline : Icons.route_rounded,
        activeOrder == null ? 'Idle' : 'Live',
        'Route',
        activeOrder == null ? _textLight : _blue,
      ),
      _ShiftMetric(
        Icons.coffee_rounded,
        _compactDuration(_wellness.totalBreakSeconds),
        'Break',
        _orange,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _shiftMetricTile(items[i])),
            if (i != items.length - 1)
              Container(width: 1, height: 46, color: const Color(0xFFE2E8F0)),
          ],
        ],
      ),
    );
  }

  Widget _shiftMetricTile(_ShiftMetric metric) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: metric.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(metric.icon, color: metric.color, size: 18),
        ),
        const SizedBox(height: 7),
        Text(
          metric.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textDark,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          metric.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _textLight, fontSize: 10),
        ),
      ],
    );
  }

  Widget _headerStatus(OrderModel? activeOrder) {
    final text = activeOrder == null ? 'Online' : activeOrder.statusText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activeOrder == null ? Icons.circle : _statusIcon(text),
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerMini(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard({
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    required OrderModel? activeOrder,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _loadingCard();
    }
    if (snapshot.hasError) {
      debugPrint('Worker orders stream error: ${snapshot.error}');
      return _emptyOrderCard(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load orders',
        subtitle: _ordersErrorMessage(snapshot.error),
      );
    }
    if (activeOrder == null) {
      return _emptyOrderCard(
        icon: Icons.inbox_outlined,
        title: 'No active order',
        subtitle: 'New assigned orders will appear here in real time.',
      );
    }
    if (activeOrder.isAssignedRequest) {
      return _buildRequestCard(activeOrder);
    }
    return _buildDeliveryCard(activeOrder);
  }

  Widget _loadingCard() {
    return Container(
      height: 156,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  String _ordersErrorMessage(Object? error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Firestore permission denied for orders. Update rules to allow this worker to read assigned orders.';
      }
      if (error.code == 'failed-precondition') {
        return 'Firestore query needs an index. Open debug console for the index link.';
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return '${error.code}: ${error.message}';
      }
      return error.code;
    }
    return error?.toString() ?? 'Check Firestore rules or network connection.';
  }

  Widget _emptyOrderCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: _primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: _textMid, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.radar_rounded, color: _textLight, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _amber.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: _amber.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _iconBox(Icons.assignment_turned_in_outlined, _amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New delivery request',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(color: _textMid, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _statusPill(order.statusText),
              ],
            ),
          ),
          _routeBlock(order),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectOrder(order),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: BorderSide(color: _red.withOpacity(0.45)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptOrder(order),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Accept Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(OrderModel order) {
    final color = _statusColor(order.statusText);

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                _iconBox(_statusIcon(order.statusText), color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Delivery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(fontSize: 12, color: _textMid),
                      ),
                    ],
                  ),
                ),
                _statusPill(order.statusText),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _miniStat(
                  Icons.schedule_rounded,
                  order.eta > 0 ? '${order.eta.toStringAsFixed(0)} min' : '--',
                  'ETA',
                ),
                _vDivider(),
                _miniStat(
                  Icons.near_me_outlined,
                  order.distance > 0
                      ? '${order.distance.toStringAsFixed(1)} km'
                      : '--',
                  'Distance',
                ),
                _vDivider(),
                _miniStat(
                  Icons.currency_rupee_rounded,
                  '₹${order.payout.toStringAsFixed(0)}',
                  'Earning',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: _textMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(order.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: order.progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _routeBlock(order),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openMap(order: order),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Navigate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order),
                    icon: Icon(_statusIcon(order.statusText), size: 16),
                    label: Text(_nextActionLabel(order.statusText)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeBlock(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(width: 2, height: 34, color: const Color(0xFFCBD5E1)),
                const Icon(Icons.location_on_rounded, color: _red, size: 17),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _routeText('Pickup', order.pickup),
                  const SizedBox(height: 12),
                  _routeText('Drop', order.drop),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textLight, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? 'Not provided' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptOrder(OrderModel order) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      HapticFeedback.mediumImpact();
      await _orderService.acceptOrder(orderId: order.id, workerId: uid);
      if (mounted) _snack('Order accepted');
    } catch (e) {
      if (mounted) _snack(e.toString());
    }
  }

  Future<void> _rejectOrder(OrderModel order) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      HapticFeedback.lightImpact();
      await _orderService.rejectOrder(orderId: order.id, workerId: uid);
      if (mounted) _snack('Order rejected');
    } catch (e) {
      if (mounted) _snack(e.toString());
    }
  }

  Future<void> _updateOrderStatus(OrderModel order) async {
    try {
      HapticFeedback.mediumImpact();
      await _orderService.updateOrderStatus(
        orderId: order.id,
        status: _nextStatus(order.statusText),
      );
      if (mounted) _snack('Status updated');
    } catch (e) {
      if (mounted) _snack(e.toString());
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: _textLight)),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: const Color(0xFFE2E8F0));

  Widget _buildStatsGrid({
    required int todayOrders,
    required int completedOrders,
    required OrderModel? activeOrder,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 600 && width < 1024;
    final stats = [
      _statCard(
        icon: Icons.local_shipping_outlined,
        value: '$todayOrders',
        label: "Today's Orders",
        gradient: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeliveryListScreen()),
        ),
      ),
      _statCard(
        icon: Icons.check_circle_outline,
        value: '$completedOrders',
        label: 'Completed',
        gradient: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
      _statCard(
        icon: Icons.timer_outlined,
        value: _compactDuration(_wellness.totalBreakSeconds),
        label: 'Break Taken',
        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BreakReminderScreen()),
        ),
      ),
      _statCard(
        icon: activeOrder == null
            ? Icons.health_and_safety_outlined
            : Icons.delivery_dining_rounded,
        value: activeOrder == null
            ? _wellness.healthStatus
            : activeOrder.statusText,
        label: activeOrder == null ? 'Health Status' : 'Current Status',
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => activeOrder == null
                ? const HealthStatusScreen()
                : const DeliveryListScreen(),
          ),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: isDesktop
            ? 156
            : isTablet
                ? 150
                : 140,
      ),
      itemBuilder: (_, index) => stats[index],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 19),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white54, size: 12),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _compactDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
  }

  Widget _buildQuickActionsGrid(bool isMobile) {
    final actions = [
      _Action(Icons.inventory_2_outlined, 'Deliveries', 'My orders',
          const DeliveryListScreen()),
      _Action(
        Icons.route_outlined,
        'Navigation',
        'Live route',
        const NavigationScreen(),
        onTap: () => _openMap(),
      ),
      _Action(Icons.favorite_outline, 'Health', 'Body stats',
          const HealthStatusScreen()),
      _Action(Icons.coffee_outlined, 'Break', 'Rest timer',
          const BreakReminderScreen()),
      _Action(Icons.account_balance_wallet_outlined, 'Earnings', 'My wallet',
          const EarningsWalletScreen()),
      _Action(Icons.history_rounded, 'History', 'Past orders',
          const OrderHistoryScreen()),
    ];

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1200
        ? 6
        : width >= 900
            ? 4
            : isMobile
                ? 3
                : 4;
    final tileHeight = width >= 1200
        ? 122.0
        : width >= 900
            ? 128.0
            : isMobile
                ? 118.0
                : 126.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: tileHeight,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      itemBuilder: (_, i) => _quickActionTile(actions[i]),
    );
  }

  Widget _quickActionTile(_Action action) {
    return InkWell(
      onTap: action.onTap ??
          () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => action.screen),
              ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primary.withValues(alpha: 0.12),
                    _blue.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: _primary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              action.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: _textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(OrderModel? activeOrder, List<OrderModel> orders) {
    final assignedOrders =
        orders.where((order) => order.status == 'assigned').toList();
    final latestAssigned = assignedOrders.isEmpty ? null : assignedOrders.first;
    return Column(
      children: [
        _alertTile(
          icon: Icons.timer_outlined,
          color: _orange,
          title: 'Take a short break',
          subtitle: "You've been active for 1h 45m",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BreakReminderScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _alertTile(
          icon: latestAssigned != null
              ? Icons.assignment_turned_in_rounded
              : activeOrder == null
                  ? Icons.notifications_none_rounded
                  : Icons.route_rounded,
          color: latestAssigned != null
              ? _primary
              : activeOrder == null
                  ? _blue
                  : _red,
          title: latestAssigned != null
              ? 'New order assigned'
              : activeOrder == null
                  ? 'Ready for new orders'
                  : 'Check route',
          subtitle: latestAssigned != null
              ? '${latestAssigned.pickup} to ${latestAssigned.drop}'
              : activeOrder == null
                  ? assignedOrders.isEmpty
                      ? 'Stay online to receive assignments'
                      : '${assignedOrders.length} orders waiting'
                  : 'Open navigation before leaving pickup',
          onTap: latestAssigned != null
              ? () => _openMap(order: latestAssigned)
              : activeOrder == null
                  ? null
                  : () => _openMap(order: activeOrder),
        ),
      ],
    );
  }

  Widget _alertTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x07000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textMid),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _textLight, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ScaleTransition(
        scale: _pulseAnim,
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _showSOSDialog(context),
            icon: const Icon(Icons.emergency_rounded,
                color: Colors.white, size: 20),
            label: const Text(
              'SOS Emergency',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSOSDialog(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final position = await _getCurrentLocation();
    final lat = position?.latitude ?? 0.0;
    final lng = position?.longitude ?? 0.0;

    final uid = _uid;
    if (uid != null && position != null) {
      await _userService.updateLocation(uid: uid, lat: lat, lng: lng);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SOSSheet(
        lat: lat,
        lng: lng,
        emergencyPhone: _emergencyPhone,
        emergencySms: _emergencySms,
        orderId: currentOrderId,
        workerId: uid,
      ),
    );
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location error: $e');
      return null;
    }
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: _textDark,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _alertBadge(int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$count new',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: _red,
          ),
        ),
      );
}

class _SOSSheet extends StatelessWidget {
  final double lat;
  final double lng;
  final String emergencyPhone;
  final String emergencySms;
  final String? orderId;
  final String? workerId;

  const _SOSSheet({
    required this.lat,
    required this.lng,
    required this.emergencyPhone,
    required this.emergencySms,
    this.orderId,
    this.workerId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS Emergency',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Choose an action below',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sosAction(
            icon: Icons.call_rounded,
            label: 'Call Emergency',
            sub: 'Dial emergency contact',
            color: const Color(0xFFEF4444),
            onTap: () async {
              final uri = Uri.parse(emergencyPhone);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          const SizedBox(height: 10),
          _sosAction(
            icon: Icons.sms_outlined,
            label: 'Send SMS Alert',
            sub: 'Send location via SMS',
            color: const Color(0xFFF59E0B),
            onTap: () async {
              final msg =
                  'Emergency! Location: https://maps.google.com/?q=$lat,$lng';
              final uri =
                  Uri.parse('$emergencySms?body=${Uri.encodeComponent(msg)}');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          const SizedBox(height: 10),
          _sosAction(
            icon: Icons.chat_outlined,
            label: 'Share on WhatsApp',
            sub: 'Send location to contact',
            color: const Color(0xFF10B981),
            onTap: () async {
              final text =
                  'Emergency! My location: https://maps.google.com/?q=$lat,$lng';
              final uri =
                  Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseFirestore.instance.collection('alerts').add({
                  'type': 'SOS',
                  'lat': lat,
                  'lng': lng,
                  'time': FieldValue.serverTimestamp(),
                  'read': false,
                  'resolved': false,
                  'workerId': workerId ?? '',
                  'orderId': orderId,
                });
                if (workerId != null) {
                  await FirebaseFirestore.instance
                      .collection('workers')
                      .doc(workerId)
                      .set({'hasSOS': true}, SetOptions(merge: true));
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin alerted successfully'),
                      backgroundColor: Color(0xFFEF4444),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_rounded,
                  color: Colors.white),
              label: const Text(
                'Alert Admin Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sosAction({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;
  final VoidCallback? onTap;

  const _Action(
    this.icon,
    this.title,
    this.subtitle,
    this.screen, {
    this.onTap,
  });
}

class _ShiftMetric {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ShiftMetric(this.icon, this.value, this.label, this.color);
}
