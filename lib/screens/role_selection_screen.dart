import 'package:flutter/material.dart';
import 'worker_login_screen.dart';
import './admin/admin_login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool isWorkerHover = false;
  bool isAdminHover = false;

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
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: _buildHeroPanel(),
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildRoleCard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildHeroPanel(compact: true),
        const SizedBox(height: 20),
        _buildRoleCard(),
      ],
    );
  }

  Widget _buildHeroPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: Colors.white.withOpacity(0.10),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Delivery Plus",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Smart Delivery Workforce System",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip(icon: Icons.security_rounded, text: "Safety First"),
              _FeatureChip(icon: Icons.speed_rounded, text: "Fast Delivery"),
              _FeatureChip(icon: Icons.favorite_rounded, text: "Health Monitoring"),
              _FeatureChip(icon: Icons.insights_rounded, text: "Smart Analytics"),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            "Empowering delivery workers with smarter tools, better visibility, and a smoother work experience.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 26,
            offset: Offset(0, 14),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.dashboard_customize_rounded,
              color: Color(0xFF0F766E),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Choose Your Role",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Continue as worker or admin",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 28),

          _AnimatedRoleButton(
            title: "Delivery Worker",
            subtitle: "Track orders, health and breaks",
            icon: Icons.delivery_dining_rounded,
            isHovered: isWorkerHover,
            filled: false,
            onHover: (v) => setState(() => isWorkerHover = v),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerLoginScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          _AnimatedRoleButton(
            title: "Admin",
            subtitle: "Manage workers, orders and analytics",
            icon: Icons.person_rounded,
            isHovered: isAdminHover,
            filled: false,
            onHover: (v) => setState(() => isAdminHover = v),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFF0F766E)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Powered by Delivery Plus 🚚",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedRoleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isHovered;
  final bool filled;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _AnimatedRoleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isHovered,
    required this.filled,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF0F766E);
    final bgColor = filled
        ? (isHovered ? const Color(0xFF115E59) : baseColor)
        : (isHovered ? const Color(0xFFE6FFFB) : Colors.white);

    final textColor = filled
        ? Colors.white
        : const Color(0xFF0F172A);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: filled ? Colors.transparent : const Color(0xFF0F766E),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? const Color(0xFF0F766E).withOpacity(0.18)
                    : Colors.black.withOpacity(0.06),
                blurRadius: isHovered ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white.withOpacity(0.16)
                      : const Color(0xFF0F766E).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: filled ? Colors.white : const Color(0xFF0F766E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: filled ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: filled ? Colors.white70 : const Color(0xFF0F766E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}