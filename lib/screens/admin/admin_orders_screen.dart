// import 'package:flutter/material.dart';
// import 'package:gigmate/services/order_service.dart';
// import 'package:gigmate/services/user_service.dart';
// import 'package:gigmate/models/order_model.dart';
// import 'package:gigmate/models/user_model.dart';

// // ═══════════════════════════════════════════════════════════════════
// //  AdminOrdersScreen — GigMate Pro
// //  Features: Search · Filter tabs · Order cards with full actions
// // ═══════════════════════════════════════════════════════════════════

// class AdminOrdersScreen extends StatefulWidget {
//   const AdminOrdersScreen({super.key});

//   @override
//   State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
// }

// class _AdminOrdersScreenState extends State<AdminOrdersScreen> {

//   static const Color _primary   = Color(0xFF0F766E);
//   static const Color _textDark  = Color(0xFF0F172A);
//   static const Color _textMid   = Color(0xFF475569);
//   static const Color _textLight = Color(0xFF94A3B8);
//   static const Color _red       = Color(0xFFEF4444);
//   static const Color _green     = Color(0xFF10B981);
//   static const Color _amber     = Color(0xFFF59E0B);
//   static const Color _blue      = Color(0xFF3B82F6);

//   String _searchQuery = "";
//   String _selectedFilter = "All";
//   final _searchCtrl = TextEditingController();

//   final List<String> _filters = ["All", "Pending", "Picked", "On the way", "Delivered", "Cancelled"];

//   // Sample orders data
//   final List<_Order> _orders = const [
//     _Order("101", "Domino's", "Sector 15", "Ravi Kumar",
//         "On the way", "2:30 PM", "Paid", "High", "12 min", "2.5 km", 0.75),
//     _Order("102", "McDonald's", "Sector 22", "Priya Sharma",
//         "Delivered", "2:10 PM", "Paid", "Normal", "—", "4.1 km", 1.0),
//     _Order("103", "KFC", "Sector 8", "Mohit Verma",
//         "Pending", "2:45 PM", "Unpaid", "High", "25 min", "6.0 km", 0.0),
//     _Order("104", "Subway", "Sector 30", "Arjun Singh",
//         "Picked", "3:00 PM", "Paid", "Normal", "18 min", "3.3 km", 0.3),
//     _Order("105", "Pizza Hut", "Sector 4", "Ravi Kumar",
//         "Cancelled", "1:50 PM", "Refunded", "Low", "—", "1.8 km", 0.0),
//     _Order("106", "Burger King", "Sector 11", "Priya Sharma",
//         "On the way", "3:15 PM", "Paid", "Normal", "8 min", "2.0 km", 0.9),
//   ];

//   List<_Order> get _filtered {
//     return _orders.where((o) {
//       final matchFilter = _selectedFilter == "All" || o.status == _selectedFilter;
//       final matchSearch = _searchQuery.isEmpty ||
//           o.id.contains(_searchQuery) ||
//           o.pickup.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           o.worker.toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           o.drop.toLowerCase().contains(_searchQuery.toLowerCase());
//       return matchFilter && matchSearch;
//     }).toList();
//   }

//   Color _statusColor(String s) {
//     switch (s) {
//       case "Pending":    return _amber;
//       case "Picked":     return _blue;
//       case "On the way": return _green;
//       case "Delivered":  return const Color(0xFF10B981);
//       case "Cancelled":  return _red;
//       default:           return _textLight;
//     }
//   }

//   IconData _statusIcon(String s) {
//     switch (s) {
//       case "Pending":    return Icons.hourglass_empty_rounded;
//       case "Picked":     return Icons.shopping_bag_outlined;
//       case "On the way": return Icons.delivery_dining_rounded;
//       case "Delivered":  return Icons.check_circle_outline;
//       case "Cancelled":  return Icons.cancel_outlined;
//       default:           return Icons.circle_outlined;
//     }
//   }

//   Color _priorityColor(String p) {
//     switch (p) {
//       case "High": return _red;
//       case "Low":  return _textLight;
//       default:     return _blue;
//     }
//   }

//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // ── Search + filter area
//         Container(
//           color: Colors.white,
//           padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//           child: Column(
//             children: [
//               // Search bar
//               TextField(
//                 controller: _searchCtrl,
//                 onChanged: (v) => setState(() => _searchQuery = v),
//                 decoration: InputDecoration(
//                   hintText: "Search by order ID, worker or location...",
//                   hintStyle: const TextStyle(
//                       fontSize: 13, color: Color(0xFF94A3B8)),
//                   prefixIcon: const Icon(Icons.search_rounded,
//                       color: Color(0xFF94A3B8), size: 20),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.close_rounded, size: 18),
//                           onPressed: () {
//                             _searchCtrl.clear();
//                             setState(() => _searchQuery = "");
//                           })
//                       : null,
//                   filled: true,
//                   fillColor: const Color(0xFFF8FAFC),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // Filter chips
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: _filters.map((f) {
//                     final sel = f == _selectedFilter;
//                     return GestureDetector(
//                       onTap: () => setState(() => _selectedFilter = f),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 180),
//                         margin: const EdgeInsets.only(right: 8, bottom: 12),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 14, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: sel ? _primary : const Color(0xFFF1F5F9),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                         child: Text(f,
//                             style: TextStyle(
//                                 color: sel ? Colors.white : _textMid,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600)),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // ── Order count row
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("${_filtered.length} orders",
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: _textMid)),
//               GestureDetector(
//                 onTap: () => ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Sorting coming soon"))),
//                 child: Row(
//                   children: const [
//                     Icon(Icons.sort_rounded,
//                         color: Color(0xFF0F766E), size: 16),
//                     SizedBox(width: 4),
//                     Text("Sort",
//                         style: TextStyle(
//                             color: Color(0xFF0F766E),
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // ── Order list
//         Expanded(
//           child: _filtered.isEmpty
//               ? _emptyState()
//               : ListView.separated(
//                   padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
//                   itemCount: _filtered.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 12),
//                   itemBuilder: (_, i) => _buildOrderCard(_filtered[i]),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOrderCard(_Order o) {
//     final statusColor = _statusColor(o.status);
//     final priColor    = _priorityColor(o.priority);
//     final isDone      = o.status == "Delivered" || o.status == "Cancelled";

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//             color: statusColor.withOpacity(0.15)),
//         boxShadow: const [
//           BoxShadow(
//               color: Color(0x07000000),
//               blurRadius: 12,
//               offset: Offset(0, 4)),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Card header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
//             child: Row(
//               children: [
//                 // Order number
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _primary.withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text("Order #${o.id}",
//                       style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w800,
//                           color: _primary)),
//                 ),
//                 const SizedBox(width: 8),

//                 // Time
//                 Text(o.time,
//                     style: const TextStyle(
//                         fontSize: 12, color: _textLight)),
//                 const Spacer(),

//                 // Priority badge
//                 if (o.priority != "Normal")
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: priColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(o.priority,
//                         style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: priColor)),
//                   ),

//                 const SizedBox(width: 8),

//                 // Status chip
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(_statusIcon(o.status),
//                           size: 11, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(o.status,
//                           style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: statusColor)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ── Route info
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       width: 10, height: 10,
//                       decoration: const BoxDecoration(
//                           color: Color(0xFF10B981),
//                           shape: BoxShape.circle),
//                     ),
//                     Container(
//                         width: 1.5, height: 28,
//                         color: const Color(0xFFE2E8F0)),
//                     const Icon(Icons.location_on_rounded,
//                         color: Color(0xFFEF4444), size: 14),
//                   ],
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Pickup: ${o.pickup}",
//                           style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: _textDark)),
//                       const SizedBox(height: 12),
//                       Text("Drop: ${o.drop}",
//                           style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: _textDark)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // ── Meta row: worker, payment, ETA, distance
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 _metaChip(Icons.person_outline, o.worker),
//                 const SizedBox(width: 8),
//                 _metaChip(
//                     o.payment == "Paid"
//                         ? Icons.check_circle_outline
//                         : Icons.money_off_outlined,
//                     o.payment,
//                     color: o.payment == "Paid" ? _green : _red),
//                 const Spacer(),
//                 if (!isDone) ...[
//                   _metaChip(Icons.schedule_rounded, o.eta),
//                   const SizedBox(width: 8),
//                 ],
//                 _metaChip(Icons.near_me_outlined, o.distance),
//               ],
//             ),
//           ),

//           // ── Progress bar
//           if (!isDone)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(999),
//                 child: LinearProgressIndicator(
//                   value: o.progress,
//                   minHeight: 4,
//                   backgroundColor: const Color(0xFFE2E8F0),
//                   valueColor: AlwaysStoppedAnimation<Color>(statusColor),
//                 ),
//               ),
//             ),

//           const SizedBox(height: 12),

//           // ── Action buttons
//           const Divider(height: 1, color: Color(0xFFF1F5F9)),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 _actionBtn("Assign", Icons.person_add_outlined,
//                     Colors.white, _primary, bordered: true, onTap: () {
//                   _showAssignWorkerDialog(o);
//                 }),
//                 const SizedBox(width: 8),
//                 _actionBtn("Track", Icons.map_outlined,
//                     Colors.white, _primary, filled: true, onTap: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                         content: Text("Tracking Order #${o.id}")));
//                 }),
//                 const SizedBox(width: 8),
//                 _actionBtn("Details", Icons.info_outline,
//                     Colors.white, _primary, bordered: true, onTap: () {
//                   _showOrderDetails(o);
//                 }),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _metaChip(IconData icon, String text, {Color? color}) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon,
//             size: 13,
//             color: color ?? const Color(0xFF94A3B8)),
//         const SizedBox(width: 4),
//         Text(text,
//             style: TextStyle(
//                 fontSize: 12,
//                 color: color ?? const Color(0xFF475569),
//                 fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//   Widget _actionBtn(
//     String label,
//     IconData icon,
//     Color fg,
//     Color color, {
//     bool filled = false,
//     bool bordered = false,
//     VoidCallback? onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: filled ? color : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//             border: bordered
//                 ? Border.all(color: color.withOpacity(0.5))
//                 : null,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon,
//                   size: 14,
//                   color: filled ? Colors.white : color),
//               const SizedBox(width: 5),
//               Text(label,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       color: filled ? Colors.white : color)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inbox_rounded,
//               size: 64, color: Colors.grey[300]),
//           const SizedBox(height: 12),
//           const Text("No orders found",
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF94A3B8))),
//         ],
//       ),
//     );
//   }

//   void _showAssignWorkerDialog(_Order o) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (_) => Container(
//         padding: const EdgeInsets.all(24),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Assign Worker — Order #${o.id}",
//                 style: const TextStyle(
//                     fontSize: 16, fontWeight: FontWeight.w800)),
//             const SizedBox(height: 16),
//             ...["Ravi Kumar", "Priya Sharma", "Mohit Verma", "Arjun Singh"]
//                 .map((w) => ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor:
//                             _primary.withOpacity(0.1),
//                         child: Text(w[0],
//                             style: const TextStyle(
//                                 color: _primary,
//                                 fontWeight: FontWeight.w700)),
//                       ),
//                       title: Text(w,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.w600)),
//                       subtitle: const Text("Available • 2 km away"),
//                       trailing: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text(
//                                     "$w assigned to Order #${o.id}")),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _primary,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 8),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                         ),
//                         child: const Text("Assign",
//                             style: TextStyle(
//                                 color: Colors.white, fontSize: 12)),
//                       ),
//                     )),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showOrderDetails(_Order o) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => DraggableScrollableSheet(
//         initialChildSize: 0.6,
//         maxChildSize: 0.92,
//         minChildSize: 0.4,
//         builder: (_, ctrl) => Container(
//           padding: const EdgeInsets.all(24),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: ListView(
//             controller: ctrl,
//             children: [
//               Center(
//                 child: Container(
//                   width: 36, height: 4,
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                       color: const Color(0xFFE2E8F0),
//                       borderRadius: BorderRadius.circular(999)),
//                 ),
//               ),
//               Text("Order #${o.id} Details",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.w800)),
//               const SizedBox(height: 20),
//               _detailRow("Status", o.status),
//               _detailRow("Pickup", o.pickup),
//               _detailRow("Drop", o.drop),
//               _detailRow("Worker", o.worker),
//               _detailRow("Payment", o.payment),
//               _detailRow("Priority", o.priority),
//               _detailRow("ETA", o.eta),
//               _detailRow("Distance", o.distance),
//               _detailRow("Time", o.time),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(String key, String val) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(key,
//                 style: const TextStyle(
//                     fontSize: 13, color: Color(0xFF94A3B8))),
//           ),
//           Expanded(
//             child: Text(val,
//                 style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF0F172A))),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Order model
// class _Order {
//   final String id, pickup, drop, worker, status, time,
//       payment, priority, eta, distance;
//   final double progress;
//   const _Order(this.id, this.pickup, this.drop, this.worker,
//       this.status, this.time, this.payment, this.priority,
//       this.eta, this.distance, this.progress);
// }

import 'package:flutter/material.dart';
import 'package:gigmate/services/order_service.dart';
import 'package:gigmate/services/user_service.dart';
import 'package:gigmate/models/order_model.dart';
import 'package:gigmate/models/user_model.dart';
import 'admin_live_tracking_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderService = OrderService();
  final _userService = UserService();

  String _searchQuery = "";
  String _selectedFilter = "All";
  final _searchCtrl = TextEditingController();

  final List<String> _filters = [
    "All",
    "Pending",
    "Assigned",
    "Accepted",
    "Picked",
    "On the way",
    "Delivered",
    "Rejected",
    "Cancelled"
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// 🔥 STATUS MAPPING
  String getStatusText(String status) {
    switch (status) {
      case "pending":
        return "Pending";
      case "picked":
        return "Picked";
      case "on_the_way":
        return "On the way";
      case "delivered":
        return "Delivered";
      case "cancelled":
        return "Cancelled";
      default:
        return status;
    }
  }

  Color getStatusColor(String s) {
    switch (s) {
      case "Pending":
        return Colors.orange;
      case "Assigned":
        return Colors.amber;
      case "Accepted":
        return Colors.indigo;
      case "Picked":
        return Colors.blue;
      case "On the way":
        return Colors.green;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search orders...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// FILTER
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final sel = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? Colors.teal : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          /// 🔥 REALTIME ORDERS
          Expanded(
            child: StreamBuilder(
              stream: _orderService.getAllOrders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final orders = docs.map((doc) {
                  return OrderModel.fromMap(
                    doc.id,
                    doc.data(),
                  );
                }).toList();

                /// FILTER
                final filtered = orders.where((o) {
                  final status = o.statusText;

                  final matchFilter =
                      _selectedFilter == "All" || status == _selectedFilter;

                  final matchSearch = _searchQuery.isEmpty ||
                      o.id.contains(_searchQuery) ||
                      o.pickup
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      o.drop.toLowerCase().contains(_searchQuery.toLowerCase());

                  return matchFilter && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    return _buildOrderCard(filtered[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 ORDER CARD
  Widget _buildOrderCard(OrderModel o) {
    final status = o.statusText;
    final color = getStatusColor(status);
    final isClosed = o.status == 'delivered' ||
        o.status == 'cancelled' ||
        o.status == 'rejected';

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text("Order #${o.id}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: color)),
              )
            ],
          ),

          const SizedBox(height: 10),

          Text("Pickup: ${o.pickup}"),
          Text("Drop: ${o.drop}"),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metaChip(Icons.currency_rupee_rounded,
                  "Payout ₹${o.payout.toStringAsFixed(0)}"),
              _metaChip(
                  Icons.near_me_outlined,
                  o.distance > 0
                      ? "${o.distance.toStringAsFixed(1)} km"
                      : "--"),
              _metaChip(Icons.schedule_rounded,
                  o.eta > 0 ? "${o.eta.toStringAsFixed(0)} min" : "--"),
            ],
          ),

          const SizedBox(height: 10),

          Text("Worker: ${o.workerId != null ? "Assigned" : "Not Assigned"}"),

          const SizedBox(height: 12),

          /// ACTIONS
          LayoutBuilder(
            builder: (context, constraints) {
              final stackActions = constraints.maxWidth < 280;
              final assignButton = ElevatedButton(
                onPressed: () => _showAssignDialog(o),
                child: const Text("Assign"),
              );
              final trackButton = ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AdminLiveTrackingScreen()),
                ),
                child: const Text("Track"),
              );
              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isClosed) ...[
                      assignButton,
                      const SizedBox(height: 8),
                    ],
                    trackButton,
                  ],
                );
              }
              return Row(
                children: [
                  if (!isClosed) ...[
                    Expanded(child: assignButton),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: trackButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🔥 ASSIGN WORKER
  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.teal),
          const SizedBox(width: 4),
          Text(text,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showAssignDialog(OrderModel order) {
    if (order.status == 'delivered' ||
        order.status == 'cancelled' ||
        order.status == 'rejected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completed orders cannot be assigned")),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return StreamBuilder(
          stream: _userService.getAvailableWorkers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final workers = snapshot.data!.docs;

            return ListView(
              children: workers.map((doc) {
                final user = UserModel.fromMap(
                  doc.id,
                  doc.data(),
                );

                return ListTile(
                  title: Text(user.name),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _orderService.assignWorker(
                        orderId: order.id,
                        workerId: user.uid,
                      );

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text("Assign"),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
