import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildItem('Available', AppColors.available),
        _buildItem('Selecting', AppColors.warning),
        _buildItem('Booked', AppColors.booked),
      ],
    );
  }

  Widget _buildItem(String label, Color color) {
    return Row(
      children: [
        Icon(
          Icons.chair,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFF5F5F5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
