// lib/api/api_constants.dart
class ApiConstants {
  static const String baseUrl =
      'https://backend-ge4m.onrender.com/api'; // Updated backend base URL

  // Authentication Endpoints
  static const String loginEndpoint =
      '/users/login'; // Confirm your actual auth paths
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';
  static const String verifyOtpEndpoint = '/users/verify-otp';
  // Station Endpoints
  static const String stationsEndpoint =
      '/stations'; // Endpoint to get all stations
  static const String stationListEndpoint =
      '/stations/stationList'; // Alternative if you prefer this one for all stations
  static const String stationDetailsEndpoint =
      '/stations/'; // Base for /stations/:id

  // Ride Endpoints
  static const String startRideEndpoint =
      '/rides/start'; // To start a ride: /rides/start/{id} (where {id} is bikeId)
  static const String endRideEndpoint =
      '/rides/end'; // To end a ride: /rides/end/{rideId}
  static const String rideHistoryEndpoint =
      '/rides/history'; // To get ride history
  static const String chapaInitializePaymentEndpoint =
      '/chapa/initialize-payment'; // Your backend endpoint to initialize Chapa
  static const String chapaVerifyPaymentEndpoint =
      '/chapa/verify-payment'; // Your backend endpoint to verify Chapa transaction (optional for client-side call)
}
