import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

// ─────────────────────────────────────────────
//  WorkerProfileScreen — GigMate (Pro Level)
//  ✅ Fixed: photo upload (web+mobile), card sizing
//  ✅ Fixed: dart:io removed (web compatible)
//  ✅ Fixed: cancel restores old values
//  ✅ Added: online/offline toggle, UPI, emergency
//  ✅ Added: saving loader, danger zone, dividers
// ─────────────────────────────────────────────

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({super.key});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {

  // ── Colors
  static const Color _primary      = Color(0xFF0F766E);
  static const Color _bg           = Color(0xFFF4F7FB);
  static const Color _card         = Colors.white;
  static const Color _textDark     = Color(0xFF0F172A);
  static const Color _textMid      = Color(0xFF475569);
  static const Color _textLight    = Color(0xFF94A3B8);
  static const Color _green        = Color(0xFF10B981);
  static const Color _amber        = Color(0xFFF59E0B);
  static const Color _red          = Color(0xFFEF4444);
  static const Color _blue         = Color(0xFF3B82F6);

  // ── Firebase
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── UI State
  bool _isEditing   = false;
  bool _isLoading   = true;
  bool _isSaving    = false;
  bool _isUploading = false;
  bool _isOnline    = true;

  // ── Photo (web-safe: Uint8List only)
  Uint8List? _imageBytes;
  String     _photoUrl = "";

  // ── Profile data
  String _name             = "";
  String _email            = "";
  String _phone            = "";
  String _vehicleNo        = "";
  String _vehicleType      = "Bike";
  String _address          = "";
  String _upiId            = "";
  String _emergencyContact = "";
  double _rating           = 4.8;
  int    _totalOrders      = 0;
  int    _totalDays        = 0;
  String _joinDate         = "2026";
  String _status           = "Active";
  String _selectedVehicle  = "Bike";

  // ── Controllers
  final _nameCtrl      = TextEditingController();
  final _phoneCtrl     = TextEditingController();
  final _vehicleNoCtrl = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _upiCtrl       = TextEditingController();
  final _emergencyCtrl = TextEditingController();

  // ── Vehicle options
  final List<Map<String, dynamic>> _vehicleOptions = [
    {"label": "Bike",    "icon": Icons.two_wheeler_rounded},
    {"label": "Scooter", "icon": Icons.electric_scooter_rounded},
    {"label": "Cycle",   "icon": Icons.pedal_bike_rounded},
    {"label": "Car",     "icon": Icons.directions_car_rounded},
    {"label": "Van",     "icon": Icons.airport_shuttle_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _vehicleNoCtrl.dispose();
    _addressCtrl.dispose();
    _upiCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────
  //  LOAD PROFILE FROM FIRESTORE
  // ─────────────────────────────────────────
  Future<void> _loadProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) { setState(() => _isLoading = false); return; }

      final doc  = await _firestore.collection("workers").doc(uid).get();
      final data = doc.exists ? doc.data()! : <String, dynamic>{};

      setState(() {
        _name             = data["name"]             ?? _auth.currentUser?.displayName ?? "Worker";
        _email            = data["email"]            ?? _auth.currentUser?.email ?? "";
        _phone            = data["phone"]            ?? "";
        _vehicleNo        = data["vehicleNo"]        ?? "";
        _vehicleType      = data["vehicleType"]      ?? "Bike";
        _address          = data["address"]          ?? "";
        _photoUrl         = data["photoUrl"]         ?? "";
        _upiId            = data["upiId"]            ?? "";
        _emergencyContact = data["emergencyContact"] ?? "";
        _rating           = (data["rating"]          ?? 4.8).toDouble();
        _totalOrders      = data["totalOrders"]      ?? 0;
        _totalDays        = data["totalDays"]        ?? 0;
        _joinDate         = data["joinDate"]         ?? "2026";
        _status           = data["status"]           ?? "Active";
        _isOnline         = data["isOnline"]         ?? true;
        _selectedVehicle  = _vehicleType;
        _isLoading        = false;
      });

      _nameCtrl.text      = _name;
      _phoneCtrl.text     = _phone;
      _vehicleNoCtrl.text = _vehicleNo;
      _addressCtrl.text   = _address;
      _upiCtrl.text       = _upiId;
      _emergencyCtrl.text = _emergencyContact;

    } catch (e) {
      debugPrint("Profile load error: $e");
      setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────
  //  SAVE PROFILE TO FIRESTORE
  // ─────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection("workers").doc(uid).set({
        "name"            : _nameCtrl.text.trim(),
        "phone"           : _phoneCtrl.text.trim(),
        "vehicleNo"       : _vehicleNoCtrl.text.trim(),
        "vehicleType"     : _selectedVehicle,
        "address"         : _addressCtrl.text.trim(),
        "upiId"           : _upiCtrl.text.trim(),
        "emergencyContact": _emergencyCtrl.text.trim(),
        "email"           : _email,
      }, SetOptions(merge: true));

      setState(() {
        _name             = _nameCtrl.text.trim();
        _phone            = _phoneCtrl.text.trim();
        _vehicleNo        = _vehicleNoCtrl.text.trim();
        _vehicleType      = _selectedVehicle;
        _address          = _addressCtrl.text.trim();
        _upiId            = _upiCtrl.text.trim();
        _emergencyContact = _emergencyCtrl.text.trim();
        _isEditing        = false;
        _isSaving         = false;
      });

      _showSnackbar("Profile updated successfully! ✅", _green);

    } catch (e) {
      debugPrint("Save error: $e");
      setState(() => _isSaving = false);
      _showSnackbar("Failed to save. Try again.", _red);
    }
  }

  // ─────────────────────────────────────────
  //  PHOTO UPLOAD — web + mobile compatible
  // ─────────────────────────────────────────
  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked == null) return;

      // ✅ readAsBytes works on web + mobile both
      final bytes = await picked.readAsBytes();

      // Show preview immediately (optimistic UI)
      setState(() {
        _imageBytes  = bytes;
        _isUploading = true;
      });

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setState(() => _isUploading = false);
        return;
      }

      // ✅ putData works on web (putFile only works on mobile)
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images/$uid.jpg");

      await ref.putData(
        bytes,
        SettableMetadata(contentType: "image/jpeg"),
      );

      final url = await ref.getDownloadURL();

      // Save URL to Firestore
      await _firestore.collection("workers").doc(uid).set(
        {"photoUrl": url},
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() {
          _photoUrl    = url;
          _imageBytes  = null; // use network URL from now
          _isUploading = false;
        });
        _showSnackbar("Profile photo updated! 📸", _green);
      }

    } catch (e) {
      debugPrint("Photo upload error: $e");
      if (mounted) {
        setState(() {
          _imageBytes  = null;
          _isUploading = false;
        });
        _showSnackbar("Photo upload failed. Try again.", _red);
      }
    }
  }

  // ─────────────────────────────────────────
  //  ONLINE / OFFLINE TOGGLE
  // ─────────────────────────────────────────
  Future<void> _toggleOnlineStatus(bool value) async {
    setState(() => _isOnline = value);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _firestore.collection("workers").doc(uid).set(
        {"isOnline": value},
        SetOptions(merge: true),
      );
      _showSnackbar(
        value ? "You are now Online 🟢" : "You are now Offline 🔴",
        value ? _green : _red,
      );
    } catch (e) {
      setState(() => _isOnline = !value); // revert on error
    }
  }

  // ─────────────────────────────────────────
  //  CANCEL EDIT — restore old values
  // ─────────────────────────────────────────
  void _cancelEdit() {
    _nameCtrl.text      = _name;
    _phoneCtrl.text     = _phone;
    _vehicleNoCtrl.text = _vehicleNo;
    _addressCtrl.text   = _address;
    _upiCtrl.text       = _upiId;
    _emergencyCtrl.text = _emergencyContact;
    setState(() {
      _selectedVehicle = _vehicleType;
      _isEditing       = false;
    });
  }

  // ─────────────────────────────────────────
  //  LOGOUT
  // ─────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await _showConfirmDialog(
      title: "Logout?",
      content: "Are you sure you want to logout?",
      confirmText: "Logout",
      confirmColor: _red,
    );
    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      }
    }
  }

  // ─────────────────────────────────────────
  //  DELETE ACCOUNT
  // ─────────────────────────────────────────
  Future<void> _deleteAccount() async {
    final confirm = await _showConfirmDialog(
      title: "Delete Account?",
      content:
          "This will permanently delete your account and all data. This cannot be undone.",
      confirmText: "Delete",
      confirmColor: _red,
    );
    if (confirm == true) {
      try {
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          await _firestore.collection("workers").doc(uid).delete();
        }
        await _auth.currentUser?.delete();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
        }
      } catch (e) {
        _showSnackbar("Re-login required before deleting account.", _red);
      }
    }
  }

  // ─────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────
  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        content:
            Text(content, style: const TextStyle(color: _textMid)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel",
                style: TextStyle(color: _textMid)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _primary))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildOnlineToggleCard(),
                        const SizedBox(height: 14),
                        _buildStatsRow(),
                        const SizedBox(height: 14),
                        _buildInfoCard(),
                        const SizedBox(height: 14),
                        _buildVehicleCard(),
                        const SizedBox(height: 14),
                        _buildPaymentCard(),
                        const SizedBox(height: 14),
                        _buildBadgesCard(),
                        const SizedBox(height: 14),
                        _buildSettingsCard(),
                        const SizedBox(height: 14),
                        _buildDangerZone(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────
  //  SLIVER APP BAR
  // ─────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 275,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text("My Profile",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18)),
      actions: [
        TextButton.icon(
          onPressed: _isEditing
              ? _cancelEdit
              : () => setState(() => _isEditing = true),
          icon: Icon(
            _isEditing ? Icons.close_rounded : Icons.edit_rounded,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            _isEditing ? "Cancel" : "Edit",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildProfileHeader(),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF14B8A6),
            Color(0xFF0EA5E9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 44),

            // ── Avatar
            GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _isUploading
                          ? Container(
                              color:
                                  Colors.white.withOpacity(0.2),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : _imageBytes != null
                              ? Image.memory(_imageBytes!,
                                  fit: BoxFit.cover)
                              : _photoUrl.isNotEmpty
                                  ? Image.network(
                                      _photoUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (_, child, progress) {
                                        if (progress == null)
                                          return child;
                                        return Container(
                                          color: Colors.white
                                              .withOpacity(0.2),
                                          child: const Center(
                                            child:
                                                CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (_, __, ___) =>
                                              _avatarFallback(),
                                    )
                                  : _avatarFallback(),
                    ),
                  ),
                  // Camera badge
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: _primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Text(
              _name.isEmpty ? "Worker" : _name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(_email,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 12),

            // Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _headerChip(
                    _isOnline
                        ? Icons.circle
                        : Icons.circle_outlined,
                    _isOnline ? "Online" : "Offline",
                    _isOnline
                        ? Colors.greenAccent
                        : Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  _headerChip(Icons.verified_rounded, _status,
                      Colors.white),
                  const SizedBox(width: 8),
                  _headerChip(Icons.calendar_today_outlined,
                      "Since $_joinDate", Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Text(
          _name.isNotEmpty ? _name[0].toUpperCase() : "W",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _headerChip(IconData icon, String text, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  ONLINE TOGGLE CARD
  // ─────────────────────────────────────────
  Widget _buildOnlineToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _isOnline
            ? _green.withOpacity(0.08)
            : _red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isOnline
              ? _green.withOpacity(0.3)
              : _red.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  (_isOnline ? _green : _red).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: _isOnline ? _green : _red,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? "You are Online" : "You are Offline",
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _isOnline ? _green : _red),
                ),
                const SizedBox(height: 2),
                Text(
                  _isOnline
                      ? "Receiving new order requests"
                      : "Not receiving any orders",
                  style: const TextStyle(
                      fontSize: 12, color: _textLight),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isOnline,
            onChanged: _toggleOnlineStatus,
            activeColor: _green,
            inactiveThumbColor: _red,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  STATS ROW
  // ─────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 14,
              offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _statItem("$_totalOrders", "Total Orders",
              Icons.inventory_2_outlined, _primary),
          _statDivider(),
          _statItem(_rating.toStringAsFixed(1), "Avg Rating",
              Icons.star_rounded, _amber),
          _statDivider(),
          _statItem("$_totalDays", "Active Days",
              Icons.calendar_month_outlined, _green),
        ],
      ),
    );
  }

  Widget _statItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: _textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 56, color: const Color(0xFFE2E8F0));

  // ─────────────────────────────────────────
  //  PERSONAL INFO CARD
  // ─────────────────────────────────────────
  Widget _buildInfoCard() {
    return _sectionCard(
      title: "Personal Info",
      icon: Icons.person_outline_rounded,
      iconColor: _primary,
      child: Column(
        children: [
          _isEditing
              ? _editField("Full Name", _nameCtrl,
                  Icons.person_outline, TextInputType.name)
              : _infoRow(Icons.person_outline, "Full Name",
                  _name.isEmpty ? "Not set" : _name),
          _gap(),
          _infoRow(Icons.email_outlined, "Email", _email),
          _gap(),
          _isEditing
              ? _editField("Phone Number", _phoneCtrl,
                  Icons.phone_outlined, TextInputType.phone)
              : _infoRow(Icons.phone_outlined, "Phone",
                  _phone.isEmpty ? "Not added" : _phone),
          _gap(),
          _isEditing
              ? _editField("Home Address", _addressCtrl,
                  Icons.home_outlined, TextInputType.streetAddress)
              : _infoRow(Icons.home_outlined, "Address",
                  _address.isEmpty ? "Not added" : _address),
          _gap(),
          _isEditing
              ? _editField("Emergency Contact", _emergencyCtrl,
                  Icons.emergency_outlined, TextInputType.phone)
              : _infoRow(Icons.emergency_outlined,
                  "Emergency Contact",
                  _emergencyContact.isEmpty
                      ? "Not added"
                      : _emergencyContact),
          if (_isEditing) ...[
            const SizedBox(height: 18),
            _saveButton(),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  VEHICLE CARD
  // ─────────────────────────────────────────
  Widget _buildVehicleCard() {
    return _sectionCard(
      title: "Vehicle Info",
      icon: Icons.two_wheeler_rounded,
      iconColor: _blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing) ...[
            const Text("Select Vehicle Type",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textMid)),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _vehicleOptions.map((v) {
                  final label    = v["label"] as String;
                  final icon     = v["icon"] as IconData;
                  final selected = _selectedVehicle == label;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedVehicle = label),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? _primary
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? _primary
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon,
                              color: selected
                                  ? Colors.white
                                  : _textMid,
                              size: 18),
                          const SizedBox(width: 6),
                          Text(label,
                              style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : _textMid,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
            _editField(
                "Vehicle Number (e.g. MH12AB1234)",
                _vehicleNoCtrl,
                Icons.pin_outlined,
                TextInputType.text),
            const SizedBox(height: 18),
            _saveButton(),
          ] else ...[
            _infoRow(Icons.two_wheeler_rounded, "Vehicle Type",
                _vehicleType),
            _gap(),
            _infoRow(Icons.pin_outlined, "Vehicle Number",
                _vehicleNo.isEmpty ? "Not added" : _vehicleNo),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  PAYMENT CARD
  // ─────────────────────────────────────────
  Widget _buildPaymentCard() {
    return _sectionCard(
      title: "Payment Info",
      icon: Icons.account_balance_wallet_outlined,
      iconColor: _green,
      child: _isEditing
          ? Column(
              children: [
                _editField(
                    "UPI ID (e.g. name@upi)",
                    _upiCtrl,
                    Icons.alternate_email_rounded,
                    TextInputType.emailAddress),
                const SizedBox(height: 18),
                _saveButton(),
              ],
            )
          : _infoRow(
              Icons.alternate_email_rounded,
              "UPI ID",
              _upiId.isEmpty ? "Not added" : _upiId,
            ),
    );
  }

  // ─────────────────────────────────────────
  //  BADGES CARD
  // ─────────────────────────────────────────
  Widget _buildBadgesCard() {
    final badges = [
      _Badge("⭐", "Top Rated",  "4.8+ rating",         true),
      _Badge("🚀", "Speed King", "Fastest deliveries",   true),
      _Badge("💯", "Century",    "100+ orders done",     _totalOrders >= 100),
      _Badge("🔥", "On Fire",    "7-day streak",         false),
      _Badge("🏆", "Elite",      "500+ orders needed",   _totalOrders >= 500),
      _Badge("💎", "Diamond",    "1000+ orders needed",  _totalOrders >= 1000),
    ];

    return _sectionCard(
      title: "Achievements",
      icon: Icons.emoji_events_outlined,
      iconColor: _amber,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3.3, // ✅ Professional sizing
        ),
        itemCount: badges.length,
        itemBuilder: (_, i) {
          final b = badges[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: b.unlocked
                  ? _primary.withOpacity(0.07)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: b.unlocked
                    ? _primary.withOpacity(0.25)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Text(
                  b.emoji,
                  style: TextStyle(
                    fontSize: 26,
                    color: b.unlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(b.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: b.unlocked
                                  ? _primary
                                  : _textLight)),
                      const SizedBox(height: 2),
                      Text(b.subtitle,
                          style: const TextStyle(
                              fontSize: 10, color: _textLight),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (!b.unlocked)
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: _textLight),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  //  SETTINGS CARD
  // ─────────────────────────────────────────
  Widget _buildSettingsCard() {
    return _sectionCard(
      title: "Settings",
      icon: Icons.settings_outlined,
      iconColor: _textMid,
      child: Column(
        children: [
          _settingsTile(Icons.notifications_outlined, "Notifications",
              "Order alerts & reminders", _primary,
              onTap: () => _showSnackbar(
                  "Notification settings coming soon", _primary)),
          _settingsDivider(),
          _settingsTile(Icons.lock_outline_rounded, "Change Password",
              "Update your login password", _blue,
              onTap: () =>
                  _showSnackbar("Password reset coming soon", _blue)),
          _settingsDivider(),
          _settingsTile(Icons.language_rounded, "Language",
              "English (Default)", _green,
              onTap: () => _showSnackbar(
                  "Language settings coming soon", _green)),
          _settingsDivider(),
          _settingsTile(Icons.help_outline_rounded, "Help & Support",
              "Contact GigMate support", _amber,
              onTap: () =>
                  _showSnackbar("Support coming soon", _amber)),
          _settingsDivider(),
          _settingsTile(Icons.logout_rounded, "Logout",
              "Sign out from this device", _red,
              onTap: _logout),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  DANGER ZONE
  // ─────────────────────────────────────────
  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: _red, size: 18),
              SizedBox(width: 8),
              Text("Danger Zone",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _red)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Deleting your account is permanent and cannot be undone.",
            style: TextStyle(fontSize: 12, color: _textLight),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteAccount,
              icon: const Icon(Icons.delete_forever_rounded,
                  color: _red, size: 18),
              label: const Text("Delete My Account",
                  style: TextStyle(
                      color: _red, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: _red, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  REUSABLE WIDGETS
  // ─────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 14,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      color: _textLight,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editField(
    String hint,
    TextEditingController ctrl,
    IconData icon,
    TextInputType type,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 13, color: _textLight),
        prefixIcon: Icon(icon, color: _primary, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _textDark)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: _textLight)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: _textLight, size: 20),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveProfile,
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(
          _isSaving ? "Saving..." : "Save Changes",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _gap() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
      );

  Widget _settingsDivider() =>
      const Divider(height: 24, color: Color(0xFFE2E8F0));
}

// ─────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────
class _Badge {
  final String emoji;
  final String title;
  final String subtitle;
  final bool unlocked;
  const _Badge(this.emoji, this.title, this.subtitle, this.unlocked);
}