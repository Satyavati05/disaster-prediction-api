import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/notification_service.dart';

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});

  @override
  State<DisasterScreen> createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Severity colour helper ────────────────────────────────────────────────
  Color getColor(String severity) {
    severity = severity.toLowerCase();
    if (severity == 'high' || severity == 'extreme') return Colors.red;
    if (severity == 'medium' || severity == 'moderate') return Colors.orange;
    return Colors.green;
  }

  Future<List> fetchEarthquakes() async {
    try {
      final response = await http.get(
        Uri.parse("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['features'];
      }
    } catch (e) {
      debugPrint("Error fetching earthquakes: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Hub'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Local Alerts', icon: Icon(Icons.notifications_active)),
            Tab(text: 'Global Earthquakes', icon: Icon(Icons.public)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocalAlerts(),
          _buildEarthquakeFeed(),
        ],
      ),
    );
  }

  Widget _buildLocalAlerts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('disasters')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No local alerts at this time.'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String severity = (data['severity'] as String? ?? 'low').toLowerCase();
            final Color severityColor = getColor(severity);

            return _buildAlertCard(
              title: data['type'] ?? 'Unknown Alert',
              subtitle: data['location'] ?? 'Global',
              severity: severity,
              severityColor: severityColor,
              time: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(11, 16) : 'Now',
            );
          },
        );
      },
    );
  }

  Widget _buildEarthquakeFeed() {
    return FutureBuilder<List>(
      future: fetchEarthquakes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // SHOW ONLY STRONG EARTHQUAKES (>= 4.5)
        var quakes = snapshot.data!.where((q) {
          double magnitude = (q['properties']['mag'] as num).toDouble();
          return magnitude >= 4.5;
        }).toList();

        return ListView.builder(
          itemCount: quakes.length,
          itemBuilder: (context, index) {
            var quake = quakes[index];
            double magnitude = (quake['properties']['mag'] as num).toDouble();
            String place = quake['properties']['place'] ?? 'Unknown Location';

            // TRIGGER MAJOR ALERT SYSTEM (>= 5.5)
            if (magnitude >= 5.5) {
              NotificationService.showLocalAlert(
                "🌍 Earthquake Alert",
                "Magnitude $magnitude detected at $place",
              );
            }

            return ListTile(
              title: Text(place),
              subtitle: Text("Magnitude: $magnitude"),
              leading: const Icon(Icons.terrain, color: Colors.red),
            );
          },
        );
      },
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String subtitle,
    required String severity,
    required Color severityColor,
    required String time,
    bool isUSGS = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor.withOpacity(0.4), width: 1.2),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUSGS ? Icons.terrain_outlined : Icons.warning_amber_rounded,
            color: severityColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 2),
            Text(
              'Detected at $time',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.12),
            border: Border.all(color: severityColor, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            severity.toUpperCase(),
            style: TextStyle(
              color: severityColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
