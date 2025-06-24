class AppConfig {
  static const String appName = 'TrainLog';
  static const String appGroupId = 'group.TrainLog.prochainTrain';
  static const String iOSWidgetName = 'ProchainTrain';
  static const String androidWidgetName = 'NewsWidget';

  // API Keys (à déplacer dans un fichier sécurisé en production)
  static const String sncfApiKey = 'your_sncf_api_key';
  static const String sncbApiKey = 'your_sncb_api_key';
  static const String trenitaliaApiKey = 'your_trenitalia_api_key';

  // URLs des APIs
  static const String sncfBaseUrl = 'https://api.sncf.com/v1';
  static const String sncbBaseUrl = 'https://api.irail.be';
  static const String trenitaliaBaseUrl = 'https://api.trenitalia.com';

  // Configuration des timeouts
  static const int connectionTimeout = 10000; // 10 secondes
  static const int receiveTimeout = 10000; // 10 secondes

  // Configuration de l'application
  static const int maxTripsToLoad = 100;
  static const int maxStationsInSearch = 10;
  static const int maxDaysInPast = 365;
  static const int maxDaysInFuture = 30;
}
