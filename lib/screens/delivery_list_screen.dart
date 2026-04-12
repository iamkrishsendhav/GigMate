import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class DeliveryListScreen extends StatelessWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Deliveries")),

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

  Widget _orderCard(BuildContext context, String id, String pickup,
      String drop, String status, String eta, String distance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),

              _statusChip(status),
            ],
          ),

          const SizedBox(height: 10),

          // 📍 ROUTE
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  Container(width: 2, height: 30, color: Colors.grey),
                  const Icon(Icons.location_on, color: Colors.red),
                ],
              ),
              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pickup: $pickup"),
                  const SizedBox(height: 5),
                  Text("Drop: $drop"),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 📊 INFO ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("⏱ $eta"),
              Text("📍 $distance"),
            ],
          ),

          const SizedBox(height: 10),

          // 🔘 BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NavigationScreen()),
              );
            },
            child: const Text("Track Delivery"),
          ),
        ],
      ),
    );
  }

  // 🟢 STATUS CHIP
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "On the way":
        color = Colors.green;
        break;
      case "Pending":
        color = Colors.orange;
        break;
        case "Delivered":
  color = Colors.blue;
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}