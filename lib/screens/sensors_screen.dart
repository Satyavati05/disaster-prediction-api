import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({Key? key}) : super(key: key);

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Prediction State
  double _lat = 28.61;
  double _lon = 77.23;
  double _magnitude = 0.0;
  String _predictionResult = "Not Calculated";
  bool _isLoading = false;

  Future<void> _getPrediction() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/predict"), // emulator
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "lat": _lat,
          "lon": _lon,
          "magnitude": _magnitude,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List predictions = data['prediction'];
        setState(() => _predictionResult = predictions.join(", "));

        // Store result in firebase
        await FirebaseFirestore.instance.collection('weather_predictions').add({
          'temperature': data['temperature'],
          'wind_speed': data['wind_speed'],
          'prediction': data['prediction'],
          'timestamp': DateTime.now(),
        });

        // Trigger alerts for each prediction
        for (var p in predictions) {
          await NotificationService.showLocalAlert("⚠️ Alert", p.toString());
        }
      } else {
        setState(() => _predictionResult = "Error: ${response.statusCode}");
      }
    } catch (e) {
      // Offline fallback simple logic
      setState(() => _predictionResult = "Connection Failed (Offline)");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: AppBar(
        title: const Text(
          'Sensor Network',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.primaryOrange),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.darkBlueBg, Color(0xFF2C3E50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkText.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.greenAccent, width: 2),
                      ),
                      child: const Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Network Status',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Optimal (1,240 Active Sensors)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Sensor Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                Text(
                  'updated just now',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid of Sensors
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildSensorCard(
                  title: 'Air Quality Index',
                  value: '42',
                  unit: 'AQI',
                  icon: Icons.air,
                  trend: '+2',
                  trendUp: false,
                  color: Colors.blue,
                ),
                _buildSensorCard(
                  title: 'Latitude',
                  value: _lat.toStringAsFixed(2),
                  unit: '°',
                  icon: Icons.location_on,
                  trend: 'Live',
                  trendUp: true,
                  color: Colors.blueAccent,
                ),
                _buildSensorCard(
                  title: 'Longitude',
                  value: _lon.toStringAsFixed(2),
                  unit: '°',
                  icon: Icons.map,
                  trend: 'Live',
                  trendUp: true,
                  color: Colors.cyan,
                ),
                _buildSensorCard(
                  title: 'Soil Moisture',
                  value: '34',
                  unit: '%',
                  icon: Icons.water_drop_outlined,
                  trend: '-5',
                  trendUp: false,
                  color: Colors.teal,
                ),
                _buildSensorCard(
                  title: 'Surface Temp',
                  value: '31.2',
                  unit: '°C',
                  icon: Icons.thermostat,
                  trend: '+1.4',
                  trendUp: true,
                  color: AppTheme.primaryOrange,
                ),
                _buildSensorCard(
                  title: 'Wind Speed',
                  value: '18',
                  unit: 'km/h',
                  icon: Icons.speed,
                  trend: '+4',
                  trendUp: true,
                  color: Colors.indigo,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Disaster Prediction Tool Section
            const Text(
              'Disaster Prediction (AI Engine)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.inputBg, width: 1.5),
              ),
              child: Column(
                children: [
                  // SLIDER FOR LATITUDE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Latitude', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(_lat.toStringAsFixed(2), style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _lat,
                        min: -90,
                        max: 90,
                        activeColor: AppTheme.primaryOrange,
                        onChanged: (val) => setState(() => _lat = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // SLIDER FOR LONGITUDE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Longitude', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(_lon.toStringAsFixed(2), style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _lon,
                        min: -180,
                        max: 180,
                        activeColor: Colors.cyan,
                        onChanged: (val) => setState(() => _lon = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // SLIDER FOR MAGNITUDE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Test Earthquake Mag.', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(_magnitude.toStringAsFixed(1), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Slider(
                        value: _magnitude,
                        min: 0,
                        max: 10,
                        activeColor: Colors.red,
                        onChanged: (val) => setState(() => _magnitude = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // PREDICT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _getPrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlueBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Calculate Prediction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  if (_predictionResult != "Not Calculated") ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _predictionResult.contains("High") ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _predictionResult.contains("High") ? Colors.red : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text('AI ANALYSIS RESULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 4),
                          Text(
                            "Prediction: $_predictionResult",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _predictionResult.contains("High") ? Colors.red : Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required String trend,
    required bool trendUp,
    required Color color,
  }) {
    return _InteractiveCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.inputBg, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.more_horiz, color: AppTheme.grayText.withValues(alpha: 0.5)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.grayText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: trendUp ? Colors.redAccent : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  '$trend $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: trendUp ? Colors.redAccent : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Custom interactive wrapper to make cards feel alive
class _InteractiveCard extends StatefulWidget {
  final Widget child;
  const _InteractiveCard({required this.child});

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (_isHovered && !_isPressed)
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              else if (!_isPressed)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
