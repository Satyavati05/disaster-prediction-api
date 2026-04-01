import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrayBg,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryOrange,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jane Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'jane.doe@climate.ai',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryOrange),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'General',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Push Notifications',
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                ),
                _buildDivider(),
                _buildSwitchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location Services',
                  value: _locationEnabled,
                  onChanged: (val) {
                    setState(() => _locationEnabled = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildActionTile(icon: Icons.language, title: 'Language', subtitle: 'English'),
                _buildDivider(),
                _buildActionTile(icon: Icons.thermostat, title: 'Temperature Unit', subtitle: 'Celsius (°C)'),
                _buildDivider(),
                _buildActionTile(icon: Icons.speed, title: 'Wind Speed Unit', subtitle: 'km/h'),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              children: [
                _buildActionTile(icon: Icons.help_outline, title: 'Help Center'),
                _buildDivider(),
                _buildActionTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
                _buildDivider(),
                _buildActionTile(icon: Icons.info_outline, title: 'About Climate AI'),
              ],
            ),
            const SizedBox(height: 32),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Logout logic here
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.darkText, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.primaryOrange,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.darkText, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.grayText,
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: AppTheme.grayText),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 56, // aligns with text
    );
  }
}
