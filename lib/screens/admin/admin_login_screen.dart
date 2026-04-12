import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: isMobile
                      ? _buildMobileLayout()
                      : _buildDesktopLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- DESKTOP ----------------
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _buildInfoPanel(),
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildLoginCard(),
        ),
      ],
    );
  }

  // ---------------- MOBILE ----------------
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInfoPanel(compact: true),
        const SizedBox(height: 20),
        _buildLoginCard(),
      ],
    );
  }

  // ---------------- LEFT PANEL ----------------
  Widget _buildInfoPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 38),
          ),
          const SizedBox(height: 24),

          const Text(
            "Admin Control",
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Monitor deliveries, manage workers, track analytics and control the entire delivery system in real-time.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip(icon: Icons.analytics, text: "Analytics"),
              _FeatureChip(icon: Icons.people, text: "Workers"),
              _FeatureChip(icon: Icons.inventory, text: "Orders"),
              _FeatureChip(icon: Icons.map, text: "Live Tracking"),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- LOGIN CARD ----------------
  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 26, offset: Offset(0, 14)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.lock_rounded,
                color: Color(0xFF0F766E), size: 34),
          ),

          const SizedBox(height: 18),

          const Text(
            "Admin Login",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Login to access dashboard",
            style: TextStyle(color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 26),

          _inputField("Admin Email", Icons.email_outlined),

          const SizedBox(height: 14),

          _inputField(
            "Password",
            Icons.lock_outline,
            obscure: obscurePassword,
            suffix: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => obscurePassword = !obscurePassword);
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminDashboard()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Login",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Admin Panel • Delivery Plus 🚀",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
      ),
    );
  }
}

// ---------------- FEATURE CHIP ----------------
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}