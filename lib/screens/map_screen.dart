// ============================================================
// map_screen.dart — UOG Hafiz Hayat Campus Interactive Map
// ✅ ALL COORDINATES VERIFIED VIA GOOGLE MAPS BY USER
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  final double? focusLat;
  final double? focusLng;
  final String? focusName;

  const MapScreen({super.key, this.focusLat, this.focusLng, this.focusName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _accent   = Color(0xFF7C6FE8);
  static const _accentLt = Color(0xFFAB9FF8);

  // ✅ Campus center updated based on real building positions
  static const _uogCenter = LatLng(32.6395, 74.1655);

  final MapController _mapController = MapController();
  LatLng _myLocation     = _uogCenter;
  bool   _locationLoaded = false;
  bool   _mapReady       = false;

  // ✅ ALL COORDINATES VERIFIED VIA GOOGLE MAPS
  final List<Map<String, dynamic>> _buildings = [

    // ── Academic Blocks ───────────────────────────────────
    {
      "name": "Arfa Karim Block (B-Block)",
      "lat": 32.64161064440145, "lng": 74.16750875705614,
      "icon": Icons.computer_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "Al-Farabi Block (A-Block)",
      "lat": 32.641812722366915, "lng": 74.16663823952774,
      "icon": Icons.palette_rounded,
      "color": Color(0xFF6C5CE7),
    },
    {
      "name": "Ibn-e-Sina Block",
      "lat": 32.64170573997089, "lng": 74.1660814221149,
      "icon": Icons.science_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "Al-Khawarizmi Block",
      "lat": 32.640638603372274, "lng": 74.16788559657331,
      "icon": Icons.calculate_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "P. Omar Al-Khayam Block",
      "lat": 32.64007114534291, "lng": 74.16746990023447,
      "icon": Icons.school_rounded,
      "color": Color(0xFF6C5CE7),
    },
    {
      "name": "Jabir Bin Khayan Block",
      "lat": 32.639927571066806, "lng": 74.16667585564831,
      "icon": Icons.biotech_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "Al-Jazari Block",
      "lat": 32.64104607692107, "lng": 74.16550671025347,
      "icon": Icons.engineering_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "Sada Block",
      "lat": 32.641234915061716, "lng": 74.16850833350038,
      "icon": Icons.apartment_rounded,
      "color": Color(0xFF6C5CE7),
    },
    {
      "name": "Islamic Studies Dept",
      "lat": 32.638299077440905, "lng": 74.16598780130144,
      "icon": Icons.mosque_rounded,
      "color": Color(0xFF27AE60),
    },
    {
      "name": "Ibn-e-Khuldun / Quaid-e-Azam Library",
      "lat": 32.63842856138075, "lng": 74.16448090719456,
      "icon": Icons.local_library_rounded,
      "color": Color(0xFF00B4D8),
    },
    {
      "name": "Admin Block",
      "lat": 32.63784018144842, "lng": 74.16467725275889,
      "icon": Icons.business_rounded,
      "color": Color(0xFF6C5CE7),
    },

    // ── Food ─────────────────────────────────────────────
    {
      "name": "M Cafe",
      "lat": 32.64251940956256, "lng": 74.16409801580508,
      "icon": Icons.local_cafe_rounded,
      "color": Color(0xFFFF7675),
    },
    {
      "name": "Main Cafeteria",
      "lat": 32.640202472928245, "lng": 74.16461416933748,
      "icon": Icons.restaurant_rounded,
      "color": Color(0xFFFF7675),
    },
    {
      "name": "P Cafe",
      "lat": 32.639965090520334, "lng": 74.16821995208686,
      "icon": Icons.coffee_rounded,
      "color": Color(0xFFFF7675),
    },

    // ── Services ─────────────────────────────────────────
    {
      "name": "Transport Office",
      "lat": 32.64234102597765, "lng": 74.16529353786433,
      "icon": Icons.directions_bus_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "UOG Mart",
      "lat": 32.63812819816714, "lng": 74.16197090269037,
      "icon": Icons.shopping_bag_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "SSC Office",
      "lat": 32.636787839201006, "lng": 74.16178502719148,
      "icon": Icons.supervised_user_circle_rounded,
      "color": Color(0xFF1ABC9C),
    },
    // ── Stationary Shops (approximate near main blocks) ───
    {
      "name": "Stationary Shop 1",
      "lat": 32.63800, "lng": 74.16430,
      "icon": Icons.edit_rounded,
      "color": Color(0xFF1ABC9C),
    },
    {
      "name": "Stationary Shop 2",
      "lat": 32.64100, "lng": 74.16700,
      "icon": Icons.edit_note_rounded,
      "color": Color(0xFF1ABC9C),
    },

    // ── Campus ───────────────────────────────────────────
    {
      "name": "UOG Mosque",
      "lat": 32.6375746156943, "lng": 74.16015706165298,
      "icon": Icons.mosque_rounded,
      "color": Color(0xFF27AE60),
    },

    // ── Hostels ───────────────────────────────────────────
    {
      "name": "Girls Main Hostel",
      "lat": 32.63779160381281, "lng": 74.16045417139846,
      "icon": Icons.house_rounded,
      "color": Color(0xFF9B59B6),
    },
    {
      "name": "Boys Hostel",
      "lat": 32.63561422485083, "lng": 74.16067175825927,
      "icon": Icons.hotel_rounded,
      "color": Color(0xFF9B59B6),
    },

    // ── Halls ─────────────────────────────────────────────
    {
      "name": "Iqbal Hall",
      "lat": 32.63604300210459, "lng": 74.16093069085233,
      "icon": Icons.theater_comedy_rounded,
      "color": Color(0xFF9B59B6),
    },
    {
      "name": "IHRM",
      "lat": 32.63642388544824, "lng": 74.16184198283685,
      "icon": Icons.people_rounded,
      "color": Color(0xFF6C5CE7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) setState(() => _locationLoaded = true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _myLocation     = LatLng(pos.latitude, pos.longitude);
          _locationLoaded = true;
        });
        if (_mapReady) {
          _mapController.move(
            widget.focusLat != null
                ? LatLng(widget.focusLat!, widget.focusLng!)
                : _myLocation,
            widget.focusLat != null ? 19 : 17,
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => _locationLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initCenter = widget.focusLat != null
        ? LatLng(widget.focusLat!, widget.focusLng!)
        : _uogCenter;
    // ✅ zoom 17 default (was 16) — better spread of pins
    final initZoom = widget.focusLat != null ? 19.0 : 17.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0818),
      body: Stack(children: [

        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initCenter,
            initialZoom:   initZoom,
            minZoom: 10,
            maxZoom: 19,
            onMapReady: () {
              setState(() => _mapReady = true);
              if (_locationLoaded) _mapController.move(initCenter, initZoom);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.smart_campus_app',
              maxZoom: 19,
              fallbackUrl: 'https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
            ),

            MarkerLayer(markers: [
              if (_locationLoaded)
                Marker(
                  point: _myLocation,
                  width: 44, height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: _accentLt, width: 2.5),
                      boxShadow: [BoxShadow(
                          color: _accent.withOpacity(0.5),
                          blurRadius: 14, spreadRadius: 2)],
                    ),
                    child: const Icon(Icons.my_location_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),

              ..._buildings.map((b) {
                final isHL  = widget.focusName == b['name'];
                final color = b['color'] as Color;
                return Marker(
                  point: LatLng(b['lat'], b['lng']),
                  width:  isHL ? 130 : 100,
                  height: isHL ? 76  : 62,
                  child: GestureDetector(
                    onTap: () => _showInfo(b),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isHL ? _accent : color,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white, width: isHL ? 2.5 : 1.5),
                          boxShadow: [BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 10, spreadRadius: 1)],
                        ),
                        child: Icon(b['icon'] as IconData,
                            color: Colors.white, size: isHL ? 18 : 14),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isHL
                              ? _accent.withOpacity(0.95)
                              : const Color(0xFF13112A).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: isHL
                                  ? _accentLt
                                  : color.withOpacity(0.4),
                              width: 1),
                        ),
                        child: Text(b['name'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: isHL ? 10 : 8,
                              fontWeight: isHL
                                  ? FontWeight.w800
                                  : FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                );
              }),
            ]),
          ],
        ),

        // ── HEADER ───────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 14, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0818).withOpacity(0.97),
                  Colors.transparent
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(children: [
              if (widget.focusName != null)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13112A),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: _accent.withOpacity(0.40), width: 1.5),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _accentLt, size: 15),
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF13112A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _accent.withOpacity(0.40), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: _accent.withOpacity(0.28), blurRadius: 14)],
                ),
                child: const Icon(Icons.map_rounded,
                    color: _accentLt, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.focusName ?? "Campus Map",
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                    Text("UOG Hafiz Hayat Campus",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.40))),
                  ])),

              GestureDetector(
                onTap: () => _mapController.move(
                  widget.focusLat != null
                      ? LatLng(widget.focusLat!, widget.focusLng!)
                      : _myLocation,
                  widget.focusLat != null ? 19 : 17,
                ),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13112A),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: _accent.withOpacity(0.40), width: 1.5),
                  ),
                  child: const Icon(Icons.center_focus_strong_rounded,
                      color: _accentLt, size: 18),
                ),
              ),
            ]),
          ),
        ),

        if (!_locationLoaded)
          Positioned(
            bottom: 120, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF13112A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.30), width: 1),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _accentLt),
                ),
                const SizedBox(width: 10),
                Text("Getting your location...",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 12)),
              ]),
            )),
          ),

        if (_locationLoaded)
          Positioned(
            bottom: 110, left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF13112A).withOpacity(0.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.20), width: 1),
              ),
              child: Text("Tap a pin to see building info",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 11)),
            )),
          ),
      ]),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          heroTag: 'mapFab',
          onPressed: _getLocation,
          backgroundColor: const Color(0xFF13112A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _accent.withOpacity(0.45), width: 1.5),
          ),
          child: const Icon(Icons.my_location_rounded, color: _accentLt, size: 22),
        ),
      ),
    );
  }

  void _showInfo(Map<String, dynamic> b) {
    final color = b['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1836),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.35), width: 1.5),
          boxShadow: [BoxShadow(
              color: color.withOpacity(0.20), blurRadius: 20, spreadRadius: -4)],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Icon(b['icon'] as IconData, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(b['name'],
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text("UOG Hafiz Hayat Campus",
                    style: TextStyle(
                        fontSize: 11, color: Colors.white.withOpacity(0.4))),
              ])),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close_rounded,
                size: 20, color: Colors.white.withOpacity(0.3)),
          ),
        ]),
      ),
    );
  }
}