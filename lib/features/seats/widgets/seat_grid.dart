import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/seat_model.dart';
import '../providers/seat_provider.dart';
import 'seat_tile.dart';

import '../../../core/constants/app_colors.dart';

class SeatGrid extends StatelessWidget {
  final List<SeatModel> seats;

  const SeatGrid({super.key, required this.seats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We define a fixed 13-row layout:
        // Row 0: Driver row (Driver at Column 5)
        // Rows 1..11: Normal rows (4 seats per row: 2 seats, 2-column aisle, 2 seats)
        // Row 12: Back row (6 seats side-by-side, no aisle)
        const int crossAxisCount = 6;
        const int rowCount = 13; 

        // Horizontal padding is 40 on each side (80 total)
        // Vertical padding is 10 on each side (20 total)
        double horizontalPadding = 40.0 * 2.0;
        double verticalPadding = 10.0 * 2.0;

        double w = constraints.maxWidth - horizontalPadding;
        double h = constraints.maxHeight - verticalPadding;

        double crossAxisSpacing = 8.0;
        double mainAxisSpacing = 8.0;

        // Calculate size of a single cell
        double cellW = (w - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
        double cellH = (h - (rowCount - 1) * mainAxisSpacing) / rowCount;

        double aspectRatio = cellW / cellH;

        if (aspectRatio <= 0 || aspectRatio.isInfinite || aspectRatio.isNaN) {
          aspectRatio = 1.0;
        }

        const int totalItems = rowCount * crossAxisCount; // 13 * 6 = 78 items

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling completely
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            int row = index ~/ crossAxisCount;
            int col = index % crossAxisCount;

            // Row 0 is the driver row
            if (row == 0) {
              if (col == 5) {
                // Driver sits on the right side of the bus
                return const _DriverSeat();
              }
              return const SizedBox();
            }

            // Rows 1 to 11: Normal passenger rows (4 seats each: 2 left, 2 aisle, 2 right)
            if (row >= 1 && row <= 11) {
              // Columns 2 and 3 represent the aisle
              if (col == 2 || col == 3) {
                return const SizedBox();
              }

              // Calculate index in the passenger seats list (0 to 43)
              int colIdx = col < 2 ? col : col - 2;
              int seatIdx = (row - 1) * 4 + colIdx;

              if (seatIdx >= seats.length) return const SizedBox();

              final seat = seats[seatIdx];
              return SeatTile(
                seat: seat,
                onTap: () => context.read<SeatProvider>().toggleSeatSelection(
                  seat.id, 
                  seat.status
                ),
              );
            }

            // Row 12: Last row (6 seats side-by-side)
            if (row == 12) {
              // Last row seats start at index 44 (seat number 45)
              int seatIdx = 44 + col;

              if (seatIdx >= seats.length) return const SizedBox();

              final seat = seats[seatIdx];
              return SeatTile(
                seat: seat,
                onTap: () => context.read<SeatProvider>().toggleSeatSelection(
                  seat.id, 
                  seat.status
                ),
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }
}

class _DriverSeat extends StatelessWidget {
  const _DriverSeat();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxHeight * 0.95;
        if (size > constraints.maxWidth) {
          size = constraints.maxWidth * 0.95;
        }
        double iconSize = size;

        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.chair,
              size: iconSize,
              color: AppColors.slate, // Muted slate color for driver
            ),
            Positioned(
              top: iconSize * 0.25,
              child: Icon(
                Icons.adjust, // steering wheel likeness
                size: iconSize * 0.35,
                color: Colors.white70,
              ),
            ),
          ],
        );
      },
    );
  }
}
