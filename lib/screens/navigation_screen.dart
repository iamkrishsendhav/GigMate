import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? mapController;

  // 📍 Locations
  LatLng pickup = const LatLng(28.6139, 77.2090);
  LatLng drop = const LatLng(28.6300, 77.2200);

  List<LatLng> routePoints = [];
  LatLng currentPosition = const LatLng(28.6139, 77.2090);

  Timer? movementTimer;
  int routeIndex = 0;

  @override
  void initState() {
    super.initState();
    generateRoute();
    startMovement();
  }

  // 🛣️ Route generation (simulation)
  void generateRoute() {
    for (int i = 0; i <= 25; i++) {
      double lat = pickup.latitude +
          (drop.latitude - pickup.latitude) * i / 25;
      double lng = pickup.longitude +
          (drop.longitude - pickup.longitude) * i / 25;

      routePoints.add(LatLng(lat, lng));
    }
  }

  // 🚚 Moving rider animation
  void startMovement() {
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

  // 🌐 + 📱 Cross Platform Map
  Widget buildMap() {
    if (kIsWeb) {
      // 🌐 WEB UI (Fallback but professional)
      return Container(
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text("Live Tracking Available on Mobile",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text("Switch to mobile device 🚚"),
          ],
        ),
      );
    } else {
      // 📱 MOBILE REAL MAP
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
                BitmapDescriptor.hueBlue),
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
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ MAP / WEB UI
          buildMap(),

          // 🔝 TOP DELIVERY CARD
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

          // 🔴 SOS BUTTON
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text("🚨 SOS Emergency"),
            ),
          ),
        ],
      ),
    );
  }
}