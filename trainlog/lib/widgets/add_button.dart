import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../screens/add_trip_screen_v3.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.train,
          size: 32,
          color: AppColors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTripScreenV3(),
            ),
          );
        },
      ),
    );
  }
}
