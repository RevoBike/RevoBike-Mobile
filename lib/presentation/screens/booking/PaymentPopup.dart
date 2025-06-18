import 'package:flutter/material.dart';
import 'package:revobike/constants/app_colors.dart';

class PaymentPopup extends StatelessWidget {
  final Map<String, dynamic> rideDetails;
  final VoidCallback onPaymentSelected;

  const PaymentPopup({
    super.key,
    required this.rideDetails,
    required this.onPaymentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double? totalCost = (rideDetails['totalCost'] as num?)?.toDouble();
    final double? distance = (rideDetails['distance'] as num?)?.toDouble();
    final String? bikeId = rideDetails['bikeId'] as String?;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ride Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Bike ID:",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(bikeId ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Distance Traveled:",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          Text("${distance?.toStringAsFixed(2) ?? 'N/A'} km",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Cost:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Br.${totalCost?.toStringAsFixed(2) ?? 'N/A'}",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text("Credit Card"),
                onTap: () {
                  Navigator.of(context).pop();
                  onPaymentSelected();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credit Card payment selected.')),
                  );
                  // Implement credit card payment logic
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text("Mobile Payment"),
                onTap: () {
                  Navigator.of(context).pop();
                  onPaymentSelected();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mobile payment selected.')),
                  );
                  // Implement mobile payment logic
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.money),
                title: const Text("Cash"),
                onTap: () {
                  Navigator.of(context).pop();
                  onPaymentSelected();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cash payment selected.')),
                  );
                  // Implement cash payment logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
