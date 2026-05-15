import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController  = TextEditingController();

  final emailFocus    = FocusNode();
  final passwordFocus = FocusNode();
  final confirmFocus  = FocusNode();

  final _auth = FirebaseAuth.instance;

  bool isPasswordHidden = true;
  bool isConfirmHidden  = true;
  bool _isLoading       = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset>  _slideAnim;

  // ✅ UOG email format: 23021519-101@uog.edu.pk
  final emailRegex = RegExp(r'^\d{8}-\d{3}@uog\.edu\.pk$');
  final passwordRegex =
  RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  bool get _isDark => themeProvider.isDark;

  Color get _bg1        => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bg2        => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bg3        => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);
  Color get _cardBg     => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBg    => _isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF);
  Color get _textColor  => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor   => _isDark ? Colors.white.withOpacity(0.65) : const Color(0xFF3D3A5C).withOpacity(0.65);
  Color get _hintColor  => _isDark ? Colors.white.withOpacity(0.22) : Colors.black.withOpacity(0.28);
  Color get _iconColor  => _isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.30);
  Color get _backBg     => _isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
  Color get _backBorder => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);
  Color get _backIcon   => _isDark ? Colors.white.withOpacity(0.75) : Colors.black.withOpacity(0.65);
  Color get _cardBorder => _isDark ? _accent.withOpacity(0.30) : _accent.withOpacity(0.18);
  Color get _enabledBorder => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);
  Color get _progInactive  => _isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.10);
  Color get _glowColor1 => _isDark ? const Color(0xFF5C4FCC) : const Color(0xFF7C6FE8);
  Color get _glowColor2 => _isDark ? const Color(0xFF3B2FA0) : const Color(0xFFAB9FF8);
  Color get _termsColor => _isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.35);

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();

    emailFocus.addListener(() => setState(() {}));
    passwordFocus.addListener(() => setState(() {}));
    confirmFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) setState(() {});
  }

  Future<void> _signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmController.text.trim().isEmpty) {
      _snack("Please fill in all fields", isError: true); return;
    }
    if (!emailRegex.hasMatch(email)) {
      _snack("Format: 23021519-101@uog.edu.pk", isError: true); return;
    }
    if (!passwordRegex.hasMatch(password)) {
      _snack("Password needs 8+ chars, uppercase, number & symbol", isError: true); return;
    }
    if (passwordController.text != confirmController.text) {
      _snack("Passwords do not match", isError: true); return;
    }
    setState(() => _isLoading = true);
    try {
      // ✅ Firebase mein UOG email ke saath account create hoga
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _snack("Account created successfully! 🎉");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _snack(e.message ?? "Signup failed", isError: true);
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

  int _strengthLevel() {
    final p = passwordController.text;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]'))) score++;
    if (p.contains(RegExp(r'[0-9]'))) score++;
    if (p.contains(RegExp(r'[!@#\$&*~]'))) score++;
    return score;
  }

  Color _strengthColor(int lvl) {
    if (lvl <= 1) return const Color(0xFFE24B4A);
    if (lvl == 2) return const Color(0xFFF5A623);
    if (lvl == 3) return const Color(0xFF4BC8E8);
    return const Color(0xFF2ECC71);
  }

  String _strengthLabel(int lvl) {
    if (lvl <= 1) return "Weak";
    if (lvl == 2) return "Fair";
    if (lvl == 3) return "Good";
    return "Strong";
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strengthLevel();

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

          Positioned(top: -80, right: -80, child: _glow(280, _glowColor1)),
          Positioned(bottom: -60, left: -60, child: _glow(240, _glowColor2)),

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
                          // ✅ FIX: mainAxisAlignment.center se card vertically mid mein aa gaya
                          // ✅ FIX: Spacer() hataya — woh card ko niche dhakelta tha
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              const SizedBox(height: 16),

                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(
                                    color: _backBg,
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(color: _backBorder, width: 1),
                                  ),
                                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: _backIcon),
                                ),
                              ),

                              const SizedBox(height: 28),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: _accent.withOpacity(0.4), width: 1),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                                  Icon(Icons.school_rounded, size: 13, color: _accentLt),
                                  SizedBox(width: 6),
                                  Text("Join Smart Campus",
                                      style: TextStyle(fontSize: 12, color: _accentLt, fontWeight: FontWeight.w700)),
                                ]),
                              ),

                              const SizedBox(height: 14),

                              Text("Create Your\nAccount",
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: _textColor,
                                      height: 1.15,
                                      letterSpacing: -0.8)),

                              const SizedBox(height: 6),

                              Text("Start navigating your campus today",
                                  style: TextStyle(fontSize: 14, color: _subColor.withOpacity(0.6))),

                              const SizedBox(height: 24),

                              Row(children: [
                                _progSeg(done: true),
                                const SizedBox(width: 6),
                                _progSeg(active: true),
                                const SizedBox(width: 6),
                                _progSeg(),
                              ]),

                              const SizedBox(height: 26),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                                decoration: BoxDecoration(
                                  color: _cardBg,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(color: _cardBorder, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                        color: _accent.withOpacity(0.18),
                                        blurRadius: 40, spreadRadius: -4, offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    _label("University Email"),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: emailController,
                                      focusNode: emailFocus,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                      onSubmitted: (_) => FocusScope.of(context).requestFocus(passwordFocus),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _fieldDeco(
                                        hint: "23021519-101@uog.edu.pk",
                                        icon: Icons.alternate_email_rounded,
                                        isFocused: emailFocus.hasFocus,
                                      ),
                                    ),

                                    const SizedBox(height: 6),
                                    Row(children: [
                                      Icon(Icons.info_outline_rounded, size: 12, color: _accentLt.withOpacity(0.5)),
                                      const SizedBox(width: 5),
                                      Text("Format: RegNo-Section@uog.edu.pk",
                                          style: TextStyle(fontSize: 11, color: _subColor.withOpacity(0.7))),
                                    ]),

                                    const SizedBox(height: 16),

                                    _label("Password"),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: passwordController,
                                      focusNode: passwordFocus,
                                      obscureText: isPasswordHidden,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                      onSubmitted: (_) => FocusScope.of(context).requestFocus(confirmFocus),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _fieldDeco(
                                        hint: "Min 8 chars, A-Z, 0-9, symbol",
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

                                    if (passwordController.text.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        ...List.generate(4, (i) => Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(right: i < 3 ? 5 : 0),
                                            height: 4,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: i < strength ? _strengthColor(strength) : _progInactive,
                                            ),
                                          ),
                                        )),
                                        const SizedBox(width: 10),
                                        Text(_strengthLabel(strength),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _strengthColor(strength))),
                                      ]),
                                    ],

                                    const SizedBox(height: 20),

                                    _label("Confirm Password"),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: confirmController,
                                      focusNode: confirmFocus,
                                      obscureText: isConfirmHidden,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                      onSubmitted: (_) => _signUp(),
                                      onChanged: (_) => setState(() {}),
                                      decoration: _fieldDeco(
                                        hint: "Re-enter password",
                                        icon: Icons.lock_person_outlined,
                                        isFocused: confirmFocus.hasFocus,
                                        suffix: IconButton(
                                          icon: Icon(
                                            isConfirmHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                            size: 20, color: _iconColor,
                                          ),
                                          onPressed: () => setState(() => isConfirmHidden = !isConfirmHidden),
                                        ),
                                        suffixOverride: confirmController.text.isNotEmpty &&
                                            confirmController.text == passwordController.text
                                            ? const Icon(Icons.check_circle_rounded, size: 20, color: Color(0xFF2ECC71))
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 54,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _accent,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: _isLoading ? null : _signUp,
                                        child: _isLoading
                                            ? const SizedBox(width: 22, height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                            : const Text("Create Account",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: TextStyle(fontSize: 11, color: _termsColor, height: 1.6),
                                          children: const [
                                            TextSpan(text: "By signing up you agree to our "),
                                            TextSpan(text: "Terms",
                                                style: TextStyle(color: _accentLt, fontWeight: FontWeight.w600)),
                                            TextSpan(text: " and "),
                                            TextSpan(text: "Privacy Policy",
                                                style: TextStyle(color: _accentLt, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
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
      gradient: RadialGradient(colors: [color.withOpacity(0.28), Colors.transparent]),
    ),
  );

  Widget _label(String text) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _subColor, letterSpacing: 0.4));

  Widget _progSeg({bool done = false, bool active = false}) => Expanded(
    child: Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: done ? _accent : active ? _accent.withOpacity(0.4) : _progInactive,
      ),
    ),
  );

  InputDecoration _fieldDeco({
    required String hint,
    required IconData icon,
    required bool isFocused,
    Widget? suffix,
    Widget? suffixOverride,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _hintColor, fontSize: 13),
      prefixIcon: Icon(icon, size: 19, color: isFocused ? _accentLt : _iconColor),
      suffixIcon: suffixOverride ?? suffix,
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
      errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 11),
    );
  }
}