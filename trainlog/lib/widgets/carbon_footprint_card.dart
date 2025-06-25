import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../services/carbon_footprint_service.dart';
import '../theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CarbonFootprintCard extends StatelessWidget {
  final double distanceKm;

  const CarbonFootprintCard({
    super.key,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Calculer l'impact carbone
    final emissions =
        CarbonFootprintService.calculateCarbonFootprint(distanceKm);
    final trainEmissions = emissions['train']!;
    final carEmissions = emissions['car']!;
    final planeEmissions = emissions['plane']!;

    // Calculer les économies
    final carSavings = CarbonFootprintService.calculateCarSavings(
        trainEmissions, carEmissions);
    final planeSavings = CarbonFootprintService.calculatePlaneSavings(
        trainEmissions, planeEmissions);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.carbonFootprintTitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Émissions par mode de transport
            Row(
              children: [
                Expanded(
                  child: _buildEmissionItem(
                    context,
                    l10n.trainEmissions,
                    CarbonFootprintService.formatEmissions(trainEmissions),
                    Icons.train,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEmissionItem(
                    context,
                    l10n.carEmissions,
                    CarbonFootprintService.formatEmissions(carEmissions),
                    Icons.directions_car,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEmissionItem(
                    context,
                    l10n.planeEmissions,
                    CarbonFootprintService.formatEmissions(planeEmissions),
                    Icons.flight,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Économies CO2
            if (carSavings > 1000 || planeSavings > 1000) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.carbonSavings,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSavingsText(carSavings, planeSavings),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.moderateImpact,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmissionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSavingsText(double carSavings, double planeSavings) {
    if (carSavings > planeSavings && carSavings > 1000) {
      return '${CarbonFootprintService.formatSavings(carSavings)} vs voiture';
    } else if (planeSavings > 1000) {
      return '${CarbonFootprintService.formatSavings(planeSavings)} vs avion';
    } else {
      return 'Impact réduit';
    }
  }
}
