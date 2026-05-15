import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _formKey          = GlobalKey<FormState>();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocus         = FocusNode();
  final passwordFocus      = FocusNode();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isPasswordHidden = true;
  bool _isLoading       = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset>  _slideAnim;

  // ✅ UOG email format: 23021519-101@uog.edu.pk
  final emailRegex = RegExp(
    r'^\d{8}-\d{3}@uog\.edu\.pk$',
  );
  final passwordRegex =
  RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  bool get _isDark => themeProvider.isDark;

  Color get _bg1      => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bg2      => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bg3      => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);
  Color get _cardBg   => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBg  => _isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF);
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor  => _isDark ? Colors.white.withOpacity(0.42) : const Color(0xFF3D3A5C).withOpacity(0.6);
  Color get _hintColor => _isDark ? Colors.white.withOpacity(0.22) : Colors.black.withOpacity(0.28);
  Color get _divColor  => _isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.10);
  Color get _orColor   => _isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.35);
  Color get _iconColor => _isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.30);
  Color get _cardBorder => _isDark ? _accent.withOpacity(0.28) : _accent.withOpacity(0.20);
  Color get _enabledBorder => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);
  Color get _glowColor1 => _isDark ? const Color(0xFF5C4FCC) : const Color(0xFF7C6FE8);
  Color get _glowColor2 => _isDark ? const Color(0xFF3B2FA0) : const Color(0xFFAB9FF8);

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    emailFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email:    emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _isLoading = false);
      _snack("Login Failed. Check email & password.", isError: true);
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg1, _bg2, _bg3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [

          Positioned(top: -100, left: -80,
              child: _glow(320, _glowColor1)),
          Positioned(bottom: -60, right: -80,
              child: _glow(260, _glowColor2)),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: LayoutBuilder(builder: (ctx, cons) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: cons.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Column(children: [

                            const Spacer(),

                            Container(
                              width: 78, height: 78,
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(26),
                                border: Border.all(color: _accent.withOpacity(0.55), width: 1.5),
                                boxShadow: [BoxShadow(color: _accent.withOpacity(0.40), blurRadius: 28, spreadRadius: 2)],
                              ),
                              child: const Icon(Icons.school_rounded, size: 40, color: _accentLt),
                            ),

                            const SizedBox(height: 18),

                            Text("Welcome Back",
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: _textColor,
                                    letterSpacing: -0.8)),

                            const SizedBox(height: 6),

                            Text("University of Gujrat — Smart Campus",
                                style: TextStyle(fontSize: 13, color: _subColor, letterSpacing: 0.2)),

                            const SizedBox(height: 36),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: _cardBorder, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                      color: _accent.withOpacity(0.20),
                                      blurRadius: 40,
                                      spreadRadius: -4,
                                      offset: const Offset(0, 10)),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    _label("University Email"),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: emailController,
                                      focusNode: emailFocus,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocus),
                                      onChanged: (_) => setState(() {}),
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return "Email is required";
                                        if (!emailRegex.hasMatch(v.trim())) return "Format: 23021519-101@uog.edu.pk";
                                        return null;
                                      },
                                      decoration: _fieldDeco(
                                        hint: "23021519-101@uog.edu.pk",
                                        icon: Icons.alternate_email_rounded,
                                        isFocused: emailFocus.hasFocus,
                                        suffix: emailController.text.isNotEmpty
                                            ? IconButton(
                                          icon: Icon(Icons.cancel_rounded, size: 18, color: _iconColor),
                                          onPressed: () => setState(() => emailController.clear()),
                                        )
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    _label("Password"),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: passwordController,
                                      focusNode: passwordFocus,
                                      obscureText: isPasswordHidden,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                      onFieldSubmitted: (_) => _login(),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return "Password is required";
                                        if (!passwordRegex.hasMatch(v)) return "Min 8 chars, 1 uppercase, 1 number, 1 symbol";
                                        return null;
                                      },
                                      decoration: _fieldDeco(
                                        hint: "••••••••••",
                                        icon: Icons.lock_outline_rounded,
                                        isFocused: passwordFocus.hasFocus,
                                        suffix: IconButton(
                                          icon: Icon(
                                            isPasswordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            size: 20, color: _iconColor,
                                          ),
                                          onPressed: () => setState(() => isPasswordHidden = !isPasswordHidden),
                                        ),
                                      ),
                                    ),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 6)),
                                        child: const Text("Forgot password?",
                                            style: TextStyle(color: _accentLt, fontSize: 13, fontWeight: FontWeight.w600)),
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: _isLoading ? null : _login,
                                        child: _isLoading
                                            ? const SizedBox(width: 22, height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                            : const Text("Sign In",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    Row(children: [
                                      Expanded(child: Divider(color: _divColor, thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        child: Text("or", style: TextStyle(color: _orColor, fontSize: 12)),
                                      ),
                                      Expanded(child: Divider(color: _divColor, thickness: 1)),
                                    ]),

                                    const SizedBox(height: 18),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Don't have an account?  ",
                                            style: TextStyle(color: _orColor, fontSize: 13)),
                                        GestureDetector(
                                          onTap: () => Navigator.push(context,
                                              MaterialPageRoute(builder: (_) => const SignUpScreen())),
                                          child: const Text("Create account",
                                              style: TextStyle(color: _accentLt, fontWeight: FontWeight.w800, fontSize: 13)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),
                          ]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withOpacity(0.25), Colors.transparent]),
    ),
  );

  Widget _label(String text) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _subColor, letterSpacing: 0.4));

  InputDecoration _fieldDeco({
    required String hint,
    required IconData icon,
    required bool isFocused,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _hintColor, fontSize: 13),
      prefixIcon: Icon(icon, size: 19, color: isFocused ? _accentLt : _iconColor),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _enabledBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _enabledBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 2)),
      errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 11),
    );
  }
}