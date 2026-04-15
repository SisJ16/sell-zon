import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_routes.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const Color primaryBlue = Color(0xFF4B63F3);
  static const Color secondaryBlue = Color(0xFF39B8F7);
  static const Color pageBg = Color(0xFFF5F7FC);
  static const Color textDark = Color(0xFF202431);
  static const Color textMuted = Color(0xFF98A2B3);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginTap() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter email and password");
      return;
    }
    await _authController.login(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: LoginPage.pageBg,
      body: Stack(
        children: [
          Container(color: LoginPage.pageBg),
          Container(
            height: size.height * 0.43,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [LoginPage.primaryBlue, LoginPage.secondaryBlue],
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.29,
            left: 0,
            right: 0,
            child: const _TopWaveStack(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomWaveStack(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 64),
                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 150),
                  _AuthField(
                    hintText: 'Email',
                    icon: Icons.mail_outline_rounded,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 18),
                  _AuthField(
                    hintText: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: true,
                    controller: _passwordController,
                    trailing: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: LoginPage.primaryBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Obx(
                    () => _GradientButton(
                      text: _authController.isLoading.value ? 'Loading...' : 'Login',
                      onTap: _authController.isLoading.value ? () {} : _onLoginTap,
                    ),
                  ),
                  const SizedBox(height: 42),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.2,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Or continue with',
                          style: TextStyle(
                            color: LoginPage.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.2,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        onTap: () {},
                        child: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Color(0xFFEA4335),
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 28),
                      _SocialButton(
                        onTap: () {},
                        child: const FaIcon(
                          FontAwesomeIcons.facebookF,
                          color: Color(0xFF1877F2),
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 56),
                  const Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      color: Color(0xFF8C93A3),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: LoginPage.primaryBlue,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 42),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;
  final TextEditingController? controller;

  const _AuthField({
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: LoginPage.primaryBlue.withOpacity(0.88),
            size: 33,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              cursorColor: LoginPage.primaryBlue,
              style: const TextStyle(
                fontSize: 16,
                color: LoginPage.textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: LoginPage.textMuted.withOpacity(0.72),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _GradientButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          height: 82,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [LoginPage.primaryBlue, LoginPage.secondaryBlue],
            ),
            boxShadow: [
              BoxShadow(
                color: LoginPage.secondaryBlue.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialButton({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.96),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _TopWaveStack extends StatelessWidget {
  const _TopWaveStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          ClipPath(
            clipper: _TopWaveBackClipper(),
            child: Container(
              height: 170,
              color: Colors.white.withOpacity(0.14),
            ),
          ),
          ClipPath(
            clipper: _TopWaveMidClipper(),
            child: Container(
              height: 158,
              color: Colors.white.withOpacity(0.22),
            ),
          ),
          ClipPath(
            clipper: _TopWaveFrontClipper(),
            child: Container(
              height: 146,
              color: LoginPage.pageBg,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomWaveStack extends StatelessWidget {
  const _BottomWaveStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          ClipPath(
            clipper: _BottomWaveBackClipper(),
            child: Container(
              height: 170,
              color: const Color(0xFFA9DBFF).withOpacity(0.75),
            ),
          ),
          ClipPath(
            clipper: _BottomWaveFrontClipper(),
            child: Container(
              height: 150,
              color: const Color(0xFFD9F0FF).withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopWaveBackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 76);
    path.quadraticBezierTo(size.width * 0.24, 10, size.width * 0.52, 68);
    path.quadraticBezierTo(size.width * 0.80, 126, size.width, 34);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopWaveMidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 96);
    path.quadraticBezierTo(size.width * 0.24, 42, size.width * 0.52, 88);
    path.quadraticBezierTo(size.width * 0.80, 134, size.width, 72);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopWaveFrontClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 112);
    path.quadraticBezierTo(size.width * 0.24, 74, size.width * 0.52, 108);
    path.quadraticBezierTo(size.width * 0.80, 142, size.width, 104);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomWaveBackClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 120);
    path.quadraticBezierTo(size.width * 0.24, 20, size.width * 0.52, 70);
    path.quadraticBezierTo(size.width * 0.80, 116, size.width, 18);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BottomWaveFrontClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 138);
    path.quadraticBezierTo(size.width * 0.24, 92, size.width * 0.52, 128);
    path.quadraticBezierTo(size.width * 0.80, 164, size.width, 82);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
