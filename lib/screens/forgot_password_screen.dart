import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  final _emailController = TextEditingController();
  final _emailFocus      = FocusNode();
  final _formKey         = GlobalKey<FormState>();
  bool  _isLoading       = false;
  bool  _emailSent       = false;

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  // ✅ UOG email format: 23021519-101@uog.edu.pk
  final emailRegex = RegExp(r'^\d{8}-\d{3}@uog\.edu\.pk$');

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  bool get _isDark => themeProvider.isDark;

  Color get _bg1        => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bg2        => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bg3        => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);
  Color get _cardBg     => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBg    => _isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF);
  Color get _textColor  => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor   => _isDark ? Colors.white.withOpacity(0.45) : const Color(0xFF3D3A5C).withOpacity(0.6);
  Color get _hintColor  => _isDark ? Colors.white.withOpacity(0.22) : Colors.black.withOpacity(0.28);
  Color get _iconColor  => _isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.30);
  Color get _borderCol  => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);
  Color get _cardBorder => _isDark ? _accent.withOpacity(0.28) : _accent.withOpacity(0.18);
  Color get _backBg     => _isDark ? const Color(0xFF13112A) : const Color(0xFFF0EFFF);
  Color get _glowColor1 => _isDark ? const Color(0xFF5C4FCC) : const Color(0xFF7C6FE8);
  Color get _glowColor2 => _isDark ? const Color(0xFF3B2FA0) : const Color(0xFFAB9FF8);

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
    _emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _animController.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onThemeChange() { if (mounted) setState(() {}); }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) setState(() { _isLoading = false; _emailSent = true; });
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = "Something went wrong. Try again.";
      if (e.code == 'user-not-found')    msg = "No account found with this email.";
      if (e.code == 'invalid-email')     msg = "Enter a valid UOG email.";
      if (e.code == 'too-many-requests') msg = "Too many attempts. Try after some time.";
      _snack(msg, isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFF8B1A1A) : const Color(0xFF1D7A55),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _backBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.35), width: 1.5),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: _accentLt, size: 16),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_bg1, _bg2, _bg3], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Stack(children: [
          Positioned(top: -100, left: -80, child: _glow(320, _glowColor1)),
          Positioned(bottom: -60, right: -80, child: _glow(260, _glowColor2)),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 76, height: 76,
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: _accent.withOpacity(0.55), width: 1.5),
                                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 24, spreadRadius: 2)],
                                  ),
                                  child: Icon(_emailSent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                                      size: 38, color: _accentLt),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  _emailSent ? "Check Your Inbox!" : "Forgot Password?",
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _textColor, letterSpacing: -0.8),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  _emailSent
                                      ? "Reset link sent to your UOG email.\nClick the link to set new password."
                                      : "Enter your UOG registered email.\nWe'll send a password reset link.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: _subColor),
                                ),

                                const SizedBox(height: 36),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: _cardBg,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: _cardBorder, width: 1.5),
                                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 30, spreadRadius: -4, offset: const Offset(0, 10))],
                                  ),
                                  child: _emailSent ? _successView() : _formView(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _successView() {
    return Column(children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF1D7A55).withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2ECC71), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF2ECC71).withOpacity(0.25), blurRadius: 16, spreadRadius: -4)],
        ),
        child: const Icon(Icons.check_rounded, color: Color(0xFF2ECC71), size: 32),
      ),
      const SizedBox(height: 16),
      Text("Email Sent Successfully!",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textColor)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _accent.withOpacity(0.25), width: 1),
        ),
        child: Text(_emailController.text.trim(),
            style: const TextStyle(fontSize: 13, color: _accentLt, fontWeight: FontWeight.w600)),
      ),
      const SizedBox(height: 12),
      Text("Check your inbox and spam folder.\nClick the reset link to change password.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: _subColor, height: 1.6)),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => setState(() => _emailSent = false),
        child: Text("Resend Email",
            style: TextStyle(fontSize: 13, color: _accentLt.withOpacity(0.7),
                fontWeight: FontWeight.w600, decoration: TextDecoration.underline,
                decorationColor: _accentLt.withOpacity(0.5))),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C6FE8), foregroundColor: Colors.white,
            elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Back to Login", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    ]);
  }

  Widget _formView() {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("University Email",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _subColor, letterSpacing: 0.4)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            // ✅ Strict UOG format validation
            if (!emailRegex.hasMatch(v.trim())) return 'Format: 23021519-101@uog.edu.pk';
            return null;
          },
          decoration: InputDecoration(
            // ✅ Updated hint
            hintText: "23021519-101@uog.edu.pk",
            hintStyle: TextStyle(color: _hintColor, fontSize: 13),
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 19,
                color: _emailFocus.hasFocus ? _accentLt : _iconColor),
            filled: true,
            fillColor: _fieldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _borderCol)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _borderCol)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7C6FE8), width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 2)),
            errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 11),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.info_outline_rounded, size: 13, color: _accentLt.withOpacity(0.5)),
          const SizedBox(width: 6),
          Expanded(child: Text("Use your UOG registered email (RegNo-Section@uog.edu.pk)",
              style: TextStyle(fontSize: 11, color: _subColor))),
        ]),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity, height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C6FE8), foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isLoading ? null : _sendResetEmail,
            child: _isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Text("Send Reset Link", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text("← Back to Login",
                style: TextStyle(color: _accentLt.withOpacity(0.65), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withOpacity(0.25), Colors.transparent]),
    ),
  );
}
