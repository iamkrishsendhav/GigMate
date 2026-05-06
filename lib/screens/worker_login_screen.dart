import 'package:flutter/material.dart';
import 'worker_dashboard.dart';
import 'worker_signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  bool obscurePassword = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginWorker() async {
    // ✅ Trim + lowercase normalize karo
    final email    = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar("Please enter email & password");
      return;
    }

    try {
      setState(() => isLoading = true);

      // 1. Firebase Auth SignIn
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        _showSnackbar("Login failed. Please try again.");
        return;
      }

      // 2. ✅ FIXED — check 'workers' collection (not 'users')
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .get();

      if (workerDoc.exists) {
        final data = workerDoc.data();

        // ✅ Role check — if role field exists, verify it
        // If role field doesn't exist, allow login (backward compat)
        final role = data?['role'];
        if (role != null && role != 'worker') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            _showSnackbar("Access Denied: Only workers can login here.");
          }
          return;
        }

        // ✅ Success — go to dashboard
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const WorkerDashboard()),
            (route) => false,
          );
        }

      } else {
        // Worker document nahi mila — check karo 'users' collection as fallback
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['role'] == 'worker') {
          // ✅ Found in users collection with worker role
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const WorkerDashboard()),
              (route) => false,
            );
          }
        } else {
          // Not a worker
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            _showSnackbar("Access Denied: Only workers can login here.");
          }
        }
      }

    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = "No account found with this email.";
          break;
        case 'wrong-password':
          msg = "Wrong password. Please try again.";
          break;
        case 'invalid-email':
          msg = "Please enter a valid email address.";
          break;
        case 'invalid-credential':
          // ✅ Newer Firebase SDK uses this instead of wrong-password
          msg = "Invalid email or password. Please try again.";
          break;
        case 'user-disabled':
          msg = "This account has been disabled. Contact support.";
          break;
        case 'too-many-requests':
          msg = "Too many attempts. Please try again later.";
          break;
        case 'network-request-failed':
          msg = "Network error. Check your internet connection.";
          break;
        default:
          msg = "Login failed. Please try again.";
      }
      _showSnackbar(msg);
    } catch (e) {
      debugPrint("Login error: $e");
      _showSnackbar("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width    = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildInfoPanel(compact: true),
        const SizedBox(height: 20),
        _buildLoginCard(),
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
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Worker Access",
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Secure login for delivery workforce with smart tracking, health insights and delivery control.",
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
                  icon: Icons.route_rounded, text: "Live Navigation"),
              _FeatureChip(
                  icon: Icons.favorite_rounded,
                  text: "Health Monitoring"),
              _FeatureChip(
                  icon: Icons.timer_rounded, text: "Break Reminder"),
              _FeatureChip(
                  icon: Icons.inventory_2_rounded,
                  text: "Delivery List"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.lock_rounded,
                color: Color(0xFF0F766E), size: 28),
          ),
          const SizedBox(height: 12),
          const Text(
            "Worker Login",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Login to continue",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            hint: "Email",
            icon: Icons.email_outlined,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
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
                size: 20,
              ),
            ),
          ),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : loginWorker,
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
                      "Login",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style:
                    TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const WorkerSignupScreen()),
                ),
                child: const Text(
                  "Sign Up",
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
            "Worker Panel • GigMate 🚀",
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  FORGOT PASSWORD
  // ─────────────────────────────────────────
  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim().toLowerCase();
    if (email.isEmpty) {
      _showSnackbar(
          "Please enter your email address first.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showSnackbar(
            "Password reset link sent to your email. Check your inbox.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar("No account found with this email.");
      } else {
        _showSnackbar(
            "Could not send reset link. Check your email & connection.");
      }
    } catch (e) {
      _showSnackbar("Something went wrong. Try again.");
    }
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      // ✅ Submit on keyboard "done" / "next"
      textInputAction: hint == "Email"
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: hint == "Password"
          ? (_) => isLoading ? null : loginWorker()
          : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: Color(0xFF0F766E), width: 1.4),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  FEATURE CHIP WIDGET
// ─────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Colors.white.withOpacity(0.15)),
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