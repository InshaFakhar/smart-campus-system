// ============================================================
// buildings_screen.dart — UOG Campus Buildings Directory
// ✅ ALL COORDINATES VERIFIED VIA GOOGLE MAPS BY USER
// ============================================================

import 'package:flutter/material.dart';
import '../main.dart';
import 'map_screen.dart';
import 'directions_screen.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {

  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  final _searchController  = TextEditingController();
  String _searchQuery      = '';
  String _selectedCategory = 'All';

  bool  get _isDark     => themeProvider.isDark;
  Color get _cardBg     => _isDark ? const Color(0xFF1C1836) : Colors.white;
  Color get _fieldBg    => _isDark ? const Color(0xFF13112A) : Colors.white;
  Color get _textColor  => _isDark ? Colors.white : const Color(0xFF1A1730);
  Color get _subColor   => _isDark ? Colors.white.withOpacity(0.40) : const Color(0xFF3D3A5C).withOpacity(0.55);
  Color get _hintColor  => _isDark ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.30);
  Color get _iconBg     => _isDark ? const Color(0xFF13112A) : const Color(0xFFF0EFFF);
  Color get _chipBg     => _isDark ? const Color(0xFF13112A) : const Color(0xFFF0EFFF);
  Color get _chipBorder => _isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.10);
  Color get _arrowColor => _isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.25);

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onThemeChange() { if (mounted) setState(() {}); }

  // ✅ ALL COORDINATES VERIFIED VIA GOOGLE MAPS
  // Campus zones:
  //  NORTH  (32.641+): Arfa Karim, Al-Farabi, Ibn-e-Sina, Sada, Transport, M Cafe
  //  MIDDLE (32.639–32.641): Al-Jazari, Al-Khawarizmi, Omar Al-Khayam, Jabir Bin Khayan, Main Cafe, P Cafe
  //  SOUTH  (32.635–32.639): Admin, Library, Islamic Dept, Mosque, Mart, SSC, Hostels, Iqbal Hall, IHRM
  final List<Map<String, dynamic>> _allBuildings = [

    // ── NORTH CAMPUS ───────────────────────────────────────────
    {
      "name": "Arfa Karim Block (B-Block)",
      "category": "Academic",
      "icon": Icons.computer_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.64161064440145, "lng": 74.16750875705614,
      "desc": "Computer Science & IT — Arfa Karim Randhawa Block",
      "status": "Open",
    },
    {
      "name": "Al-Farabi Block (A-Block)",
      "category": "Academic",
      "icon": Icons.palette_rounded,
      "color": Color(0xFF6C5CE7),
      "lat": 32.641812722366915, "lng": 74.16663823952774,
      "desc": "Arts, Social Sciences & Humanities — Al-Farabi Block",
      "status": "Open",
    },
    {
      "name": "Ibn-e-Sina Block",
      "category": "Academic",
      "icon": Icons.science_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.64170573997089, "lng": 74.1660814221149,
      "desc": "Science & related departments — Ibn-e-Sina Block",
      "status": "Open",
    },
    {
      "name": "Sada Block",
      "category": "Academic",
      "icon": Icons.apartment_rounded,
      "color": Color(0xFF6C5CE7),
      "lat": 32.641234915061716, "lng": 74.16850833350038,
      "desc": "Academic block — north-east campus area",
      "status": "Open",
    },
    {
      "name": "Transport Office",
      "category": "Services",
      "icon": Icons.directions_bus_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.64234102597765, "lng": 74.16529353786433,
      "desc": "UOG bus routes, schedules & transport passes",
      "status": "Open",
    },
    {
      "name": "M Cafe",
      "category": "Food",
      "icon": Icons.local_cafe_rounded,
      "color": Color(0xFFFF7675),
      "lat": 32.64251940956256, "lng": 74.16409801580508,
      "desc": "M Cafe — snacks, tea, coffee — north-west campus",
      "status": "Open",
    },

    // ── MIDDLE CAMPUS ──────────────────────────────────────────
    {
      "name": "Al-Jazari Block",
      "category": "Academic",
      "icon": Icons.engineering_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.64104607692107, "lng": 74.16550671025347,
      "desc": "Engineering & Technology — Al-Jazari Block",
      "status": "Open",
    },
    {
      "name": "Al-Khawarizmi Block",
      "category": "Academic",
      "icon": Icons.calculate_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.640638603372274, "lng": 74.16788559657331,
      "desc": "Mathematics & Computing — Al-Khawarizmi Block",
      "status": "Open",
    },
    {
      "name": "P. Omar Al-Khayam Block",
      "category": "Academic",
      "icon": Icons.school_rounded,
      "color": Color(0xFF6C5CE7),
      "lat": 32.64007114534291, "lng": 74.16746990023447,
      "desc": "Academic block — Prof. Omar Al-Khayam Block",
      "status": "Open",
    },
    {
      "name": "Jabir Bin Khayan Block",
      "category": "Academic",
      "icon": Icons.biotech_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.639927571066806, "lng": 74.16667585564831,
      "desc": "Chemistry & Science — Jabir Bin Khayan Block",
      "status": "Open",
    },
    {
      "name": "Main Cafeteria",
      "category": "Food",
      "icon": Icons.restaurant_rounded,
      "color": Color(0xFFFF7675),
      "lat": 32.640202472928245, "lng": 74.16461416933748,
      "desc": "Main campus cafeteria — full meals, snacks, drinks",
      "status": "Open",
    },
    {
      "name": "P Cafe",
      "category": "Food",
      "icon": Icons.coffee_rounded,
      "color": Color(0xFFFF7675),
      "lat": 32.639965090520334, "lng": 74.16821995208686,
      "desc": "P Cafe — east campus, popular among students",
      "status": "Open",
    },

    // ── SOUTH CAMPUS ───────────────────────────────────────────
    {
      "name": "Islamic Studies Dept",
      "category": "Academic",
      "icon": Icons.mosque_rounded,
      "color": Color(0xFF27AE60),
      "lat": 32.638299077440905, "lng": 74.16598780130144,
      "desc": "Islamic Studies & Arabic — south campus",
      "status": "Open",
    },
    {
      "name": "Ibn-e-Khuldun / Quaid-e-Azam Library",
      "category": "Academic",
      "icon": Icons.local_library_rounded,
      "color": Color(0xFF00B4D8),
      "lat": 32.63842856138075, "lng": 74.16448090719456,
      "desc": "Main university library — books, journals, digital resources",
      "status": "Open",
    },
    {
      "name": "Admin Block",
      "category": "Academic",
      "icon": Icons.business_rounded,
      "color": Color(0xFF6C5CE7),
      "lat": 32.63784018144842, "lng": 74.16467725275889,
      "desc": "Main admin offices — VC, Registrar, Finance, Admissions",
      "status": "Open",
    },
    {
      "name": "UOG Mosque",
      "category": "Campus",
      "icon": Icons.mosque_rounded,
      "color": Color(0xFF27AE60),
      "lat": 32.6375746156943, "lng": 74.16015706165298,
      "desc": "Campus mosque — Friday prayers & daily namaz",
      "status": "Open",
    },
    {
      "name": "UOG Mart",
      "category": "Food",
      "icon": Icons.shopping_bag_rounded,
      "color": Color(0xFFFF7675),
      "lat": 32.63812819816714, "lng": 74.16197090269037,
      "desc": "UOG Mart — grocery, stationery, daily essentials",
      "status": "Open",
    },
    {
      "name": "Girls Main Hostel",
      "category": "Hostels",
      "icon": Icons.house_rounded,
      "color": Color(0xFF9B59B6),
      "lat": 32.63779160381281, "lng": 74.16045417139846,
      "desc": "Girls hostel — secured, walled boundary",
      "status": "Open",
    },
    {
      "name": "SSC Office",
      "category": "Services",
      "icon": Icons.supervised_user_circle_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.636787839201006, "lng": 74.16178502719148,
      "desc": "Student Service Center — fee, enrollment, documents",
      "status": "Open",
    },
    {
      "name": "Iqbal Hall",
      "category": "Campus",
      "icon": Icons.theater_comedy_rounded,
      "color": Color(0xFF9B59B6),
      "lat": 32.63604300210459, "lng": 74.16093069085233,
      "desc": "Main event hall — seminars, functions & gatherings",
      "status": "Open",
    },
    {
      "name": "IHRM",
      "category": "Academic",
      "icon": Icons.people_rounded,
      "color": Color(0xFF6C5CE7),
      "lat": 32.63642388544824, "lng": 74.16184198283685,
      "desc": "Institute of Hotel & Restaurant Management",
      "status": "Open",
    },
    {
      "name": "Boys Hostel",
      "category": "Hostels",
      "icon": Icons.hotel_rounded,
      "color": Color(0xFF9B59B6),
      "lat": 32.63561422485083, "lng": 74.16067175825927,
      "desc": "Boys hostel — south-west campus",
      "status": "Open",
    },

    // ── SERVICES / SHOPS ───────────────────────────────────────
    {
      "name": "Stationary Shop 1",
      "category": "Services",
      "icon": Icons.edit_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.63800, "lng": 74.16430,
      "desc": "Stationery, print, photocopy — near Library/Admin area",
      "status": "Open",
    },
    {
      "name": "Stationary Shop 2",
      "category": "Services",
      "icon": Icons.edit_note_rounded,
      "color": Color(0xFF1ABC9C),
      "lat": 32.64100, "lng": 74.16700,
      "desc": "Stationery, books, binding — near academic blocks",
      "status": "Open",
    },
  ];

  final List<String> _categories = [
    'All', 'Academic', 'Food', 'Services', 'Hostels', 'Campus',
  ];

  List<Map<String, dynamic>> get _filtered {
    return _allBuildings.where((b) {
      final matchSearch = b['name'].toString().toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          b['desc'].toString().toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == 'All' ||
          b['category'] == _selectedCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _accent.withOpacity(0.35), width: 1.5),
                    boxShadow: [BoxShadow(
                        color: _accent.withOpacity(0.25), blurRadius: 12)],
                  ),
                  child: const Icon(Icons.apartment_rounded,
                      color: _accentLt, size: 20),
                ),
                const SizedBox(width: 12),
                Text("Buildings",
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w800, color: _textColor)),
                const Spacer(),
                Text("${filtered.length} found",
                    style: TextStyle(fontSize: 12, color: _subColor)),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Search Bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: _fieldBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _accent.withOpacity(0.28), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: _accent.withOpacity(0.10),
                      blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: _textColor, fontSize: 14),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search — Arfa Karim, Al-Jazari, M Cafe...",
                    hintStyle: TextStyle(color: _hintColor, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, size: 20,
                        color: _accentLt.withOpacity(0.6)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                      onTap: () => setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      }),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: _subColor),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Category Filter ───────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final sel = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _accent : _chipBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? _accent : _chipBorder),
                        boxShadow: sel
                            ? [BoxShadow(
                            color: _accent.withOpacity(0.30),
                            blurRadius: 8, spreadRadius: -2)]
                            : null,
                      ),
                      child: Text(cat,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : _subColor)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Buildings List ────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 48, color: _subColor),
                  const SizedBox(height: 12),
                  Text("No buildings found",
                      style: TextStyle(
                          color: _subColor, fontSize: 14)),
                ],
              ))
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _buildingTile(filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildingTile(Map<String, dynamic> b) {
    final color  = b['color'] as Color;
    final status = b['status'] as String;

    Color statusColor;
    if (status == "Open" || status == "Available") {
      statusColor = const Color(0xFF2ECC71);
    } else if (status == "Busy") {
      statusColor = const Color(0xFFF39C12);
    } else {
      statusColor = const Color(0xFFE24B4A);
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => MapScreen(
          focusLat: b['lat'],
          focusLng: b['lng'],
          focusName: b['name'],
        ),
      )),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.28), width: 1.5),
          boxShadow: [BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: color.withOpacity(0.40), width: 1.5),
              boxShadow: [BoxShadow(
                  color: color.withOpacity(0.20),
                  blurRadius: 8, spreadRadius: -2)],
            ),
            child: Icon(b['icon'] as IconData, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b['name'],
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700, color: _textColor)),
              const SizedBox(height: 3),
              Text(b['desc'],
                  style: TextStyle(fontSize: 11, color: _subColor),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 7),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(b['category'],
                      style: TextStyle(fontSize: 10,
                          color: color, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status,
                      style: TextStyle(fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => DirectionsScreen(
                          destinationName: b['name'],
                          destinationLat: b['lat'],
                          destinationLng: b['lng'],
                        ),
                      )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(children: [
                      Icon(Icons.near_me_rounded,
                          size: 10, color: Color(0xFF00B4D8)),
                      SizedBox(width: 3),
                      Text("Directions",
                          style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF00B4D8),
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ],
          )),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: _arrowColor),
        ]),
      ),
    );
  }
}