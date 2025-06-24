class CarbonFootprintService {
  // Facteurs d'émission en gCO2e par km par passager
  // Sources : ADEME, Base Carbone
  static const Map<String, double> _emissionFactors = {
    'train': 2.0, // TGV/TER en France (moyenne)
    'car': 170.0, // Voiture particulière (moyenne)
    'plane': 255.0, // Avion court-courrier
  };

  /// Calcule l'impact carbone pour un trajet donné
  static Map<String, double> calculateCarbonFootprint(double distanceKm) {
    return {
      'train': distanceKm * _emissionFactors['train']!,
      'car': distanceKm * _emissionFactors['car']!,
      'plane': distanceKm * _emissionFactors['plane']!,
    };
  }

  /// Calcule les économies de CO2 par rapport à la voiture
  static double calculateCarSavings(
      double trainEmissions, double carEmissions) {
    return carEmissions - trainEmissions;
  }

  /// Calcule les économies de CO2 par rapport à l'avion
  static double calculatePlaneSavings(
      double trainEmissions, double planeEmissions) {
    return planeEmissions - trainEmissions;
  }

  /// Formate les émissions en kg CO2e
  static String formatEmissions(double emissions) {
    if (emissions >= 1000) {
      return '${(emissions / 1000).toStringAsFixed(1)} kg CO₂e';
    } else {
      return '${emissions.toStringAsFixed(0)} g CO₂e';
    }
  }

  /// Formate les économies en kg CO2e
  static String formatSavings(double savings) {
    if (savings >= 1000) {
      return '${(savings / 1000).toStringAsFixed(1)} kg CO₂e';
    } else {
      return '${savings.toStringAsFixed(0)} g CO₂e';
    }
  }

  /// Retourne une description de l'impact
  static String getImpactDescription(
      double trainEmissions, double carEmissions, double planeEmissions) {
    final carSavings = calculateCarSavings(trainEmissions, carEmissions);
    final planeSavings = calculatePlaneSavings(trainEmissions, planeEmissions);

    if (carSavings > 1000) {
      return 'Vous économisez ${formatSavings(carSavings)} par rapport à la voiture';
    } else if (planeSavings > 1000) {
      return 'Vous économisez ${formatSavings(planeSavings)} par rapport à l\'avion';
    } else {
      return 'Impact carbone modéré pour ce trajet';
    }
  }
}
