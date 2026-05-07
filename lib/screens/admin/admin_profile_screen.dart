import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  static const _primary = Color(0xFF0F766E);
  static const _bg = Color(0xFFF0F4F8);
  static const _textDark = Color(0xFF0F172A);
  static const _textMid = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'admin@gigmate.com';
    final uid = user?.uid ?? 'gigmate-admin';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        title: const Text('Admin Profile',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => _editProfile(context, uid, email),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('admins')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};
          final name =
              (data['name'] ?? user?.displayName ?? 'GigMate Admin').toString();
          final phone = (data['phone'] ?? '+91 90000 00000').toString();
          final role =
              (data['roleTitle'] ?? 'Operations Administrator').toString();
          final employeeId = (data['employeeId'] ?? 'GM-ADMIN-001').toString();
          final photoUrl =
              (data['photoUrl'] ?? user?.photoURL ?? '').toString();
          final joined = _dateText(data['joinedAt']);

          return LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final content = [
              _profileHero(
                name: name,
                email: email,
                phone: phone,
                role: role,
                photoUrl: photoUrl,
                employeeId: employeeId,
                joined: joined,
              ),
              _identityCard(
                name: name,
                email: email,
                phone: phone,
                employeeId: employeeId,
                role: role,
              ),
              _sectionCard(
                title: 'Admin History',
                icon: Icons.history_rounded,
                children: const [
                  _TimelineItem(
                    title: 'Control room ownership',
                    subtitle:
                        'Handles orders, worker escalation, live tracking and reports.',
                  ),
                  _TimelineItem(
                    title: 'Verification authority',
                    subtitle:
                        'Reviews worker identity, vehicle records and emergency cases.',
                  ),
                  _TimelineItem(
                    title: 'Broadcast manager',
                    subtitle:
                        'Sends operational messages to the full worker network.',
                  ),
                ],
              ),
              _sectionCard(
                title: 'Security & Access',
                icon: Icons.verified_user_rounded,
                children: [
                  _InfoRow('Access level', 'Owner'),
                  _InfoRow('Two factor status',
                      data['twoFactorEnabled'] == true ? 'Enabled' : 'Ready'),
                  _InfoRow('Last profile update', _dateText(data['updatedAt'])),
                  _InfoRow('Admin UID', uid),
                ],
              ),
            ];

            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 24 : 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: content[0]),
                            const SizedBox(width: 18),
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  content[1],
                                  const SizedBox(height: 16),
                                  content[2],
                                  const SizedBox(height: 16),
                                  content[3],
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            for (final item in content) ...[
                              item,
                              const SizedBox(height: 14),
                            ],
                          ],
                        ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  static Widget _profileHero({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String photoUrl,
    required String employeeId,
    required String joined,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: _primary.withValues(alpha: 0.1),
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? const Icon(Icons.admin_panel_settings_rounded,
                        color: _primary, size: 38)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _textDark)),
                    const SizedBox(height: 4),
                    Text(role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _textMid, fontSize: 13)),
                    const SizedBox(height: 8),
                    _statusPill('Verified Admin'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _InfoRow('Email', email),
          _InfoRow('Phone', phone),
          _InfoRow('Employee ID', employeeId),
          _InfoRow('Joined', joined),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              _profileMetric(Icons.verified_rounded, 'Access', 'Owner'),
              const SizedBox(width: 10),
              _profileMetric(Icons.security_rounded, 'Status', 'Secure'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _profileMetric(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _textLight, fontSize: 11)),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _identityCard({
    required String name,
    required String email,
    required String phone,
    required String employeeId,
    required String role,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF093D38), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F766E),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('GigMate Admin ID',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 18),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(role, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              _idChip(employeeId),
              _idChip(email),
              _idChip(phone),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x07000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _textDark)),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  static Widget _statusPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.w800)),
    );
  }

  static Widget _idChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  static String _dateText(dynamic value) {
    DateTime? date;
    if (value is Timestamp) date = value.toDate();
    if (value is DateTime) date = value;
    if (date == null) return 'May 2026';
    return '${date.day}/${date.month}/${date.year}';
  }

  static void _editProfile(BuildContext context, String uid, String email) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(999)),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: _primary, size: 26),
                    ),
                    const SizedBox(height: 12),
                    const Text('Update Admin Profile',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    _field('Full name', nameCtrl, Icons.person_outline_rounded),
                    const SizedBox(height: 10),
                    _field('Phone', phoneCtrl, Icons.phone_outlined),
                    const SizedBox(height: 10),
                    _field('Employee ID', idCtrl, Icons.badge_outlined),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('admins')
                              .doc(uid)
                              .set({
                            if (nameCtrl.text.trim().isNotEmpty)
                              'name': nameCtrl.text.trim(),
                            if (phoneCtrl.text.trim().isNotEmpty)
                              'phone': phoneCtrl.text.trim(),
                            if (idCtrl.text.trim().isNotEmpty)
                              'employeeId': idCtrl.text.trim(),
                            'email': email,
                            'roleTitle': 'Operations Administrator',
                            'updatedAt': FieldValue.serverTimestamp(),
                            'joinedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon:
                            const Icon(Icons.save_rounded, color: Colors.white),
                        label: const Text('Save Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _field(
      String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _primary),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(label,
                style: const TextStyle(
                    color: AdminProfileScreen._textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AdminProfileScreen._textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TimelineItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: AdminProfileScreen._primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AdminProfileScreen._textDark,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        color: AdminProfileScreen._textMid, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
