import 'package:flutter/material.dart';
import '../main.dart';
import 'map_screen.dart';

class SearchScreen extends StatefulWidget {
  final String query;
  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  // ── Theme Helpers ─────────────────────────────────────────
  bool  get _isDark    => themeProvider.isDark;
  Color get _bg1       => _isDark ? const Color(0xFF0A0818) : const Color(0xFFF0EFFF);
  Color get _bg2       => _isDark ? const Color(0xFF1E1A4A) : const Color(0xFFE8E6FF);
  Color get _bg3       => _isDark ? const Color(0xFF16142E) : const Color(0xFFEEEDFF);
  Color get _cardBgT   => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBgT  => _isDark ? const Color(0xFF13112A) : const Color(0xFFF0EFFF);
  Color get _textCol   => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subCol    => _isDark ? Colors.white.withOpacity(0.38) : Colors.black.withOpacity(0.45);
  Color get _borderC   => _isDark ? _accent.withOpacity(0.35) : _accent.withOpacity(0.25);
  Color get _hintCol   => _isDark ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.30);
  Color get _iconCol   => _isDark ? Colors.white.withOpacity(0.40) : Colors.black.withOpacity(0.40);
  Color get _catBgCol  => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _chipBgCol => _isDark ? const Color(0xFF13112A) : Colors.white;
  Color get _chipBdrC  => _isDark ? _accent.withOpacity(0.25) : _accent.withOpacity(0.20);

  late TextEditingController _searchController;
  String _searchQuery = '';

  late AnimationController _animController;
  late Animation<double>   _fadeAnim;

  final List<Map<String, dynamic>> _allBuildings = [
    {"name": "Main Gate",            "category": "Campus",   "icon": Icons.door_front_door_rounded,        "color": Color(0xFF6C5CE7), "lat": 32.08870, "lng": 74.18310, "desc": "Main entrance gate of UOG"},
    {"name": "Admin Block",          "category": "Academic", "icon": Icons.business_rounded,               "color": Color(0xFF6C5CE7), "lat": 32.08963, "lng": 74.18409, "desc": "Main administrative office"},
    {"name": "VC Office",            "category": "Academic", "icon": Icons.account_balance_rounded,        "color": Color(0xFF6C5CE7), "lat": 32.08980, "lng": 74.18390, "desc": "Vice Chancellor's office"},
    {"name": "Library",              "category": "Academic", "icon": Icons.local_library_rounded,          "color": Color(0xFF00B4D8), "lat": 32.09010, "lng": 74.18430, "desc": "Main campus library"},
    {"name": "SSC Office",           "category": "Services", "icon": Icons.supervised_user_circle_rounded, "color": Color(0xFF1ABC9C), "lat": 32.08950, "lng": 74.18370, "desc": "Student Service Center"},
    {"name": "CS & IT Department",   "category": "Academic", "icon": Icons.computer_rounded,               "color": Color(0xFF1ABC9C), "lat": 32.09030, "lng": 74.18450, "desc": "Computer Science & IT department"},
    {"name": "Science Block",        "category": "Academic", "icon": Icons.science_rounded,                "color": Color(0xFF1ABC9C), "lat": 32.09050, "lng": 74.18460, "desc": "Natural Sciences block"},
    {"name": "Commerce Department",  "category": "Academic", "icon": Icons.bar_chart_rounded,              "color": Color(0xFF1ABC9C), "lat": 32.09020, "lng": 74.18440, "desc": "Commerce & Management"},
    {"name": "Engineering Block",    "category": "Academic", "icon": Icons.engineering_rounded,            "color": Color(0xFF1ABC9C), "lat": 32.09060, "lng": 74.18420, "desc": "Engineering department"},
    {"name": "Auditorium",           "category": "Academic", "icon": Icons.theater_comedy_rounded,         "color": Color(0xFF9B59B6), "lat": 32.08940, "lng": 74.18360, "desc": "Main auditorium"},
    {"name": "Examination Hall",     "category": "Academic", "icon": Icons.assignment_rounded,             "color": Color(0xFF6C5CE7), "lat": 32.08930, "lng": 74.18355, "desc": "Main examination hall"},
    {"name": "Arts Block",           "category": "Academic", "icon": Icons.palette_rounded,                "color": Color(0xFF6C5CE7), "lat": 32.08945, "lng": 74.18365, "desc": "Arts & Humanities block"},
    {"name": "Computer Lab 1",       "category": "Labs",     "icon": Icons.desktop_windows_rounded,        "color": Color(0xFF00B4D8), "lat": 32.09035, "lng": 74.18455, "desc": "General computer lab"},
    {"name": "Computer Lab 2",       "category": "Labs",     "icon": Icons.desktop_windows_rounded,        "color": Color(0xFF00B4D8), "lat": 32.09040, "lng": 74.18460, "desc": "Programming lab"},
    {"name": "Physics Lab",          "category": "Labs",     "icon": Icons.biotech_rounded,                "color": Color(0xFF00B4D8), "lat": 32.09052, "lng": 74.18465, "desc": "Physics experiments lab"},
    {"name": "Chemistry Lab",        "category": "Labs",     "icon": Icons.science_rounded,                "color": Color(0xFF00B4D8), "lat": 32.09055, "lng": 74.18468, "desc": "Chemistry lab"},
    {"name": "Biology Lab",          "category": "Labs",     "icon": Icons.grass_rounded,                  "color": Color(0xFF00B4D8), "lat": 32.09058, "lng": 74.18470, "desc": "Biology & botany lab"},
    {"name": "Main Cafeteria",       "category": "Food",     "icon": Icons.restaurant_rounded,             "color": Color(0xFFFF7675), "lat": 32.08920, "lng": 74.18340, "desc": "Main campus cafeteria"},
    {"name": "Boys Canteen",         "category": "Food",     "icon": Icons.fastfood_rounded,               "color": Color(0xFFFF7675), "lat": 32.08910, "lng": 74.18330, "desc": "Boys side canteen"},
    {"name": "Girls Canteen",        "category": "Food",     "icon": Icons.fastfood_rounded,               "color": Color(0xFFFF7675), "lat": 32.08915, "lng": 74.18335, "desc": "Girls side canteen"},
    {"name": "Faculty Lounge",       "category": "Food",     "icon": Icons.local_cafe_rounded,             "color": Color(0xFFFF7675), "lat": 32.08970, "lng": 74.18385, "desc": "Faculty dining lounge"},
    {"name": "Bank (HBL)",           "category": "Services", "icon": Icons.account_balance_rounded,        "color": Color(0xFF1ABC9C), "lat": 32.08900, "lng": 74.18350, "desc": "HBL Bank branch on campus"},
    {"name": "ATM",                  "category": "Services", "icon": Icons.local_atm_rounded,              "color": Color(0xFF1ABC9C), "lat": 32.08902, "lng": 74.18352, "desc": "ATM machine"},
    {"name": "Post Office",          "category": "Services", "icon": Icons.mail_rounded,                   "color": Color(0xFF1ABC9C), "lat": 32.08895, "lng": 74.18345, "desc": "Campus post office"},
    {"name": "Transport Office",     "category": "Services", "icon": Icons.directions_bus_rounded,         "color": Color(0xFF1ABC9C), "lat": 32.08860, "lng": 74.18320, "desc": "Bus routes & transport"},
    {"name": "Security Office",      "category": "Services", "icon": Icons.security_rounded,               "color": Color(0xFF1ABC9C), "lat": 32.08875, "lng": 74.18315, "desc": "Campus security office"},
    {"name": "Photocopy Shop",       "category": "Services", "icon": Icons.print_rounded,                  "color": Color(0xFF1ABC9C), "lat": 32.08878, "lng": 74.18318, "desc": "Print & photocopy services"},
    {"name": "Hospital / Clinic",    "category": "Health",   "icon": Icons.local_hospital_rounded,         "color": Color(0xFFE17055), "lat": 32.08880, "lng": 74.18380, "desc": "Campus medical center"},
    {"name": "Dispensary",           "category": "Health",   "icon": Icons.medical_services_rounded,       "color": Color(0xFFE17055), "lat": 32.08882, "lng": 74.18382, "desc": "First aid & medicine"},
    {"name": "Boys Hostel 1",        "category": "Hostels",  "icon": Icons.hotel_rounded,                  "color": Color(0xFF9B59B6), "lat": 32.09100, "lng": 74.18500, "desc": "Boys hostel block 1"},
    {"name": "Boys Hostel 2",        "category": "Hostels",  "icon": Icons.hotel_rounded,                  "color": Color(0xFF9B59B6), "lat": 32.09110, "lng": 74.18510, "desc": "Boys hostel block 2"},
    {"name": "Girls Hostel 1",       "category": "Hostels",  "icon": Icons.house_rounded,                  "color": Color(0xFF9B59B6), "lat": 32.09080, "lng": 74.18480, "desc": "Girls hostel block 1"},
    {"name": "Girls Hostel 2",       "category": "Hostels",  "icon": Icons.house_rounded,                  "color": Color(0xFF9B59B6), "lat": 32.09085, "lng": 74.18485, "desc": "Girls hostel block 2"},
    {"name": "Guest House",          "category": "Hostels",  "icon": Icons.villa_rounded,                  "color": Color(0xFF9B59B6), "lat": 32.09090, "lng": 74.18490, "desc": "University guest house"},
    {"name": "Cricket Ground",       "category": "Sports",   "icon": Icons.sports_cricket_rounded,         "color": Color(0xFFF39C12), "lat": 32.09120, "lng": 74.18520, "desc": "Main cricket ground"},
    {"name": "Football Ground",      "category": "Sports",   "icon": Icons.sports_soccer_rounded,          "color": Color(0xFFF39C12), "lat": 32.09130, "lng": 74.18530, "desc": "Football field"},
    {"name": "Gymnasium",            "category": "Sports",   "icon": Icons.fitness_center_rounded,         "color": Color(0xFFF39C12), "lat": 32.09090, "lng": 74.18490, "desc": "Sports gymnasium"},
    {"name": "Basketball Court",     "category": "Sports",   "icon": Icons.sports_basketball_rounded,      "color": Color(0xFFF39C12), "lat": 32.09095, "lng": 74.18495, "desc": "Basketball court"},
  ];

  final List<String> _suggestions = [
    "Library", "Cafeteria", "CS Department",
    "Boys Hostel", "Hospital", "Admin Block",
  ];

  List<Map<String, dynamic>> get _results {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _allBuildings.where((b) =>
    b['name'].toString().toLowerCase().contains(q) ||
        b['category'].toString().toLowerCase().contains(q) ||
        b['desc'].toString().toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);
    _searchQuery      = widget.query;
    _searchController = TextEditingController(text: widget.query);
    _animController   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChange() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final results = _results;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _bg1,
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
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Search Bar Row ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _fieldBgT,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: _borderC, width: 1.5),
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: _accentLt, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _fieldBgT,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _borderC, width: 1.5),
                          boxShadow: [
                            BoxShadow(color: _accent.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: TextStyle(color: _textCol, fontSize: 14),
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: "Library, Hostel, Cafeteria...",
                            hintStyle: TextStyle(color: _hintCol, fontSize: 13),
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: _accentLt.withOpacity(0.7)),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? GestureDetector(
                              onTap: () => setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              }),
                              child: Icon(Icons.close_rounded, size: 18, color: _iconCol),
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                // ── Results count ────────────────────────
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                    child: Text(
                      "${results.length} result${results.length != 1 ? 's' : ''} for \"$_searchQuery\"",
                      style: TextStyle(fontSize: 12, color: _subCol, fontWeight: FontWeight.w500),
                    ),
                  ),

                const SizedBox(height: 12),

                // ── Body ─────────────────────────────────
                Expanded(
                  child: _searchQuery.isEmpty
                      ? _emptyState()
                      : results.isEmpty
                      ? _noResults()
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _tile(results[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Map<String, dynamic> b) {
    final color = b['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => MapScreen(
          focusLat:  b['lat'],
          focusLng:  b['lng'],
          focusName: b['name'],
        )),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBgT,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.28), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.40), width: 1.5),
              boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 10, spreadRadius: -2)],
            ),
            child: Icon(b['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b['name'],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textCol)),
              const SizedBox(height: 3),
              Text(b['desc'], style: TextStyle(fontSize: 11, color: _subCol)),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(b['category'],
                      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.map_rounded, size: 11, color: _iconCol),
                const SizedBox(width: 4),
                Text("View on map", style: TextStyle(fontSize: 10, color: _iconCol)),
              ]),
            ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _iconCol),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          Center(
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent.withOpacity(0.30), width: 1.5),
                  boxShadow: [BoxShadow(color: _accent.withOpacity(0.15), blurRadius: 20, spreadRadius: -4)],
                ),
                child: Icon(Icons.search_rounded, size: 34, color: _accentLt.withOpacity(0.6)),
              ),
              const SizedBox(height: 14),
              Text("Search UOG Campus",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textCol)),
              const SizedBox(height: 6),
              Text("Find buildings, labs, offices & more",
                  style: TextStyle(fontSize: 13, color: _subCol)),
            ]),
          ),

          const SizedBox(height: 30),

          // Quick suggestions
          Text("Quick Search",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _subCol, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _suggestions.map((s) => GestureDetector(
              onTap: () => setState(() {
                _searchQuery = s;
                _searchController.text = s;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _chipBgCol,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _chipBdrC, width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_rounded, size: 13, color: _accentLt.withOpacity(0.7)),
                  const SizedBox(width: 6),
                  Text(s, style: TextStyle(fontSize: 12, color: _textCol, fontWeight: FontWeight.w600)),
                ]),
              ),
            )).toList(),
          ),

          const SizedBox(height: 28),

          // Categories
          Text("Browse by Category",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _subCol, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          ...[
            {"label": "Academic",  "icon": Icons.school_rounded,                "color": Color(0xFF6C5CE7)},
            {"label": "Labs",      "icon": Icons.science_rounded,               "color": Color(0xFF00B4D8)},
            {"label": "Food",      "icon": Icons.restaurant_rounded,            "color": Color(0xFFFF7675)},
            {"label": "Services",  "icon": Icons.miscellaneous_services_rounded, "color": Color(0xFF1ABC9C)},
            {"label": "Hostels",   "icon": Icons.hotel_rounded,                 "color": Color(0xFF9B59B6)},
            {"label": "Sports",    "icon": Icons.sports_rounded,                "color": Color(0xFFF39C12)},
          ].map((cat) => GestureDetector(
            onTap: () => setState(() {
              _searchQuery = cat['label'] as String;
              _searchController.text = cat['label'] as String;
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _catBgCol,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (cat['color'] as Color).withOpacity(0.22), width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 19),
                ),
                const SizedBox(width: 12),
                Text(cat['label'] as String,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textCol)),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _iconCol),
              ]),
            ),
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _noResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 52, color: _subCol.withOpacity(0.5)),
          const SizedBox(height: 14),
          Text("No results for \"$_searchQuery\"",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _subCol)),
          const SizedBox(height: 8),
          Text("Try: Library, Hostel, Cafeteria",
              style: TextStyle(fontSize: 12, color: _subCol.withOpacity(0.6))),
        ],
      ),
    );
  }
}