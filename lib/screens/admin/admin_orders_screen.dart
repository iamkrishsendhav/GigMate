import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String selectedFilter = "All";

  final orders = [
    {
      "id": "Order #101",
      "status": "On the way",
      "pickup": "Domino's",
      "drop": "Sector 15",
      "eta": "12 min",
      "distance": "2.5 km"
    },
    {
      "id": "Order #102",
      "status": "Pending",
      "pickup": "KFC",
      "drop": "City Mall",
      "eta": "25 min",
      "distance": "5 km"
    },
    {
      "id": "Order #103",
      "status": "Delivered",
      "pickup": "Burger King",
      "drop": "Metro Station",
      "eta": "Done",
      "distance": "2 km"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = orders.where((o) =>
        selectedFilter == "All" || o["status"] == selectedFilter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search Orders",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        SizedBox(
          height: 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip("All"),
              _chip("Pending"),
              _chip("On the way"),
              _chip("Delivered"),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final o = filtered[index];
              return _orderCard(o);
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label) {
    final selected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D9488) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _orderCard(Map<String, String> o) {
    Color statusColor = o["status"] == "On the way"
        ? Colors.green
        : o["status"] == "Pending"
            ? Colors.orange
            : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(o["id"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              _status(o["status"]!, statusColor),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  Container(height: 30, width: 2, color: Colors.grey),
                  const Icon(Icons.location_on, color: Colors.red),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pickup: ${o["pickup"]}"),
                  Text("Drop: ${o["drop"]}"),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("⏱ ${o["eta"]}"),
              Text("📍 ${o["distance"]}"),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("Assign"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                  child: const Text("Track"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _status(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}