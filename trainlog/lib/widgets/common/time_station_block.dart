import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trainlog/theme/typography.dart';
import '../../theme/colors.dart';
import 'marquee_text.dart';

class TimeStationBlock extends StatelessWidget {
  final DateTime time;
  final String station;

  const TimeStationBlock({
    super.key,
    required this.time,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          DateFormat('HH:mm').format(time),
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const Text(' '),
        Expanded(
          child: MarqueeText(
            text: station,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
            maxLength: 0, // Force l'effet marquee pour tous les textes
          ),
        ),
      ],
    );
  }
}
