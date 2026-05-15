import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  File? _profileImage;
  bool  _notificationsEnabled    = true;
  bool  _campusUpdates           = true;
  bool  _scheduleReminders       = true;
  bool  _mapAlerts               = false;
  String _selectedLanguage       = "English";

  // Language strings — English / Urdu
  Map<String, String> get _t => _selectedLanguage == "Urdu" ? {
    "profile":          "پروفائل",
    "student":          "طالب علم",
    "buildings":        "عمارتیں دیکھیں",
    "saved_routes":     "محفوظ راستے",
    "days_active":      "فعال دن",
    "account":          "اکاؤنٹ",
    "edit_profile":     "پروفائل ترمیم",
    "notifications":    "اطلاعات",
    "change_password":  "پاس ورڈ تبدیل",
    "preferences":      "ترجیحات",
    "saved_locations":  "محفوظ مقامات",
    "search_history":   "تلاش کی تاریخ",
    "settings":         "ترتیبات",
    "dark_mode":        "ڈارک موڈ",
    "light_mode":       "لائٹ موڈ",
    "switch_light":     "لائٹ موڈ پر جائیں",
    "switch_dark":      "ڈارک موڈ پر جائیں",
    "language":         "زبان",
    "app":              "ایپ",
    "about_app":        "ایپ کے بارے میں",
    "sign_out":         "سائن آؤٹ",
  } : {
    "profile":          "Profile",
    "student":          "Student",
    "buildings":        "Buildings Visited",
    "saved_routes":     "Saved Routes",
    "days_active":      "Days Active",
    "account":          "Account",
    "edit_profile":     "Edit Profile",
    "notifications":    "Notifications",
    "change_password":  "Change Password",
    "preferences":      "Preferences",
    "saved_locations":  "Saved Locations",
    "search_history":   "Search History",
    "settings":         "Settings",
    "dark_mode":        "Dark Mode",
    "light_mode":       "Light Mode",
    "switch_light":     "Switch to light mode",
    "switch_dark":      "Switch to dark mode",
    "language":         "Language",
    "app":              "App",
    "about_app":        "About App",
    "sign_out":         "Sign Out",
  };

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() { if (mounted) setState(() {}); }

  bool  get _isDark      => themeProvider.isDark;
  Color get _cardBg      => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBg     => _isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF);
  Color get _textColor   => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor    => _isDark ? Colors.white38 : const Color(0xFF3D3A5C).withOpacity(0.6);
  Color get _borderCol   => _isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.07);
  Color get _bgGrad1     => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bgGrad2     => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bgGrad3     => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);
  Color get _iconColor   => _isDark ? Colors.white.withOpacity(0.65) : const Color(0xFF3D3A5C).withOpacity(0.75);
  Color get _hintColor   => _isDark ? Colors.white.withOpacity(0.22) : Colors.black.withOpacity(0.28);
  Color get _enabledBdr  => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.12);

  // ── Image picker ──────────────────────────────────────────
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dragHandle(),
            const SizedBox(height: 16),
            Text("Profile Photo", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textColor)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _imgOption(Icons.camera_alt_rounded, "Camera", () async {
                Navigator.pop(context);
                final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80);
                if (img != null && mounted) setState(() => _profileImage = File(img.path));
              }),
              _imgOption(Icons.photo_library_rounded, "Gallery", () async {
                Navigator.pop(context);
                final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (img != null && mounted) setState(() => _profileImage = File(img.path));
              }),
              if (_profileImage != null)
                _imgOption(Icons.delete_rounded, "Remove", () {
                  Navigator.pop(context);
                  setState(() => _profileImage = null);
                }, color: const Color(0xFFE24B4A)),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _imgOption(IconData icon, String label, VoidCallback onTap, {Color? color}) =>
      GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: (color ?? _accent).withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: (color ?? _accent).withOpacity(0.35), width: 1.5),
            ),
            child: Icon(icon, color: color ?? _accentLt, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color ?? _subColor, fontWeight: FontWeight.w600)),
        ]),
      );

  // ── Edit Profile ──────────────────────────────────────────
  void _showEditProfile() {
    final user    = FirebaseAuth.instance.currentUser;
    final nameCtrl  = TextEditingController(text: user?.displayName ?? "");
    final phoneFocus = FocusNode();
    final nameFocus  = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ keyboard ke saath scroll hoga
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        // ✅ viewInsets.bottom — keyboard height automatically handle
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: SingleChildScrollView( // ✅ scroll bhi hoga
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            _dragHandle(),
            const SizedBox(height: 16),
            Text("Edit Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
            const SizedBox(height: 20),
            _sheetLabel("Display Name"),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              focusNode: nameFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(ctx).requestFocus(phoneFocus),
              style: TextStyle(color: _textColor, fontSize: 14),
              decoration: _sheetDeco(hint: "Your full name", icon: Icons.person_outline_rounded),
            ),
            const SizedBox(height: 16),
            _sheetLabel("Email (Read-only)"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _fieldBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _enabledBdr),
              ),
              child: Row(children: [
                Icon(Icons.alternate_email_rounded, size: 19, color: _iconColor),
                const SizedBox(width: 12),
                Text(user?.email ?? "", style: TextStyle(fontSize: 14, color: _subColor)),
              ]),
            ),
            const SizedBox(height: 16),
            _sheetLabel("Phone Number"),
            const SizedBox(height: 8),
            TextField(
              focusNode: phoneFocus,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: TextStyle(color: _textColor, fontSize: 14),
              decoration: _sheetDeco(hint: "+92 300 0000000", icon: Icons.phone_outlined),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent, foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    await user?.updateDisplayName(nameCtrl.text.trim());
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    setState(() {});
                    _snack("Profile updated successfully! ✅");
                  }
                },
                child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Change Password ───────────────────────────────────────
  void _showChangePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    final f1 = FocusNode(), f2 = FocusNode(), f3 = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ keyboard handle
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dragHandle(),
              const SizedBox(height: 16),
              Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
              const SizedBox(height: 4),
              Text("Enter your current password to confirm identity",
                  style: TextStyle(fontSize: 12, color: _subColor)),
              const SizedBox(height: 20),

              _sheetLabel("Current Password"),
              const SizedBox(height: 8),
              _pwField(ctrl: currentCtrl, focus: f1, nextFocus: f2, setS: setS,
                  hint: "Your current password", icon: Icons.lock_outline_rounded),

              const SizedBox(height: 14),
              _sheetLabel("New Password"),
              const SizedBox(height: 8),
              _pwField(ctrl: newCtrl, focus: f2, nextFocus: f3, setS: setS,
                  hint: "Min 8 chars, 1 uppercase, 1 symbol", icon: Icons.lock_reset_rounded),

              const SizedBox(height: 14),
              _sheetLabel("Confirm New Password"),
              const SizedBox(height: 8),
              _pwField(ctrl: confirmCtrl, focus: f3, setS: setS,
                  hint: "Re-enter new password", icon: Icons.check_circle_outline_rounded,
                  isDone: true),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent, foregroundColor: Colors.white,
                    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (newCtrl.text != confirmCtrl.text) { _snack("Passwords do not match", isError: true); return; }
                    if (newCtrl.text.length < 8) { _snack("Password too short (min 8 chars)", isError: true); return; }
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(newCtrl.text)) {
                      _snack("Need uppercase, number & symbol", isError: true); return;
                    }
                    try {
                      final user = FirebaseAuth.instance.currentUser!;
                      final cred = EmailAuthProvider.credential(email: user.email!, password: currentCtrl.text);
                      await user.reauthenticateWithCredential(cred);
                      await user.updatePassword(newCtrl.text);
                      if (mounted) { Navigator.pop(ctx); _snack("Password changed successfully! ✅"); }
                    } catch (_) { _snack("Current password is incorrect", isError: true); }
                  },
                  child: const Text("Update Password", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _pwField({
    required TextEditingController ctrl,
    required FocusNode focus,
    FocusNode? nextFocus,
    required StateSetter setS,
    required String hint,
    required IconData icon,
    bool isDone = false,
  }) {
    bool hidden = true;
    return StatefulBuilder(builder: (_, setLocal) => TextField(
      controller: ctrl,
      focusNode: focus,
      obscureText: hidden,
      textInputAction: isDone ? TextInputAction.done : TextInputAction.next,
      onSubmitted: nextFocus != null ? (_) => FocusScope.of(context).requestFocus(nextFocus) : null,
      style: TextStyle(color: _textColor, fontSize: 14),
      decoration: _sheetDeco(
        hint: hint,
        icon: icon,
        suffix: IconButton(
          icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 19, color: _iconColor),
          onPressed: () => setLocal(() => hidden = !hidden),
        ),
      ),
    ));
  }

  // ── Notifications ─────────────────────────────────────────
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _dragHandle(),
            const SizedBox(height: 16),
            Row(children: [
              Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? const Color(0xFF1D7A55).withOpacity(0.15)
                      : const Color(0xFFE24B4A).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _notificationsEnabled
                        ? const Color(0xFF2ECC71).withOpacity(0.4)
                        : const Color(0xFFE24B4A).withOpacity(0.35),
                  ),
                ),
                child: Text(
                  _notificationsEnabled ? "ON" : "OFF",
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _notificationsEnabled ? const Color(0xFF2ECC71) : const Color(0xFFE24B4A),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text("Control which notifications you receive from UOG Smart Campus",
                style: TextStyle(fontSize: 12, color: _subColor)),
            const SizedBox(height: 20),
            _notifRow("Push Notifications", "All alerts & announcements", _notificationsEnabled,
                    (v) => setS(() { setState(() => _notificationsEnabled = v); })),
            _notifRow("Campus Updates", "UOG news & events", _campusUpdates,
                    (v) => setS(() { setState(() => _campusUpdates = v); })),
            _notifRow("Schedule Reminders", "Class & exam reminders", _scheduleReminders,
                    (v) => setS(() { setState(() => _scheduleReminders = v); })),
            _notifRow("Map Alerts", "Building & route updates", _mapAlerts,
                    (v) => setS(() { setState(() => _mapAlerts = v); })),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _notifRow(String title, String sub, bool value, ValueChanged<bool> onChange) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderCol, width: 1.5),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textColor)),
            Text(sub, style: TextStyle(fontSize: 11, color: _subColor)),
          ])),
          Switch.adaptive(value: value, onChanged: onChange, activeColor: _accent),
        ]),
      );

  // ── Saved Locations ───────────────────────────────────────
  void _showSavedLocations() {
    final locs = [
      {"icon": Icons.school_rounded,          "name": "Admin Block",    "sub": "Main Campus, UOG"},
      {"icon": Icons.local_library_rounded,   "name": "Library",        "sub": "Near B-Block"},
      {"icon": Icons.sports_cricket_rounded,  "name": "Cricket Ground", "sub": "North Campus"},
      {"icon": Icons.restaurant_rounded,      "name": "Main Cafeteria", "sub": "Block C Area"},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dragHandle(),
          const SizedBox(height: 16),
          Row(children: [
            Text("Saved Locations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
            const Spacer(),
            Icon(Icons.bookmark_rounded, color: _accent, size: 22),
          ]),
          const SizedBox(height: 16),
          ...locs.map((loc) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderCol, width: 1.5),
            ),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accent.withOpacity(0.30), width: 1),
                ),
                child: Icon(loc["icon"] as IconData, color: _accentLt, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(loc["name"] as String,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textColor)),
                Text(loc["sub"] as String, style: TextStyle(fontSize: 11, color: _subColor)),
              ])),
              Icon(Icons.bookmark_rounded, color: _accent.withOpacity(0.7), size: 20),
            ]),
          )),
        ]),
      ),
    );
  }

  // ── Search History ────────────────────────────────────────
  void _showSearchHistory() {
    final List<String> history = ["Library", "Cafeteria", "Admin Block", "Sports Complex", "B-Block", "CS Department"];
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dragHandle(),
          const SizedBox(height: 16),
          Row(children: [
            Text("Search History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
            const Spacer(),
            GestureDetector(
              onTap: () => setS(() => history.clear()),
              child: Text("Clear All",
                  style: TextStyle(fontSize: 13, color: const Color(0xFFE24B4A).withOpacity(0.8), fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),
          history.isEmpty
              ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text("No search history yet", style: TextStyle(color: _subColor, fontSize: 14)))
              : Wrap(
            spacing: 8, runSpacing: 8,
            children: history.map((h) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.25), width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.history_rounded, size: 13, color: _accentLt.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(h, style: TextStyle(fontSize: 13, color: _accentLt, fontWeight: FontWeight.w600)),
              ]),
            )).toList(),
          ),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }

  // ── Language ──────────────────────────────────────────────
  void _showLanguage() {
    // ✅ English aur Urdu — dono actually apply hote hain (UI text change)
    final langs = [
      {"code": "English", "label": "English",   "sub": "Default language"},
      {"code": "Urdu",    "label": "اردو",       "sub": "قومی زبان"},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dragHandle(),
          const SizedBox(height: 16),
          Text(_t["language"]!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _textColor)),
          const SizedBox(height: 8),
          Text("Changing language updates app text", style: TextStyle(fontSize: 12, color: _subColor)),
          const SizedBox(height: 20),
          ...langs.map((lang) {
            final sel = _selectedLanguage == lang["code"];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedLanguage = lang["code"]!);
                Navigator.pop(context);
                _snack("Language changed to ${lang["label"]}");
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sel ? _accent.withOpacity(0.12) : _fieldBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? _accent.withOpacity(0.55) : _borderCol,
                    width: sel ? 2 : 1.5,
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: sel ? _accent.withOpacity(0.20) : _fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? _accent.withOpacity(0.4) : _borderCol),
                    ),
                    child: Center(child: Text(
                      lang["code"] == "Urdu" ? "اُ" : "En",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                          color: sel ? _accentLt : _subColor),
                    )),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(lang["label"]!, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                        color: sel ? _accentLt : _textColor)),
                    Text(lang["sub"]!, style: TextStyle(fontSize: 11, color: _subColor)),
                  ])),
                  if (sel) Icon(Icons.check_circle_rounded, color: _accent, size: 22),
                ]),
              ),
            );
          }),
        ]),
      )),
    );
  }

  // ── About App ─────────────────────────────────────────────
  void _showAboutApp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dragHandle(),
          const SizedBox(height: 20),
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _accent.withOpacity(0.55), width: 1.5),
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.30), blurRadius: 18, spreadRadius: -2)],
            ),
            child: const Icon(Icons.school_rounded, size: 36, color: _accentLt),
          ),
          const SizedBox(height: 14),
          Text("UOG Smart Campus", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _textColor)),
          const SizedBox(height: 4),
          Text("Version 1.0.0", style: TextStyle(fontSize: 13, color: _subColor)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderCol, width: 1.5),
            ),
            child: Text(
              "UOG Smart Campus is a navigation & information app for University of Gujrat students. Find buildings, explore campus map, get directions and stay updated with campus news.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _subColor, height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.copyright_rounded, size: 13, color: _subColor),
            const SizedBox(width: 4),
            Text("2024 University of Gujrat", style: TextStyle(fontSize: 12, color: _subColor)),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ── Sign Out ──────────────────────────────────────────────
  void _showSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_t["sign_out"]!, style: TextStyle(fontWeight: FontWeight.w900, color: _textColor)),
        content: Text("Are you sure you want to sign out?", style: TextStyle(color: _subColor, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: _subColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE24B4A), foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: Text(_t["sign_out"]!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFF8B1A1A) : const Color(0xFF1D7A55),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

  InputDecoration _sheetDeco({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _hintColor, fontSize: 13),
        prefixIcon: Icon(icon, size: 19, color: _iconColor),
        suffixIcon: suffix,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _enabledBdr)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _enabledBdr)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 2)),
      );

  Widget _sheetLabel(String text) => Text(text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _subColor, letterSpacing: 0.4));

  Widget _dragHandle() => Center(child: Container(
    width: 40, height: 4,
    decoration: BoxDecoration(color: _subColor, borderRadius: BorderRadius.circular(2)),
  ));

  @override
  Widget build(BuildContext context) {
    final user        = FirebaseAuth.instance.currentUser;
    final email       = user?.email ?? "Not logged in";
    final raw         = email.contains('@') ? email.split('@')[0] : "Student";
    final isStudentId = RegExp(r'^\d').hasMatch(raw);
    final displayName = user?.displayName;
    final name        = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (isStudentId ? "Student" : raw[0].toUpperCase() + raw.substring(1));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_bgGrad1, _bgGrad2, _bgGrad3],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(children: [
            const SizedBox(height: 22),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(_t["profile"]!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _textColor)),
              ),
            ),

            const SizedBox(height: 28),

            // Avatar — tap to change
            GestureDetector(
              onTap: _pickImage,
              child: Stack(children: [
                Container(
                  width: 92, height: 92,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent.withOpacity(0.55), width: 2),
                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.30), blurRadius: 20, spreadRadius: -2)],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover, width: 92, height: 92)
                        : const Icon(Icons.person_rounded, size: 46, color: Color(0xFFAB9FF8)),
                  ),
                ),
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _accent, shape: BoxShape.circle,
                      border: Border.all(color: _bgGrad1, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 14),
            Text(name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _textColor)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(fontSize: 13, color: _subColor)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.40), width: 1),
              ),
              child: Text(_t["student"]!, style: const TextStyle(fontSize: 11, color: _accentLt, fontWeight: FontWeight.w700)),
            ),

            const SizedBox(height: 28),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                _stat("12", _t["buildings"]!),
                const SizedBox(width: 12),
                _stat("3", _t["saved_routes"]!),
                const SizedBox(width: 12),
                _stat("5", _t["days_active"]!),
              ]),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Account
                _secLabel(_t["account"]!),
                _tile(Icons.person_outline_rounded,     _t["edit_profile"]!,    _showEditProfile),
                _tile(Icons.notifications_none_rounded, _t["notifications"]!,   _showNotifications,
                    trailing: _badge(_notificationsEnabled ? "ON" : "OFF", _notificationsEnabled)),
                _tile(Icons.lock_outline_rounded,       _t["change_password"]!, _showChangePassword),

                const SizedBox(height: 10),

                // Preferences
                _secLabel(_t["preferences"]!),
                _tile(Icons.map_outlined,    _t["saved_locations"]!, _showSavedLocations),
                _tile(Icons.history_rounded, _t["search_history"]!,  _showSearchHistory),

                const SizedBox(height: 10),

                // Settings
                _secLabel(_t["settings"]!),

                // Theme toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderCol, width: 1.5),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (_isDark ? _accent : const Color(0xFFF39C12)).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: (_isDark ? _accent : const Color(0xFFF39C12)).withOpacity(0.35), width: 1),
                      ),
                      child: Icon(_isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          size: 18, color: _isDark ? _accentLt : const Color(0xFFF39C12)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_isDark ? _t["dark_mode"]! : _t["light_mode"]!,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textColor)),
                      Text(_isDark ? _t["switch_light"]! : _t["switch_dark"]!,
                          style: TextStyle(fontSize: 11, color: _subColor)),
                    ])),
                    GestureDetector(
                      onTap: () => themeProvider.toggleTheme(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 52, height: 28,
                        decoration: BoxDecoration(
                          color: _isDark ? _accent : const Color(0xFFF39C12),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(
                            color: (_isDark ? _accent : const Color(0xFFF39C12)).withOpacity(0.4),
                            blurRadius: 8, spreadRadius: -2,
                          )],
                        ),
                        child: Stack(children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: _isDark ? 26 : 2, top: 2,
                            child: Container(
                              width: 24, height: 24,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                              child: Icon(_isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  size: 14, color: _isDark ? _accent : const Color(0xFFF39C12)),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ]),
                ),

                _tile(Icons.language_rounded, _t["language"]!, _showLanguage,
                    trailing: Text(_selectedLanguage == "Urdu" ? "اردو" : "English",
                        style: TextStyle(fontSize: 13, color: _accentLt, fontWeight: FontWeight.w600))),

                const SizedBox(height: 10),

                _secLabel(_t["app"]!),
                _tile(Icons.info_outline_rounded, _t["about_app"]!, _showAboutApp),
                _tile(Icons.logout_rounded, _t["sign_out"]!, _showSignOut, color: const Color(0xFFE24B4A)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _badge(String label, bool active) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: active ? const Color(0xFF1D7A55).withOpacity(0.15) : const Color(0xFFE24B4A).withOpacity(0.10),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: active ? const Color(0xFF2ECC71).withOpacity(0.4) : const Color(0xFFE24B4A).withOpacity(0.35), width: 1),
    ),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: active ? const Color(0xFF2ECC71) : const Color(0xFFE24B4A))),
  );

  Widget _stat(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withOpacity(0.20), width: 1.5),
        boxShadow: [BoxShadow(color: _accent.withOpacity(0.10), blurRadius: 16, spreadRadius: -4)],
      ),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _accentLt)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: _subColor, height: 1.4)),
      ]),
    ),
  );

  Widget _secLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _subColor, letterSpacing: 1.0)),
  );

  Widget _tile(IconData icon, String label, VoidCallback onTap, {Color? color, Widget? trailing}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: color != null ? color.withOpacity(0.08) : _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color != null ? color.withOpacity(0.25) : _borderCol, width: 1.5),
          ),
          child: Row(children: [
            Icon(icon, size: 20, color: color ?? _iconColor),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? _textColor))),
            if (trailing != null) trailing,
            if (trailing == null && color == null)
              Icon(Icons.chevron_right_rounded, size: 18, color: _subColor),
          ]),
        ),
      );
}