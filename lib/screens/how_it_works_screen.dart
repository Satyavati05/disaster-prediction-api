import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_home.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top App Bar like area
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ClimateAI',
                      style: TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to login
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Hero Section with Image bg
            Container(
              height: 350,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.darkBlueBg, // Fallback
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1614642240262-a4441fed1de8?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'AI Climate\nForecasting\nSystem',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Predicting the future of our planet with advanced AI and satellite data.\nExperience real-time global climate monitoring and risk assessment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainHome(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Explore Dashboard',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Start Quiz', style: TextStyle(fontSize: 14)),
                      )
                    ],
                  )
                ],
              ),
            ),

            // How It Works Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Our AI analyzes vast amounts of data from satellites and global sensor networks to provide highly accurate, localized climate forecasts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grayText, fontSize: 13),
                  ),
                ],
              ),
            ),

            // The list of features
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _InfoCard(
                    icon: Icons.satellite_alt,
                    title: 'Satellite Data',
                    description: 'Continuous stream of high-resolution imagery and atmospheric data from Earth-orbiting satellites.',
                    iconColor: AppTheme.primaryOrange,
                    iconBgColor: AppTheme.primaryOrange.withOpacity(0.1),
                  ),
                  _InfoCard(
                    icon: Icons.sensors,
                    title: 'Sensor Networks',
                    description: 'Millions of ground-based oceanic and terrestrial sensors tracking micro-level environmental changes.',
                    iconColor: AppTheme.primaryOrange,
                    iconBgColor: AppTheme.primaryOrange.withOpacity(0.1),
                  ),
                  _InfoCard(
                    icon: Icons.memory,
                    title: 'AI Analysis',
                    description: 'Deep learning algorithms process petabytes of data to predict complex climate patterns with unprecedented accuracy.',
                    iconColor: AppTheme.primaryOrange,
                    iconBgColor: AppTheme.primaryOrange.withOpacity(0.1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Comparison
            const Text(
              'Traditional vs AI\nForecasting',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Discover why AI brings a new paradigm of precision and speed to long-term climate prediction models.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.grayText, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ComparisonCard(
                icon: Icons.history,
                title: 'Traditional Methods',
                isAi: false,
                points: const [
                  'Relies heavily on historical averaging',
                  'Slower processing of multi-variable data',
                  'Struggles with rapid, non-linear climate shifts',
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ComparisonCard(
                icon: Icons.auto_graph,
                title: 'AI Forecasting',
                isAi: true,
                points: const [
                  'Identifies complex, hidden patterns in raw data',
                  'Real-time processing of dynamic variables',
                  'Adapts instantly to emerging climate anomalies',
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Bottom CTA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.darkBlueBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Understand Your\nClimate Risks',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Get personalized insights into how changing climate patterns might affect your specific region, infrastructure, and local ecosystems in the coming decades.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Learn Climate Risks'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              '© 2024 ClimateAI Forecasting Systems. All rights reserved.',
              style: TextStyle(color: AppTheme.grayText, fontSize: 10),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color iconBgColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.grayText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> points;
  final bool isAi;

  const _ComparisonCard({
    required this.icon,
    required this.title,
    required this.points,
    required this.isAi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAi ? AppTheme.primaryOrange.withOpacity(0.1) : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: isAi ? Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAi ? AppTheme.primaryOrange.withOpacity(0.2) : AppTheme.inputBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isAi ? AppTheme.primaryOrange : AppTheme.grayText,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                ...points.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isAi ? Icons.check : Icons.remove,
                            size: 14,
                            color: isAi ? AppTheme.primaryOrange : AppTheme.grayText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 13,
                                color: isAi ? AppTheme.primaryOrange : AppTheme.grayText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
