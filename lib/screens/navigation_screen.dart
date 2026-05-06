import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? mapController;

  // 📍 Locations
  final LatLng pickup = const LatLng(28.6139, 77.2090);
  final LatLng drop = const LatLng(28.6300, 77.2200);

  List<LatLng> routePoints = [];
  LatLng currentPosition = const LatLng(28.6139, 77.2090);

  Timer? movementTimer;
  int routeIndex = 0;

  @override
  void initState() {
    super.initState();
    generateRoute();
  }

  // 🛣️ Route generation (FIXED)
  void generateRoute() {
    routePoints.clear(); // 🔥 IMPORTANT FIX

    for (int i = 0; i <= 25; i++) {
      double lat = pickup.latitude +
          (drop.latitude - pickup.latitude) * i / 25;
      double lng = pickup.longitude +
          (drop.longitude - pickup.longitude) * i / 25;

      routePoints.add(LatLng(lat, lng));
    }
  }

  // 🚚 Start movement ONLY after map ready (FIXED)
  void startMovement() {
    movementTimer?.cancel();

    movementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (routeIndex < routePoints.length) {
        setState(() {
          currentPosition = routePoints[routeIndex];
          routeIndex++;
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLng(currentPosition),
        );
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }

  Widget buildMap() {
  return GoogleMap(
    initialCameraPosition:
        CameraPosition(target: pickup, zoom: 14),

    markers: {
      Marker(
          markerId: const MarkerId("pickup"),
          position: pickup,
          infoWindow: const InfoWindow(title: "Pickup")),

      Marker(
          markerId: const MarkerId("drop"),
          position: drop,
          infoWindow: const InfoWindow(title: "Drop")),

      Marker(
        markerId: const MarkerId("rider"),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure),
      ),
    },

    polylines: {
      Polyline(
        polylineId: const PolylineId("route"),
        points: routePoints,
        color: Colors.blue,
        width: 5,
      )
    },

    onMapCreated: (controller) {
      mapController = controller;
      startMovement();
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildMap(),

          // 🔝 TOP CARD
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🚚 Delivery in Progress",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Pickup: Restaurant A"),
                  Text("Drop: Sector 15"),
                  SizedBox(height: 5),
                  Text("ETA: 15 min",
                      style: TextStyle(color: Colors.teal)),
                ],
              ),
            ),
          ),

          // 🔙 BACK BUTTON
          Positioned(
            top: 50,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          Positioned(
  bottom: 20,
  left: 20,
  right: 20,
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        )
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC2626),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
          SizedBox(width: 10),
          Text(
            "SOS Emergency",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
  ),
)
        ],
      ),
    );
  }
}