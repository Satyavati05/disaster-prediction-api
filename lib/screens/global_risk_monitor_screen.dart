import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import 'disaster_screen.dart';

class GlobalRiskMonitorScreen extends StatefulWidget {
  const GlobalRiskMonitorScreen({Key? key}) : super(key: key);

  @override
  State<GlobalRiskMonitorScreen> createState() => _GlobalRiskMonitorScreenState();
}

class _GlobalRiskMonitorScreenState extends State<GlobalRiskMonitorScreen> {
  bool cycloneOn = true;
  bool floodOn = false;
  bool seismicOn = false;
  bool landslideOn = false;
  bool rainfallOn = false;

  String _currentLocationText = 'Search location or zone';
  bool _isFetchingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _currentLocationText = 'Fetching GPS...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('GPS denied');
      }

      if (permission == LocationPermission.deniedForever) throw Exception('GPS perm. denied');

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _currentLocationText = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      setState(() {
        _currentLocationText = 'Search location or zone';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppTheme.lightGrayBg.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.darkText),
          onPressed: () {},
        ),
        title: const Text(
          'Global Risk Monitor',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppTheme.primaryOrange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DisasterScreen()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.inputBg,
              child: Icon(Icons.person, color: AppTheme.grayText),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE5E5E5), // Light gray base
            ),
            child: Center(
              child: Opacity(
                opacity: 0.1,
                child: Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
          ),

          // Floating Search Bar
          Positioned(
            top: 100,
            left: 16,
            right: 80, // give space for right buttons
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: _currentLocationText,
                  hintStyle: const TextStyle(color: AppTheme.grayText),
                  prefixIcon: _isFetchingLocation 
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange),
                          ),
                        )
                      : const Icon(Icons.search, color: AppTheme.primaryOrange),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Floating Tools (Right)
          Positioned(
            top: 100,
            right: 16,
            child: Column(
              children: [
                _buildMapToolButton(Icons.add, isTop: true),
                _buildMapToolButton(Icons.remove, isBottom: true),
                const SizedBox(height: 12),
                _buildMapToolButton(
                  Icons.my_location, 
                  isSingle: true,
                  onTap: _getCurrentLocation,
                ),
                const SizedBox(height: 12),
                _buildMapToolButton(Icons.layers, isSingle: true),
              ],
            ),
          ),

          // Active Risk Layers Panel
          Positioned(
            top: 180,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACTIVE RISK LAYERS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLayerToggle('Cyclone Path', Icons.radar, cycloneOn, (v) {
                    setState(() => cycloneOn = v);
                  }, isHighlight: true),
                  _buildLayerToggle('Flood Zones', Icons.water_damage, floodOn, (v) {
                    setState(() => floodOn = v);
                  }),
                  _buildLayerToggle('Seismic Activity', Icons.stacked_line_chart, seismicOn, (v) {
                    setState(() => seismicOn = v);
                  }),
                  _buildLayerToggle('Landslide Risk', Icons.terrain, landslideOn, (v) {
                    setState(() => landslideOn = v);
                  }),
                  _buildLayerToggle('Rainfall Anomalies', Icons.water_drop, rainfallOn, (v) {
                    setState(() => rainfallOn = v);
                  }),
                ],
              ),
            ),
          ),

          // Active Threat Bottom Card
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Active Threat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'CATEGORY 4',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cyclone 'Elysian'",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Moving North-West at 22km/h",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grayText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WIND SPEED',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.grayText.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '185 km/h',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRESSURE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.grayText.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '945 hPa',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info, color: AppTheme.primaryOrange, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'View Detailed Report',
                                style: TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                        ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // Bottom Sheet Handle representation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Environmental Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adjust visibility and transparency of environmental\ndata layers.',
                    style: TextStyle(fontSize: 13, color: AppTheme.grayText),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapToolButton(IconData icon, {bool isTop = false, bool isBottom = false, bool isSingle = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isSingle 
            ? BorderRadius.circular(12) 
            : BorderRadius.vertical(
                top: isTop ? const Radius.circular(12) : Radius.zero,
                bottom: isBottom ? const Radius.circular(12) : Radius.zero,
              ),
          border: !isSingle && isTop 
            ? Border(bottom: BorderSide(color: Colors.grey.shade200)) 
            : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Icon(icon, color: AppTheme.darkText, size: 20),
      ),
    );
  }

  Widget _buildLayerToggle(
    String title, 
    IconData icon, 
    bool value, 
    ValueChanged<bool> onChanged, 
    {bool isHighlight = false}
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: isHighlight ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isHighlight ? Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                size: 20, 
                color: isHighlight ? AppTheme.primaryOrange : AppTheme.darkText, // fallback actual icon colors
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.darkText,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primaryOrange,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.blueGrey.withOpacity(0.3),
          )
        ],
      ),
    );
  }
}
