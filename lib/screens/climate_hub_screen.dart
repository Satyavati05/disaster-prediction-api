import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ClimateHubScreen extends StatelessWidget {
  const ClimateHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.darkText),
          onPressed: () {},
        ),
        title: const Text(
          'Climate Hub',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryOrange),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryOrange,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your Learning Journey Card
            _buildLearningJourneyCard(),
            const SizedBox(height: 24),

            // Explained Hero Card
            Container(
              constraints: const BoxConstraints(minHeight: 180),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Explained',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Understand the fundamental physics of how our\natmosphere traps heat and what it means for...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start Reading',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Disaster Preparedness
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disaster Preparedness',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                  ),
                ),
                Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              title: 'Flood Safety Protocols',
              level: 'BEGINNER',
              duration: '15 mins',
              description: 'Essential steps to take before, during, and after a flood event in urban areas.',
              imageUrl: 'https://images.unsplash.com/photo-1547683905-f686c993aae5?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              buttonText: 'Review Module',
              isCompleted: true,
              isInProgress: false,
              isLocked: false,
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              title: 'Wildfire Readiness',
              level: 'INTERMEDIATE',
              duration: '25 mins',
              description: 'Learn how to create defensible space and pack a 5-minute evacuation bag.',
              imageUrl: 'https://images.unsplash.com/photo-1599827552599-eda794bfa25e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              buttonText: 'Continue Learning',
              isCompleted: false,
              isInProgress: true,
              isLocked: false,
            ),
            const SizedBox(height: 16),
            _buildModuleCard(
              title: 'Extreme Heat & Drought',
              level: 'ADVANCED',
              duration: '40 mins',
              description: 'Understanding the "Wet Bulb" temperature and community water resilience.',
              imageUrl: 'https://images.unsplash.com/photo-1508197149814-0cc02e8b7f74?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              buttonText: 'Locked (Level 3)',
              isCompleted: false,
              isInProgress: false,
              isLocked: true,
            ),

            const SizedBox(height: 32),

            // Climate Fundamentals
            const Text(
              'Climate Fundamentals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFundamentalCard(
                    icon: Icons.thermostat,
                    title: 'Carbon Cycle',
                    desc: 'The movement of carbon between the atmosphere, oceans, and soil.',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFundamentalCard(
                    icon: Icons.water,
                    title: 'Ocean Ac...',
                    desc: 'How absorbed CO2 is changing the chemistry of our oceans.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningJourneyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Learning Journey',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '3 of 8 modules completed',
                    style: TextStyle(color: AppTheme.grayText, fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'LEVEL 2',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.375, // 3/8
              backgroundColor: AppTheme.inputBg,
              color: AppTheme.primaryOrange,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primaryOrange, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Keep going! You're in the top 15% of learners this week.",
                  style: TextStyle(
                    color: AppTheme.primaryOrange.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String level,
    required String duration,
    required String description,
    required String imageUrl,
    required String buttonText,
    required bool isCompleted,
    required bool isInProgress,
    required bool isLocked,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: isLocked
                        ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                        : null,
                  ),
                ),
              ),
              if (isCompleted)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              if (isInProgress)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'IN PROGRESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      level,
                      style: TextStyle(
                        color: isLocked ? AppTheme.grayText : AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppTheme.grayText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppTheme.grayText : AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.grayText,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLocked ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocked ? AppTheme.inputBg : AppTheme.primaryOrange,
                      foregroundColor: isLocked ? AppTheme.grayText : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFundamentalCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryOrange),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: AppTheme.grayText),
          ),
        ],
      ),
    );
  }
}
