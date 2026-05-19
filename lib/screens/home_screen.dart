import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'map_screen.dart';
import 'buildings_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'directions_screen.dart';
import '../main.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  int _currentIndex = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final _searchController = TextEditingController();
  int _unreadCount = 0;  // 🔴 Badge count

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadUnreadCount();  // 🔔 Load badge on start
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChange() { if (mounted) setState(() {}); }

  bool get _isDark => themeProvider.isDark;

  // ── Load unread count ──────────────────────────────────────
  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.instance.unreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  void _onTab(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);
    _animController.reset();
    _animController.forward();
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _DashboardPage(search: _searchController, onTab: _onTab, isDark: _isDark);
      case 1: return const MapScreen();
      case 2: return const BuildingsScreen();
      case 3: return const ProfileScreen();
      default: return _DashboardPage(search: _searchController, onTab: _onTab, isDark: _isDark);
    }
  }

  Color get _navBg   => _isDark ? const Color(0xFF13112A) : Colors.white;
  Color get _bgGrad1 => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bgGrad2 => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bgGrad3 => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);

  // ── Notification Bell Tap ─────────────────────────────────
  void _openNotifications() async {
    // Mark all as read
    await NotificationService.instance.markAllRead();
    setState(() => _unreadCount = 0);

    // Load history and show
    final history = await NotificationService.instance.loadHistory();

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _isDark ? const Color(0xFF1C1836) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _NotificationSheet(history: history, isDark: _isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: _isDark ? const Color(0xFF0E0C1E) : Colors.white,
      systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgGrad1, _bgGrad2, _bgGrad3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(opacity: _fadeAnim, child: _buildBody()),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: _navBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _accent.withOpacity(0.20), width: 1.5),
          boxShadow: [
            BoxShadow(color: _accent.withOpacity(0.18), blurRadius: 28, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_rounded, "Home"),
            _navItem(1, Icons.map_rounded, "Map"),
            _navItem(2, Icons.apartment_rounded, "Buildings"),
            _navItem(3, Icons.person_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final bool on = _currentIndex == index;
    final inactiveColor = _isDark
        ? Colors.white.withOpacity(0.30)
        : Colors.black.withOpacity(0.35);

    return GestureDetector(
      onTap: () => _onTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: on ? 18 : 12, vertical: 9),
        decoration: BoxDecoration(
          color: on ? _accent.withOpacity(0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: on ? Border.all(color: _accent.withOpacity(0.45), width: 1) : null,
          boxShadow: on
              ? [BoxShadow(color: _accent.withOpacity(0.25), blurRadius: 12, spreadRadius: -2)]
              : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: on ? _accentLt : inactiveColor),
          if (on) ...[
            const SizedBox(width: 7),
            Text(label, style: const TextStyle(color: _accentLt, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Notification Bottom Sheet
// ═══════════════════════════════════════════════════════════════
class _NotificationSheet extends StatelessWidget {
  final List<AppNotification> history;
  final bool isDark;
  const _NotificationSheet({required this.history, required this.isDark});

  Color get _cardBg  => isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF);
  Color get _textCol => isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subCol  => isDark ? Colors.white38 : Colors.black38;

  IconData _iconFor(String type) {
    switch (type) {
      case 'campus_updates':      return Icons.campaign_rounded;
      case 'schedule_reminders':  return Icons.event_rounded;
      case 'map_alerts':          return Icons.map_rounded;
      default:                    return Icons.notifications_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'campus_updates':      return const Color(0xFF6C5CE7);
      case 'schedule_reminders':  return const Color(0xFF00B4D8);
      case 'map_alerts':          return const Color(0xFF1ABC9C);
      default:                    return const Color(0xFFF39C12);
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scroll) => Column(children: [
        // Handle + header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 18),
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FE8).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFF7C6FE8).withOpacity(0.40), width: 1.5),
                ),
                child: const Icon(Icons.notifications_rounded, color: Color(0xFFAB9FF8), size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Notifications",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _textCol)),
                Text("${history.length} total",
                    style: TextStyle(fontSize: 12, color: _subCol)),
              ]),
            ]),
            const SizedBox(height: 16),
          ]),
        ),

        // List or empty state
        Expanded(
          child: history.isEmpty
              ? Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_off_rounded,
                  size: 56, color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 14),
              Text("No notifications yet",
                  style: TextStyle(fontSize: 15, color: _subCol, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text("Campus updates will appear here",
                  style: TextStyle(fontSize: 12, color: _subCol)),
            ],
          ))
              : ListView.separated(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = history[i];
              final col = _colorFor(n.type);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: col.withOpacity(0.25), width: 1.5),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: col.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: col.withOpacity(0.35), width: 1),
                    ),
                    child: Icon(_iconFor(n.type), size: 20, color: col),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(n.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textCol)),
                    const SizedBox(height: 4),
                    Text(n.body,
                        style: TextStyle(fontSize: 12, color: _subCol, height: 1.4)),
                    const SizedBox(height: 6),
                    Text(_timeAgo(n.time),
                        style: TextStyle(fontSize: 11, color: col.withOpacity(0.7),
                            fontWeight: FontWeight.w600)),
                  ])),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Dashboard Tab — same as before + notification bell working
// ════════════════════════════════════════════════════════════
class _DashboardPage extends StatelessWidget {
  final TextEditingController search;
  final Function(int) onTab;
  final bool isDark;
  const _DashboardPage({required this.search, required this.onTab, required this.isDark});

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  Color get _cardBg    => isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _searchBg  => isDark ? const Color(0xFF13112A) : Colors.white;
  Color get _chipBg    => isDark ? const Color(0xFF13112A) : Colors.white;
  Color get _textColor => isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor  => isDark ? Colors.white.withOpacity(0.38) : const Color(0xFF3D3A5C).withOpacity(0.55);
  Color get _borderCol => isDark ? _accent.withOpacity(0.22) : _accent.withOpacity(0.18);
  Color get _chipBorder=> isDark ? Colors.white.withOpacity(0.09) : Colors.black.withOpacity(0.08);
  Color get _notifBg   => isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.06);
  Color get _notifBdr  => isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.10);
  Color get _hintColor => isDark ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.30);
  Color get _iconColor => isDark ? Colors.white.withOpacity(0.55) : Colors.black.withOpacity(0.45);

  void _showExamDetails(BuildContext context) {
    final exams = [
      {"date": "May 10", "subject": "Mathematics",      "detail": "Hall A  •  9:00 AM",  "color": const Color(0xFF6C5CE7)},
      {"date": "May 12", "subject": "Computer Science", "detail": "Hall B  •  10:00 AM", "color": const Color(0xFF1ABC9C)},
      {"date": "May 14", "subject": "Physics",          "detail": "Hall C  •  9:00 AM",  "color": const Color(0xFF00B4D8)},
      {"date": "May 16", "subject": "English",          "detail": "Hall A  •  11:00 AM", "color": const Color(0xFFF39C12)},
      {"date": "May 18", "subject": "Pakistan Studies", "detail": "Hall D  •  9:00 AM",  "color": const Color(0xFFE17055)},
      {"date": "May 20", "subject": "Islamiat",         "detail": "Hall B  •  10:00 AM", "color": const Color(0xFF27AE60)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1836) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.40), width: 1.5),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF9B8FF8), size: 22),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Exam Schedule",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1A1730))),
                Text("May 2025 — Final Exams",
                    style: TextStyle(fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ]),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE17055).withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE17055).withOpacity(0.30), width: 1.5),
              ),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFE17055), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text("Carry your admit card & student ID to every exam",
                      style: TextStyle(fontSize: 12, color: Color(0xFFE17055), fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text("SCHEDULE",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                    color: isDark ? Colors.white38 : Colors.black38)),
            const SizedBox(height: 12),
            ...exams.map((exam) {
              final col = exam['color'] as Color;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF13112A) : const Color(0xFFF5F4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: col.withOpacity(0.25), width: 1.5),
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: col.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: col.withOpacity(0.35), width: 1),
                    ),
                    child: Text(exam['date'] as String,
                        style: TextStyle(fontSize: 11, color: col, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(exam['subject'] as String,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1A1730))),
                    const SizedBox(height: 2),
                    Text(exam['detail'] as String,
                        style: TextStyle(fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38)),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: col.withOpacity(0.6), size: 20),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user  = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "";
    final raw   = email.contains('@') ? email.split('@')[0] : "Student";
    final isStudentId = RegExp(r'^\d').hasMatch(raw);
    final name  = isStudentId ? "Student" : raw[0].toUpperCase() + raw.substring(1);

    // Get unread count from ancestor
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    final unread    = homeState?._unreadCount ?? 0;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Top Bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _accent.withOpacity(0.50), width: 1.5),
                    boxShadow: [BoxShadow(color: _accent.withOpacity(0.28), blurRadius: 14, spreadRadius: -2)],
                  ),
                  child: const Icon(Icons.school_rounded, size: 24, color: Color(0xFFAB9FF8)),
                ),
                const SizedBox(width: 13),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Hello, $name 👋",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textColor)),
                  Text("Smart Campus Navigator",
                      style: TextStyle(fontSize: 11, color: _subColor)),
                ]),
                const Spacer(),

                // ✅ Working Notification Bell with Badge
                GestureDetector(
                  onTap: () => homeState?._openNotifications(),
                  child: Stack(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _notifBg,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: _notifBdr, width: 1),
                      ),
                      child: Icon(
                        unread > 0
                            ? Icons.notifications_rounded
                            : Icons.notifications_none_rounded,
                        size: 21,
                        color: unread > 0 ? _accentLt : _iconColor,
                      ),
                    ),
                    // 🔴 Red badge
                    if (unread > 0)
                      Positioned(
                        top: 4, right: 4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE24B4A),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ]),
            ),

            const SizedBox(height: 24),

            // ── Announcement Banner ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.5),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text("📍 Smart Navigation",
                              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 10),
                        const Text("Explore Campus\nNavigation",
                            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                        const SizedBox(height: 6),
                        Text("Find blocks, rooms & directions easily",
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => onTab(1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: const Text("Open Map →",
                                style: TextStyle(fontSize: 12, color: Color(0xFF6C5CE7), fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.map_rounded, size: 76, color: Colors.white24),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // ── Search Bar ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: _searchBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderCol, width: 1.5),
                  boxShadow: [BoxShadow(color: _accent.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: search,
                  style: TextStyle(color: _textColor, fontSize: 14),
                  onSubmitted: (v) {
                    if (v.isNotEmpty) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(query: v)));
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Search buildings, blocks, rooms...",
                    hintStyle: TextStyle(color: _hintColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, size: 21, color: _accentLt.withOpacity(0.6)),
                    suffixIcon: Icon(Icons.tune_rounded, size: 19, color: _iconColor.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Quick Actions ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Quick Actions",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textColor)),
                  Text("See all",
                      style: TextStyle(fontSize: 12, color: _accentLt.withOpacity(0.7), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.98,
                children: [
                  _card(context: context, icon: Icons.map_rounded, title: "Campus Map",
                      subtitle: "View your location", color: const Color(0xFF6C5CE7), onTap: () => onTab(1)),
                  _card(context: context, icon: Icons.near_me_rounded, title: "Directions",
                      subtitle: "Navigate to building", color: const Color(0xFF00B4D8),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectionsScreen()))),
                  _card(context: context, icon: Icons.apartment_rounded, title: "Buildings",
                      subtitle: "Browse & search", color: const Color(0xFF9B59B6), onTap: () => onTab(2)),
                  _card(context: context, icon: Icons.person_rounded, title: "Profile",
                      subtitle: "Account settings", color: const Color(0xFF1ABC9C), onTap: () => onTab(3)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Campus Info ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("Campus Info",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textColor)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Row(children: [
                  Expanded(child: _chip(Icons.access_time_rounded, "Open 8AM–8PM")),
                  const SizedBox(width: 12),
                  Expanded(child: _chip(Icons.wifi_rounded, "Free Campus WiFi")),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _chip(Icons.local_parking_rounded, "Parking Available")),
                  const SizedBox(width: 12),
                  Expanded(child: _chip(Icons.restaurant_rounded, "Cafeteria: Block C")),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required BuildContext context, required IconData icon, required String title,
    required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.45), width: 1.5),
              boxShadow: [BoxShadow(color: color.withOpacity(0.28), blurRadius: 12, spreadRadius: -2)],
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textColor)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(fontSize: 11, color: _subColor)),
          ]),
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: _chipBg,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: _chipBorder, width: 1),
    ),
    child: Row(children: [
      Icon(icon, size: 14, color: const Color(0xFFAB9FF8)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: _subColor), overflow: TextOverflow.ellipsis)),
    ]),
  );
}