import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:revobike/api/chapa_service.dart';
import 'package:revobike/api/auth_service.dart';
import 'package:revobike/data/models/User.dart';
import 'package:revobike/presentation/screens/booking/paymentFeedbackScreen.dart'; // NEW: Import feedback screen

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> rideDetails;

  const PaymentScreen({super.key, required this.rideDetails});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoadingPayment = false;
  String? _paymentErrorMessage;
  final ChapaService _chapaService = ChapaService();
  final AuthService _authService = AuthService();

  @override

  // Chapa payment initiation logic
  void _payWithChapa() async {
    setState(() {
      _isLoadingPayment = true;
      _paymentErrorMessage = null;
    });

    try {
      final String? rideId = widget.rideDetails['_id'] as String?;
      if (rideId == null) {
        throw Exception('Ride ID is missing for payment.');
      }

      print('Initiating payment with rideId: $rideId');

      // Call your backend to initiate payment with rideId
      final String checkoutUrl =
          await _chapaService.initiatePayment(rideId: rideId);

      print('Received checkoutUrl: $checkoutUrl');

      // Generate a txRef from the checkoutUrl or use a UUID if needed
      final String txRef = Uri.parse(checkoutUrl).queryParameters['tx_ref'] ??
          'revobike-${const Uuid().v4()}';

      // Launch the Chapa checkout URL in a WebView
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _ChapaWebViewScreen(
            checkoutUrl: checkoutUrl,
            txRef: txRef,
            onPaymentComplete: (bool success) {
              if (mounted) {
                // After payment is complete (or cancelled), navigate to feedback screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentFeedbackScreen(
                      isSuccess: success,
                      rideDetails: widget
                          .rideDetails, // Pass ride details to feedback screen
                    ),
                  ),
                );
              }
            },
            chapaService: _chapaService, // Pass ChapaService for verification
          ),
        ),
      );
    } catch (e) {
      print('Exception caught in _payWithChapa: $e');
      if (mounted) {
        setState(() {
          _paymentErrorMessage = 'Payment failed: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment initiation failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract details from the rideDetails map
    final double? totalCost =
        (widget.rideDetails['totalCost'] as num?)?.toDouble();
    final double? distance =
        (widget.rideDetails['distance'] as num?)?.toDouble();
    final String? bikeId = widget.rideDetails['bikeId'] as String?;
    final String? startTime = widget.rideDetails['startTime'] as String?;
    final String? endTime = widget.rideDetails['endTime'] as String?;

    // Optional: Format start and end times for display
    String formattedStartTime = 'N/A';
    String formattedEndTime = 'N/A';
    if (startTime != null) {
      try {
        final DateTime startDt = DateTime.parse(startTime);
        formattedStartTime =
            '${startDt.hour}:${startDt.minute.toString().padLeft(2, '0')} ${startDt.day}/${startDt.month}';
      } catch (e) {
        print('Error parsing start time: $e');
      }
    }
    if (endTime != null) {
      try {
        final DateTime endDt = DateTime.parse(endTime);
        formattedEndTime =
            '${endDt.hour}:${endDt.minute.toString().padLeft(2, '0')} ${endDt.day}/${endDt.month}';
      } catch (e) {
        print('Error parsing end time: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    _buildSummaryRow("Bike ID:", bikeId ?? 'N/A'),
                    _buildSummaryRow("Distance Traveled:",
                        "${distance?.toStringAsFixed(2) ?? 'N/A'} km"),
                    _buildSummaryRow("Start Time:", formattedStartTime),
                    _buildSummaryRow("End Time:", formattedEndTime),
                    const Divider(height: 20, thickness: 1),
                    _buildSummaryRow("Total Cost:",
                        "Br.${totalCost?.toStringAsFixed(2) ?? 'N/A'}",
                        isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Choose Payment Method",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoadingPayment ? null : _payWithChapa,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoadingPayment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Pay with Chapa",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            if (_paymentErrorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _paymentErrorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black87 : Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// A dedicated WebView screen for Chapa checkout
class _ChapaWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String txRef;
  final Function(bool) onPaymentComplete;
  final ChapaService chapaService; // Pass ChapaService for verification

  const _ChapaWebViewScreen({
    required this.checkoutUrl,
    required this.txRef,
    required this.onPaymentComplete,
    required this.chapaService,
  });

  @override
  State<_ChapaWebViewScreen> createState() => _ChapaWebViewScreenState();
}

class _ChapaWebViewScreenState extends State<_ChapaWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoadingWebView = true;
  bool _paymentHandled = false; // Changed from _paymentSuccessHandled

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if (progress == 100) {
              setState(() {
                _isLoadingWebView = false;
              });
            } else if (progress < 100) {
              setState(() {
                _isLoadingWebView = true;
              });
            }
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
            setState(() {
              _isLoadingWebView = true;
            });
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            setState(() {
              _isLoadingWebView = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
            if (mounted && !_paymentHandled) {
              // Ensure not already handled
              _paymentHandled = true;
              Navigator.of(context).pop(); // Pop the WebView
              widget.onPaymentComplete(false); // Notify failure
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // This is crucial for handling redirects from Chapa.
            // Chapa redirects to your return_url after payment.
            // We'll check if the URL contains keywords for success/failure
            // or if it matches your specified return_url.

            print('Navigating to: ${request.url}');

            // IMPORTANT: Adjust this URL to match your return_url EXACTLY
            // from the initializePayment call.
            // For this example, we used: 'https://revobike-web-3.onrender.com/payment-status?tx_ref=$txRef'
            // Ensure the domain and path are correct.
            if (request.url
                    .contains('revobike-web-3.onrender.com/payment-status') &&
                request.url.contains('tx_ref=${widget.txRef}')) {
              // This is a potential callback URL. Now verify the payment with your backend.
              _verifyPaymentStatus(request.url);
              return NavigationDecision
                  .prevent; // Prevent WebView from loading this URL further
            }

            // Fallback: You might also look for "success", "failure", "cancelled" in the URL
            // This is less reliable than verifying with your backend, but can be a quick indicator.
            if (request.url.contains('success=true') && !_paymentHandled) {
              _paymentHandled = true; // Prevent double handling
              widget.onPaymentComplete(true);
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            } else if ((request.url.contains('status=failed') ||
                    request.url.contains('status=cancelled')) &&
                !_paymentHandled) {
              _paymentHandled = true; // Prevent double handling
              widget.onPaymentComplete(false);
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate; // Allow other navigation
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  // Function to verify payment status with your backend after Chapa redirects
  void _verifyPaymentStatus(String redirectUrl) async {
    if (_paymentHandled) return; // Prevent double handling

    setState(() {
      _isLoadingWebView = true; // Show loading while verifying
    });

    try {
      // It's safer to have your backend call Chapa's verify endpoint
      // and for your Flutter app to just call your backend.
      final Map<String, dynamic> verificationResult =
          await widget.chapaService.verifyPayment(widget.txRef);

      if (mounted) {
        if (verificationResult['status'] == 'success') {
          _paymentHandled = true;
          widget.onPaymentComplete(true);
        } else {
          _paymentHandled = true;
          widget.onPaymentComplete(false);
        }
        Navigator.of(context).pop(); // Close WebView
      }
    } catch (e) {
      if (mounted) {
        print('Payment verification error: $e');
        _paymentHandled = true;
        widget.onPaymentComplete(false);
        Navigator.of(context).pop(); // Close WebView even on error
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWebView = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        // Add a leading back button to close the WebView if needed
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (mounted && !_paymentHandled) {
              // Only allow closing if not already handled
              _paymentHandled = true; // Mark as handled (cancelled)
              widget.onPaymentComplete(false); // Consider this a cancellation
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoadingWebView)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
