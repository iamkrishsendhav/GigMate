import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'worker_dashboard.dart';
import 'worker_login_screen.dart';

class WorkerSignupScreen extends StatefulWidget {
  const WorkerSignupScreen({super.key});

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  bool obscurePassword = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signupWorker() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      // 1. Firebase Auth mein user create karein
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Us user ki UID nikaalein
      String uid = userCredential.user!.uid;

      // 3. Firestore mein 'users' collection mein data save karein
      // await FirebaseFirestore.instance.collection('users').doc(uid).set({
      //   'uid': uid,
      //   'name': name,
      //   'email': email,
      //   'role': 'worker', // Automatic 'worker' role assignment
      //   'createdAt': FieldValue
      //       .serverTimestamp(), // Behtar practice ke liye server time use karein
      // });
      final now = DateTime.now();
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      final joinDate = "${months[now.month]} ${now.year}";

      await FirebaseFirestore.instance.collection('workers').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'worker',
        'isOnline': false,
        'currentOrderId': null,
        'lat': null,
        'lng': null,
        'hasSOS': false,
        'phone': '',
        'vehicleNo': '',
        'vehicleType': 'Bike',
        'address': '',
        'photoUrl': '',
        'rating': 4.8,
        'totalOrders': 0,
        'totalDays': 0,
        'joinDate': joinDate,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'worker',
        'isOnline': false,
        'currentOrderId': null,
        'lat': null,
        'lng': null,
        'rating': 4.8,
        'totalOrders': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Success! Dashboard par redirect karein
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WorkerDashboard()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      }
      if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Something went wrong. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                  child:
                      isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
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
            child: _buildInfoPanel(),
          ),
        ),
        Expanded(
          flex: 4,
          child: _buildSignupCard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInfoPanel(compact: true),
        const SizedBox(height: 20),
        _buildSignupCard(),
      ],
    );
  }

  Widget _buildInfoPanel({bool compact = false}) {
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
          ),
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
            child: const Icon(Icons.person_add_rounded,
                color: Colors.white, size: 38),
          ),
          const SizedBox(height: 24),
          const Text(
            "Join GigMate",
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Start your journey as a professional delivery partner. Manage orders, track health, and earn more with smart features.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FeatureChip(
                  icon: Icons.assignment_turned_in_rounded,
                  text: "Instant Onboarding"),
              _FeatureChip(
                  icon: Icons.account_balance_wallet_rounded,
                  text: "Fast Payouts"),
              _FeatureChip(
                  icon: Icons.support_agent_rounded, text: "24/7 Support"),
              _FeatureChip(
                  icon: Icons.trending_up_rounded, text: "Performance Perks"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard() {
    return Container(
      // Padding ko 28 se kam karke 24 kiya hai space bachane ke liye
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, // Size 66 se kam ki
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.badge_rounded,
                color: Color(0xFF0F766E), size: 28),
          ),
          const SizedBox(height: 12), // Spacing kam ki
          const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 22, // Size 26 se kam ki
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Register as a Delivery Partner",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20), // Spacing kam ki
          _buildTextField(
            hint: "Full Name",
            icon: Icons.person_outline_rounded,
            controller: nameController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            hint: "Password",
            icon: Icons.lock_outline,
            controller: passwordController,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF64748B),
                size: 20, // Icon size kam ki
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50, // Height 54 se kam karke 50 ki
            child: ElevatedButton(
              onPressed: isLoading ? null : signupWorker,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Already have an account? ",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WorkerLoginScreen()),
                  );
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Join the Workforce • GigMate 🚀",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14), // Text size thodi choti ki
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14),
        prefixIcon: Icon(icon, size: 20), // Icon size kam ki
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14), // Padding adjust ki height kam karne ke liye
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Radius thoda kam kiya
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
        ),
      ),
    );
  }
}

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
