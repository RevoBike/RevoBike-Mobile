import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecentTripsScreen extends StatefulWidget {
  const RecentTripsScreen({super.key});

  @override
  State<RecentTripsScreen> createState() => _RecentTripsScreenState();
}

class _RecentTripsScreenState extends State<RecentTripsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text("Recent Trips", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _sectionTitle("Unfinished Rides"),
            _rideCard("Saris Abo Station", "In Progress", "10 min", "Br. 150", isActive: true),

            const SizedBox(height: 16),
            _sectionTitle("Recent Bookings"),
            _rideCard("Bole Avenue", "Completed", "45 min", "Br. 350"),
            _rideCard("Piassa Central", "Completed", "30 min", "Br. 250"),

            const SizedBox(height: 16),
            _sectionTitle("Previous Trips"),
            _rideCard("Mexico Square", "Completed", "20 min", "Br. 180"),
            _rideCard("CMC Area", "Completed", "55 min", "Br. 400"),
            const SizedBox(height: 64),
          ],
        ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  Widget _rideCard(String location, String status, String duration, String fare, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 14, color: isActive ? Colors.red : Colors.blue)),
                Text("$duration - $fare", style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
            isActive
                ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text("Finish Ride"),
            )
                : const Icon(FontAwesomeIcons.circleCheck, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}

class Trip {
  final String name;
  Trip({required this.name});
}