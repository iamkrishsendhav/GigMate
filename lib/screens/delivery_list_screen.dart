import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gigmate/services/order_service.dart';
import 'package:gigmate/models/order_model.dart';
import 'navigation_screen.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  final _orderService = OrderService();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// 🔥 STATUS FLOW
  String _nextStatus(String current) {
    if (current == "Assigned") return "accepted";
    if (current == "Accepted") return "picked";
    if (current == "Picked") return "on_the_way";
    if (current == "On the way") return "delivered";
    return "delivered";
  }

  /// 🎨 STATUS COLOR
  Color _statusColor(String status) {
    switch (status) {
      case "Pending":
      case "Assigned":
        return Colors.orange;
      case "Accepted":
        return Colors.indigo;
      case "Picked":
        return Colors.blue;
      case "On the way":
        return Colors.green;
      case "Delivered":
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// 📊 PROGRESS VALUE
  double _progress(String status) {
    switch (status) {
      case "Pending":
      case "Assigned":
        return 0.12;
      case "Accepted":
        return 0.2;
      case "Picked":
        return 0.5;
      case "On the way":
        return 0.8;
      case "Delivered":
        return 1.0;
      default:
        return 0.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("My Deliveries"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      /// 🔥 REALTIME LIST
      body: StreamBuilder(
        stream: _orderService.getWorkerOrders(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No deliveries assigned"));
          }

          final orders = docs.map((doc) {
            return OrderModel.fromMap(
              doc.id,
              doc.data(),
            );
          }).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              return _orderCard(orders[i]);
            },
          );
        },
      ),
    );
  }

  /// 🔥 ORDER CARD (PREMIUM UI)
  Widget _orderCard(OrderModel order) {
    final status = order.statusText;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order #${order.id}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              _statusChip(status),
            ],
          ),

          const SizedBox(height: 10),

          /// PROGRESS
          LinearProgressIndicator(
            value: _progress(status),
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),

          const SizedBox(height: 14),

          /// ROUTE
          Row(
            children: [
              Column(
                children: const [
                  Icon(Icons.circle, size: 10, color: Colors.white),
                  SizedBox(height: 4),
                  SizedBox(
                      width: 2,
                      height: 35,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white54),
                      )),
                  SizedBox(height: 4),
                  Icon(Icons.location_on, color: Colors.white),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.pickup,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(order.drop,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// INFO
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(Icons.timer, "${order.eta} min"),
              _chip(Icons.place, "${order.distance} km"),
              _chip(Icons.currency_rupee_rounded,
                  order.payout > 0 ? order.payout.toStringAsFixed(0) : "0"),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Order earning",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "₹${order.payout.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          /// ACTIONS
          Row(
            children: [
              /// TRACK
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NavigationScreen(order: order),
                      ),
                    );
                  },
                  child: const Text("Track"),
                ),
              ),

              const SizedBox(width: 10),

              /// UPDATE STATUS
              if (status != "Delivered")
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      if (status == "Assigned") {
                        await _orderService.acceptOrder(
                          orderId: order.id,
                          workerId: uid,
                        );
                      } else {
                        await _orderService.updateOrderStatus(
                          orderId: order.id,
                          status: _nextStatus(status),
                        );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Status Updated 🚀"),
                        ),
                      );
                    },
                    child: const Text("Update"),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}
