// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/models/seat_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/supabase_service.dart';

class SeatTile extends StatelessWidget {
  final SeatModel seat;
  final VoidCallback onTap;

  const SeatTile({super.key, required this.seat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMine = seat.lastTouchedBy == SupabaseService.currentUserId;

    Color seatColor;
    if (seat.status == 'booked') {
      seatColor = AppColors.booked;
    } else if (seat.status == 'selecting') {
      seatColor = AppColors.warning;
    } else {
      seatColor = AppColors.available;
    }

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dynamic size to fit the container constraints
          double size = constraints.maxHeight * 0.95;
          if (size > constraints.maxWidth) {
            size = constraints.maxWidth * 0.95;
          }
          
          double iconSize = size;
          double fontSize = iconSize * 0.28;
          if (fontSize < 8) fontSize = 8;
          if (fontSize > 13) fontSize = 13;

          return Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isMine && seat.status == 'selecting'
                  ? Border.all(color: Colors.white, width: 1.5)
                  : Border.all(color: Colors.transparent, width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.chair,
                  size: iconSize,
                  color: seatColor,
                ),
                Positioned(
                  top: iconSize * 0.22, // Dynamically center seat number on backrest
                  child: Text(
                    seat.seatNumber.toString(),
                    style: TextStyle(
                      color: seat.status == 'available'
                          ? AppColors.brandTealDeep
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
