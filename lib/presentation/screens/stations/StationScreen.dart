import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:revobike/presentation/screens/booking/BookingConfirmationScreen.dart';
import 'package:revobike/presentation/screens/stations/StationDetails.dart';

class StationScreen extends StatelessWidget {
  final List<Station> stations = [
    Station(
        name: "Meskel Square Station",
        location: "Meskel Square",
        availableBikes: 10,
        distance: "1.2 mi",
        rate: "\$0.5/km",
        status: "open"),
    Station(
        name: "Saris Abo Station",
        location: "Saris Abo",
        availableBikes: 8,
        distance: "2.5 mi",
        rate: "\$0.6/km",
        status: "open"),
    Station(
        name: "Tulu Dimtu Station",
        location: "Tulu Dimtu",
        availableBikes: 5,
        distance: "3.0 mi",
        rate: "\$0.4/km",
        status: "closed"),
    Station(
        name: "Shiro Meda Station",
        location: "Shiro Meda",
        availableBikes: 12,
        distance: "4.5 mi",
        rate: "\$0.6/km",
        status: "open"),
  ];

  StationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Icon(
                        station.status == "open"
                            ? FontAwesomeIcons.circleCheck
                            : FontAwesomeIcons.circleXmark,
                        color: station.status == "open" ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.locationDot, size: 16, color: Colors.blue,),
                      const SizedBox(width: 8),
                      Text(station.location, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.bicycle, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("${station.availableBikes} Bikes Available",
                          style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.route, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("${station.distance} away",
                          style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      const Spacer(),
                      const Icon(FontAwesomeIcons.dollarSign, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(station.rate, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StationDetailsScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              )
                            ),
                          ),
                          child: const Text("View", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: station.status == "open" ? () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BookingConfirmationScreen())) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: station.status == "open" ? Colors.blue : Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Book", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Station {
  final String name;
  final String location;
  final int availableBikes;
  final String distance;
  final String rate;
  final String status;

  Station({
    required this.name,
    required this.location,
    required this.availableBikes,
    required this.distance,
    required this.rate,
    required this.status,
  });
}
