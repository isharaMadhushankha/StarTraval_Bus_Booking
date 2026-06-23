// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'supabase_service.dart';

class EmailService {
  static Future<void> sendBookingConfirmation({
    required String userEmail,
    required String userName,
    required String busNo,
    required String route,
    required List<int> seatNumbers,
    required double totalAmount,
    required String bookingId,
  }) async {
    try {
      final apiKey = dotenv.env['RESEND_API_KEY'];

      if (apiKey == null) {
        debugPrint('❌ Resend API key not configured in .env');
        return;
      }

      final emailContent = _generateEmailHTML(
        userName: userName,
        busNo: busNo,
        route: route,
        seatNumbers: seatNumbers,
        totalAmount: totalAmount,
        bookingId: bookingId,
      );

      // Send via Resend API
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': 'StartTraval <onboarding@resend.dev>',
          'to': userEmail,
          'subject': 'Booking Confirmation - $bookingId',
          'html': emailContent,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Email sent successfully via Resend');
        await _saveEmailLog(userEmail, bookingId, true);
      } else {
        debugPrint('❌ Resend error: ${response.body}');
        await _saveEmailLog(userEmail, bookingId, false, error: response.body);
      }
    } catch (e) {
      debugPrint('❌ Error sending email: $e');
      await _saveEmailLog(userEmail, bookingId, false, error: e.toString());
    }
  }

  static String _generateEmailHTML({
    required String userName,
    required String busNo,
    required String route,
    required List<int> seatNumbers,
    required double totalAmount,
    required String bookingId,
  }) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 20px auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #1abc9c 0%, #16a085 100%); color: white; text-align: center; margin: -20px -20px 20px -20px; padding: 30px; border-radius: 8px 8px 0 0; }
        .header h1 { margin: 0; font-size: 28px; }
        .header p { margin: 10px 0 0 0; opacity: 0.9; }
        .details { background: #f9f9f9; padding: 15px; border-radius: 5px; margin: 15px 0; border-left: 4px solid #1abc9c; }
        .detail-row { display: flex; justify-content: space-between; margin: 12px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
        .detail-row:last-child { border-bottom: none; }
        .label { font-weight: bold; color: #333; }
        .value { color: #666; text-align: right; }
        .total-row { display: flex; justify-content: space-between; margin-top: 10px; padding-top: 10px; border-top: 2px solid #1abc9c; }
        .total-label { font-size: 16px; font-weight: bold; color: #1abc9c; }
        .total-value { font-size: 20px; color: #1abc9c; font-weight: bold; }
        .footer { text-align: center; color: #999; font-size: 12px; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; }
        .success-badge { display: inline-block; background: #27ae60; color: white; padding: 8px 16px; border-radius: 20px; margin-bottom: 15px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🚌 StartTraval</h1>
          <p>Booking Confirmation</p>
        </div>
        
        <div style="text-align: center; margin-bottom: 20px;">
          <span class="success-badge">✓ Booking Confirmed</span>
        </div>
        
        <p>Dear $userName,</p>
        <p>Thank you for booking with StartTraval! Your booking has been confirmed and your seat is reserved. Here are your booking details:</p>
        
        <div class="details">
          <div class="detail-row">
            <span class="label">Booking Reference:</span>
            <span class="value" style="font-family: monospace; font-weight: bold;">$bookingId</span>
          </div>
          <div class="detail-row">
            <span class="label">Bus Number:</span>
            <span class="value">$busNo</span>
          </div>
          <div class="detail-row">
            <span class="label">Route:</span>
            <span class="value">$route</span>
          </div>
          <div class="detail-row">
            <span class="label">Seat Number(s):</span>
            <span class="value">${seatNumbers.join(', ')}</span>
          </div>
          <div class="detail-row">
            <span class="label">Number of Seats:</span>
            <span class="value">${seatNumbers.length}</span>
          </div>
          <div class="total-row">
            <span class="total-label">Total Amount Paid:</span>
            <span class="total-value">₹${totalAmount.toStringAsFixed(2)}</span>
          </div>
        </div>
        
        <p style="background: #e8f5e9; padding: 15px; border-radius: 5px; color: #27ae60;">
          <strong>✓ Payment Status:</strong> Completed<br>
          <strong>✓ Booking Status:</strong> Confirmed
        </p>
        
        <p><strong>What's Next?</strong></p>
        <ul>
          <li>Keep this email for reference</li>
          <li>Present your booking reference at the bus counter</li>
          <li>Arrive 15 minutes before departure time</li>
          <li>Safe travels! 🎉</li>
        </ul>
        
        <div class="footer">
          <p>© 2025 StartTraval Bus Booking. All rights reserved.</p>
          <p>This is an automated email. Please do not reply directly to this message.</p>
        </div>
      </div>
    </body>
    </html>
    ''';
  }

  static Future<void> _saveEmailLog(
    String email,
    String bookingId,
    bool success, {
    String? error,
  }) async {
    try {
      await SupabaseService.client.from('email_logs').insert({
        'email': email,
        'booking_id': bookingId,
        'subject': 'Booking Confirmation - $bookingId',
        'success': success,
        'error_message': error,
        'sent_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error saving email log: $e');
    }
  }
}
