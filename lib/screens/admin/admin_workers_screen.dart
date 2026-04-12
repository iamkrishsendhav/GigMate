import 'package:flutter/material.dart';

class AdminWorkersScreen extends StatefulWidget {
  const AdminWorkersScreen({super.key});

  @override
  State<AdminWorkersScreen> createState() => _AdminWorkersScreenState();
}

class _AdminWorkersScreenState extends State<AdminWorkersScreen> {
  String selectedFilter = "All";

  final List<Map<String, dynamic>> workers = [
    {
      "name": "Ravi Kumar",
      "id": "W-101",
      "status": "Online",
      "deliveries": 18,
      "rating": 4.8,
      "area": "Sector 15",
      "shift": "Morning",
    },
    {
      "name": "Aman Singh",
      "id": "W-102",
      "status": "On Delivery",
      "deliveries": 12,
      "rating": 4.6,
      "area": "City Mall",
      "shift": "Evening",
    },
    {
      "name": "Neha Verma",
      "id": "W-103",
      "status": "Break",
      "deliveries": 9,
      "rating": 4.9,
      "area": "Railway Station",
      "shift": "Morning",
    },
    {
      "name": "Suresh Yadav",
      "id": "W-104",
      "status": "Offline",
      "deliveries": 22,
      "rating": 4.4,
      "area": "Tech Park",
      "shift": "Night",
    },
    {
      "name": "Priya Sharma",
      "id": "W-105",
      "status": "Online",
      "deliveries": 15,
      "rating": 4.7,
      "area": "Bus Stand",
      "shift": "Evening",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredWorkers = workers.where((worker) {
      if (selectedFilter == "All") return true;
      return worker["status"] == selectedFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search workers",
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
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _filterChip("All"),
              _filterChip("Online"),
              _filterChip("On Delivery"),
              _filterChip("Break"),
              _filterChip("Offline"),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: "Total Workers",
                  value: "5",
                  icon: Icons.people,
                  color: const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  title: "Active",
                  value: "3",
                  icon: Icons.bolt,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: filteredWorkers.length,
            itemBuilder: (context, index) {
              final worker = filteredWorkers[index];
              return _workerCard(worker);
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _workerCard(Map<String, dynamic> worker) {
    final Color statusColor = _getStatusColor(worker["status"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF0D9488).withOpacity(0.12),
                child: Text(
                  worker["name"][0],
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${worker["id"]} • ${worker["area"]}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              _statusBadge(worker["status"], statusColor),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _infoBox("Deliveries", "${worker["deliveries"]}")),
              const SizedBox(width: 10),
              Expanded(child: _infoBox("Rating", "${worker["rating"]} ⭐")),
              const SizedBox(width: 10),
              Expanded(child: _infoBox("Shift", worker["shift"])),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on_outlined),
                  label: const Text("Track"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    foregroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined),
                  label: const Text("Message"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case "Online":
        return Colors.green;
      case "On Delivery":
        return Colors.blue;
      case "Break":
        return Colors.orange;
      case "Offline":
        return Colors.grey;
      default:
        return const Color(0xFF0D9488);
    }
  }
}