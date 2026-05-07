import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/order_model.dart';

class NavigationScreen extends StatefulWidget {
  final OrderModel? order;

  const NavigationScreen({super.key, this.order});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  static const _primary = Color(0xFF0F766E);
  static const _textDark = Color(0xFF0F172A);
  static const _textMid = Color(0xFF64748B);
  static const _red = Color(0xFFDC2626);

  GoogleMapController? _mapController;
  Timer? _movementTimer;
  int _routeIndex = 0;
  bool _isFollowing = true;
  MapType _mapType = MapType.normal;

  final LatLng _pickup = const LatLng(28.6139, 77.2090);
  final LatLng _drop = const LatLng(28.6300, 77.2200);
  final List<LatLng> _routePoints = [];
  LatLng _currentPosition = const LatLng(28.6139, 77.2090);

  OrderModel? get _order => widget.order;

  String get _pickupLabel {
    final pickup = _order?.pickup.trim();
    return pickup == null || pickup.isEmpty ? 'Pickup point' : pickup;
  }

  String get _dropLabel {
    final drop = _order?.drop.trim();
    return drop == null || drop.isEmpty ? 'Drop point' : drop;
  }

  String get _etaText {
    final eta = _order?.eta ?? 15;
    return eta > 0 ? '${eta.toStringAsFixed(0)} min' : '15 min';
  }

  String get _distanceText {
    final distance = _order?.distance ?? 4.8;
    return distance > 0 ? '${distance.toStringAsFixed(1)} km' : '4.8 km';
  }

  @override
  void initState() {
    super.initState();
    _generateRoute();
    _loadCurrentLocation();
  }

  void _generateRoute() {
    _routePoints.clear();
    const steps = 36;
    for (var i = 0; i <= steps; i++) {
      final progress = i / steps;
      final curveOffset = (progress - 0.5) * (progress - 0.5) * 0.006;
      final lat =
          _pickup.latitude + (_drop.latitude - _pickup.latitude) * progress;
      final lng = _pickup.longitude +
          (_drop.longitude - _pickup.longitude) * progress +
          curveOffset;
      _routePoints.add(LatLng(lat, lng));
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 15.5, tilt: 30),
        ),
      );
    } catch (_) {
      // Fallback route remains available when location is blocked.
    }
  }

  void _startMovement() {
    _movementTimer?.cancel();
    _movementTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_routeIndex >= _routePoints.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentPosition = _routePoints[_routeIndex];
        _routeIndex++;
      });
      if (_isFollowing) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 15.2, tilt: 30),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _movementTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6220, 77.2145),
              zoom: 14.2,
            ),
            mapType: _mapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (controller) {
              _mapController = controller;
              _fitRoute();
              _startMovement();
            },
            onCameraMoveStarted: () {
              if (_isFollowing) setState(() => _isFollowing = false);
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: _topBar(),
          ),
          Positioned(
            right: 16,
            bottom: 238,
            child: _mapControls(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _deliveryPanel(),
          ),
        ],
      ),
    );
  }

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('pickup'),
          position: _pickup,
          infoWindow: InfoWindow(title: 'Pickup', snippet: _pickupLabel),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
        Marker(
          markerId: const MarkerId('drop'),
          position: _drop,
          infoWindow: InfoWindow(title: 'Drop', snippet: _dropLabel),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
        Marker(
          markerId: const MarkerId('rider'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'You'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };

  Set<Polyline> get _polylines => {
        Polyline(
          polylineId: const PolylineId('route-shadow'),
          points: _routePoints,
          color: Colors.black.withOpacity(0.22),
          width: 9,
        ),
        Polyline(
          polylineId: const PolylineId('active-route'),
          points: _routePoints,
          color: const Color(0xFF2563EB),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      };

  Widget _topBar() {
    return Row(
      children: [
        _roundButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: _glassDecoration(),
            child: Row(
              children: [
                const Icon(Icons.navigation_rounded, color: _primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _order == null ? 'Live route' : 'Order #${_order!.id} route',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _statusPill(_order?.statusText ?? 'Live'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapControls() {
    return Column(
      children: [
        _roundButton(
          icon: Icons.my_location_rounded,
          onTap: () {
            setState(() => _isFollowing = true);
            _loadCurrentLocation();
          },
        ),
        const SizedBox(height: 10),
        _roundButton(
          icon: Icons.layers_rounded,
          onTap: () {
            setState(() {
              _mapType =
                  _mapType == MapType.normal ? MapType.satellite : MapType.normal;
            });
          },
        ),
      ],
    );
  }

  Widget _deliveryPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delivery_dining_rounded,
                    color: _primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Delivery in progress',
                        style: TextStyle(
                            color: _textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text('ETA $_etaText - $_distanceText remaining',
                        style: const TextStyle(color: _textMid)),
                  ],
                ),
              ),
              _speedPill(),
            ],
          ),
          const SizedBox(height: 16),
          _routeBox(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fitRoute,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Recenter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendSos,
                  icon: const Icon(Icons.warning_amber_rounded,
                      color: Colors.white),
                  label: const Text('SOS',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _routeBox() {
    return Container(
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
              const Icon(Icons.circle, color: _primary, size: 12),
              Container(width: 2, height: 48, color: const Color(0xFFE2E8F0)),
              const Icon(Icons.location_on_rounded, color: _red, size: 20),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _routeText('Pickup', _pickupLabel),
                const SizedBox(height: 14),
                _routeText('Drop', _dropLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _textMid, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _textDark, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: _textDark),
        ),
      ),
    );
  }

  Widget _statusPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(color: _primary, fontWeight: FontWeight.w900)),
    );
  }

  Widget _speedPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.speed_rounded, color: _primary, size: 17),
          SizedBox(width: 6),
          Text('42 km/h',
              style: TextStyle(color: _textDark, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.94),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.6)),
      boxShadow: const [
        BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
      ],
    );
  }

  void _fitRoute() {
    if (_mapController == null || _routePoints.isEmpty) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
        _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
        _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
      ),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _sendSos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS sent to admin control room')),
    );
  }
}
