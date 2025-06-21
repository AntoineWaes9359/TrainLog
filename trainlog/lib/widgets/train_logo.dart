import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TrainLogo extends StatelessWidget {
  final String trainType;
  final double size;

  const TrainLogo({
    super.key,
    required this.trainType,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    String logoPath;

    if (trainType.toUpperCase().contains('OUIGO')) {
      logoPath = 'assets/images/logo_OUIGO.svg';
    } else if (trainType.toUpperCase().contains('INOUI')) {
      logoPath = 'assets/images/logo_TGV INOUI.svg';
    } else if (trainType.toUpperCase().contains('TER')) {
      logoPath = 'assets/images/logo_TER.svg';
    } else {
      logoPath = 'assets/images/logo_SNCF.svg';
    }

    return SvgPicture.asset(
      logoPath,
      height: size,
      width: size,
    );
  }
}
