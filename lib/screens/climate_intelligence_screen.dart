import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class ClimateIntelligenceScreen extends StatefulWidget {
  const ClimateIntelligenceScreen({super.key});

  @override
  State<ClimateIntelligenceScreen> createState() => _ClimateIntelligenceScreenState();
}

class _ClimateIntelligenceScreenState extends State<ClimateIntelligenceScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Overview', 'Risk Map', 'Satellite', 'Predictions'];

  late AnimationController _alertController;
  late Animation<double> _alertAnimation;

  // ML Prediction state
  bool _isPredicting = false;
  double _riskProbability = 0.64;
  String _flashFloodIndex = 'Moderate';

  @override
  void initState() {
    super.initState();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _alertAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _alertController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _alertController.dispose();
    super.dispose();
  }

  Future<void> _runPrediction() async {
    setState(() {
      _isPredicting = true;
    });

    try {
      // Modify IP to match your connected device (e.g. 10.0.2.2 for Android emulator or local WiFi IP)
      final response = await http.post(
        Uri.parse("http://192.168.1.5:5000/predict"), // Placeholder IP, user might need to change
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rainfall": 250,
          "river_level": 90
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming response is something like: {"risk_probability": 0.85, "flood_index": "High Risk"}
        setState(() {
          _riskProbability = (data['risk_probability'] ?? 0.85).toDouble();
          _flashFloodIndex = data['flood_index'] ?? 'High Risk';
        });
      } else {
        debugPrint("API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Prediction request failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryOrange,
            child: Icon(Icons.waves, color: Colors.white, size: 18),
          ),
        ),
        title: const Text(
          'Climate Intelligence',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(
                    _tabs.length,
                    (index) => _buildTab(_tabs[index], index),
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_selectedTabIndex != 0) {
      return Center(
        key: ValueKey(_selectedTabIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle_outlined, size: 64, color: AppTheme.grayText),
            const SizedBox(height: 16),
            Text(
              '${_tabs[_selectedTabIndex]} module in development',
              style: const TextStyle(color: AppTheme.grayText, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('Overview Tab'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real-Time Risk Map Card
          _InteractiveElement(child: _buildRealTimeRiskMapCard()),
          const SizedBox(height: 16),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _InteractiveElement(
                  child: _buildMetricCard(
                    title: 'Average Temperature',
                    value: '28.4°C',
                    subValue: '+1.2%',
                    icon: Icons.thermostat_outlined,
                    isIncrease: true,
                    bars: [0.3, 0.4, 0.35, 0.5, 0.6, 0.8],
                    barsColor: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    highlightLastBar: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InteractiveElement(
                  child: _buildMetricCard(
                    title: 'Sea Level Delta',
                    value: '+2.4mm',
                    subValue: 'stable',
                    icon: Icons.water_outlined,
                    isIncrease: false,
                    bars: [0.2, 0.25, 0.3, 0.3, 0.25, 0.4],
                    barsColor: Colors.blue.withValues(alpha: 0.3),
                    highlightLastBar: true,
                    highlightColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // AI Prediction Core Card
          _InteractiveElement(child: _buildAiPredictionCoreCard()),
          const SizedBox(height: 24),

          // Risk Alerts
          const Text(
            'Risk Alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 16),
          _InteractiveElement(
            child: _buildRiskAlertCard(
              icon: Icons.warning_amber_rounded,
              title: 'Cyclone Formation Detected',
              description: 'Satellite imagery confirms low pressure building at Sector 4A.',
              time: '2m ago',
              iconColor: Colors.red,
              animateIcon: true,
            ),
          ),
          _InteractiveElement(
            child: _buildRiskAlertCard(
              icon: Icons.air,
              title: 'Heatwave Warning',
              description: 'Ambient temperature sensors in Southern region exceeding 42°C.',
              time: '14m ago',
              iconColor: AppTheme.primaryOrange,
              animateIcon: false,
            ),
          ),
          const SizedBox(height: 24),

          // Satellite Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Satellite Preview',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              Text(
                'GOES-16',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grayText.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InteractiveElement(
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1451187580459-43490279c0fa?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 24),
        padding: const EdgeInsets.only(bottom: 12, top: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.grayText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeRiskMapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore, color: AppTheme.primaryOrange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Real-Time Risk Map',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Live Updates',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Empty map placeholder area
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightGrayBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _alertAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _alertAnimation.value,
                  child: const Icon(Icons.warning, color: Colors.amber, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PREDICTION HORIZON',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.grayText.withValues(alpha: 0.7),
                ),
              ),
              const Text(
                'CURRENT TIME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          Slider(
            value: 0.3,
            onChanged: (val) {},
            activeColor: AppTheme.primaryOrange,
            inactiveColor: AppTheme.inputBg,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('24 Hours', style: TextStyle(fontSize: 10, color: AppTheme.grayText)),
              Text('7 Days', style: TextStyle(fontSize: 10, color: AppTheme.grayText)),
              Text('30 Days', style: TextStyle(fontSize: 10, color: AppTheme.grayText)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subValue,
    required IconData icon,
    required bool isIncrease,
    required List<double> bars,
    required Color barsColor,
    required bool highlightLastBar,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: isIncrease ? AppTheme.primaryOrange : Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subValue,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isIncrease ? AppTheme.primaryOrange : AppTheme.grayText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini Bar Chart
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(bars.length, (index) {
                bool isLast = index == bars.length - 1;
                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  tween: Tween<double>(begin: 0.0, end: bars[index]),
                  builder: (context, val, _) {
                    return Container(
                      width: 16,
                      height: 40 * val,
                      decoration: BoxDecoration(
                        color: isLast && highlightLastBar
                            ? (highlightColor ?? AppTheme.primaryOrange)
                            : barsColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAiPredictionCoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA5B15), Color(0xFFED833A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.memory, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'AI Prediction Core',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Probability of severe weather event in the next 72 hours:',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Circular Progress Widget
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey(_riskProbability), // Re-animates when probability changes
                  tween: Tween<double>(begin: 0.0, end: _riskProbability),
                  duration: const Duration(seconds: 2),
                  curve: Curves.fastOutSlowIn,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(_riskProbability * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'RISK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
          
          // Action button to trigger the HTTP Post
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isPredicting ? null : _runPrediction,
              icon: _isPredicting 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 2))
                  : const Icon(Icons.analytics, color: AppTheme.primaryOrange, size: 18),
              label: Text(
                _isPredicting ? 'Analyzing Sensors...' : 'Run Live Prediction',
                style: const TextStyle(color: AppTheme.primaryOrange),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Wildfire Probability', style: TextStyle(color: Colors.white)),
                Text('High', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Flash Flood Index', style: TextStyle(color: Colors.white)),
                Text(_flashFloodIndex, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAlertCard({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color iconColor,
    required bool animateIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: animateIcon
                ? AnimatedBuilder(
                    animation: _alertAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _alertAnimation.value,
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.grayText, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: AppTheme.grayText.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Custom widget to add pressed state scale animations to any child widget
class _InteractiveElement extends StatefulWidget {
  final Widget child;
  const _InteractiveElement({required this.child});

  @override
  State<_InteractiveElement> createState() => _InteractiveElementState();
}

class _InteractiveElementState extends State<_InteractiveElement> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.97 : (_isHovered ? 1.01 : 1.0)),
          child: widget.child,
        ),
      ),
    );
  }
}
