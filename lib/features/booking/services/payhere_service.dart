import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayHereService {
  static void startPayment({
    required BuildContext context,
    required double amount,
    required String bookingId,
    required Function(String) onCompleted,
    required Function(String) onError,
    required Function onDismissed,
  }) {
    Map paymentObject = {
      "sandbox": true,
      "merchant_id": dotenv.env['PAYHERE_MERCHANT_ID'] ?? "1235607", 
      "notify_url": "https://your-backend.com/payhere-notify",
      "order_id": bookingId,
      "items": "Bus Seat Booking",
      "amount": amount.toStringAsFixed(2),
      "currency": "LKR",
      "first_name": "Saman",
      "last_name": "Perera",
      "email": "samanp@gmail.com",
      "phone": "0771234567",
      "address": "No.1, Galle Road",
      "city": "Colombo",
      "country": "Sri Lanka",
      "delivery_address": "No.1, Galle Road",
      "delivery_city": "Colombo",
      "delivery_country": "Sri Lanka",
      "custom_1": "",
      "custom_2": ""
    };

    PayHere.startPayment(
      paymentObject,
      (paymentId) {
        debugPrint("Payment Completed. Payment Id: $paymentId");
        onCompleted(paymentId);
      },
      (error) {
        debugPrint("Payment Error: $error");
        onError(error);
      },
      () {
        debugPrint("Payment Dismissed");
        onDismissed();
      }
    );
  }
}
