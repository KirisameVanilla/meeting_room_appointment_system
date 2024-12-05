import 'package:flutter/material.dart';

class TimeSlotWidget extends StatelessWidget {
  final String timeSlot;
  final bool isBooked;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCancelMode;
  final String? occupiedBy;

  TimeSlotWidget({
    required this.timeSlot,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
    required this.isCancelMode,
    required this.occupiedBy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isBooked
              ? (isCancelMode
                  ? (isSelected ? Colors.purple : Colors.orange)
                  : Colors.red)
              : (isSelected ? Colors.blue : Colors.green),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            occupiedBy != '' ? '$timeSlot\nOccupied by$occupiedBy' : timeSlot,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
