import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class DeliveryListScreen extends StatelessWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "My Deliveries",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _orderCard(context, "Order #101", "Domino's Pizza", "Sector 15",
              "On the way", "12 min", "2.5 km"),

          _orderCard(context, "Order #102", "KFC", "City Mall",
              "Pending", "25 min", "5.1 km"),

          _orderCard(context, "Order #103", "Burger King", "Metro Station",
              "On the way", "10 min", "1.8 km"),

          _orderCard(context, "Order #104", "Cafe Coffee Day", "Tech Park",
              "Delivered", "Completed", "3.0 km"),

          _orderCard(context, "Order #105", "Biryani House", "Sector 22",
              "On the way", "18 min", "4.2 km"),

          _orderCard(context, "Order #106", "McDonald's", "Bus Stand",
              "Pending", "30 min", "6.5 km"),

          _orderCard(context, "Order #107", "Subway", "Railway Station",
              "Delivered", "Completed", "2.0 km"),

          _orderCard(context, "Order #108", "Pizza Hut", "Shopping Complex",
              "On the way", "14 min", "3.7 km"),
        ],
      ),
    );
  }

  /// 🔥 ORDER CARD
  Widget _orderCard(BuildContext context, String id, String pickup,
      String drop, String status, String eta, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              _statusChip(status),
            ],
          ),

          const SizedBox(height: 12),

          /// 📍 ROUTE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  Container(
                    width: 2,
                    height: 40,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const Icon(Icons.location_on, color: Colors.red),
                ],
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      drop,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 📊 INFO
          Row(
            children: [
              _infoChip(Icons.timer_outlined, eta),
              const SizedBox(width: 10),
              _infoChip(Icons.place_outlined, distance),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔘 BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationScreen(),
                  ),
                );
              },
              child: const Text(
                "Track Delivery",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📊 INFO CHIP
  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 🟢 STATUS CHIP
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "On the way":
        color = const Color(0xFF16A34A);
        break;
      case "Pending":
        color = const Color(0xFFF59E0B);
        break;
      case "Delivered":
        color = const Color(0xFF2563EB);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}