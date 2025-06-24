import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  /// Mappe les codes de langue vers les codes de locale appropriés
  /// avec gestion des formats de date régionaux
  static String _getLocaleCode(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'fr_FR'; // Format: dd/MM/yyyy
      case 'en':
        return 'en_US'; // Format: MM/dd/yyyy
      case 'de':
        return 'de_DE'; // Format: dd.MM.yyyy
      case 'es':
        return 'es_ES'; // Format: dd/MM/yyyy
      case 'it':
        return 'it_IT'; // Format: dd/MM/yyyy
      case 'nl':
        return 'nl_NL'; // Format: dd-MM-yyyy
      default:
        return 'en_US'; // Fallback par défaut
    }
  }

  /// Formate une date selon la langue de l'application
  /// Format: "E d MMM" (ex: "lun 15 jan" / "Mon Jan 15")
  static String formatShortDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('E d MMM', localeCode).format(date);
  }

  /// Formate une date avec l'heure selon la langue
  /// Format: "E d MMM, HH:mm" (ex: "lun 15 jan, 14:30" / "Mon Jan 15, 2:30 PM")
  static String formatShortDateTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('E d MMM, HH:mm', localeCode).format(date);
  }

  /// Formate une date complète selon la langue
  /// Format: "EEEE d MMMM yyyy" (ex: "lundi 15 janvier 2024" / "Monday January 15, 2024")
  static String formatFullDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('EEEE d MMMM yyyy', localeCode).format(date);
  }

  /// Formate une date avec l'heure complète selon la langue
  /// Format: "EEEE d MMMM yyyy HH:mm" (ex: "lundi 15 janvier 2024 14:30" / "Monday January 15, 2024 2:30 PM")
  static String formatFullDateTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('EEEE d MMMM yyyy HH:mm', localeCode).format(date);
  }

  /// Formate une date au format court selon la langue et la région
  /// Formats régionaux :
  /// - fr_FR, es_ES, it_IT: "dd/MM/yyyy" (ex: "15/01/2024")
  /// - en_US: "MM/dd/yyyy" (ex: "01/15/2024")
  /// - de_DE: "dd.MM.yyyy" (ex: "15.01.2024")
  /// - nl_NL: "dd-MM-yyyy" (ex: "15-01-2024")
  static String formatShortDateOnly(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);

    // Utilise le format approprié selon la région
    String formatPattern;
    switch (localeCode) {
      case 'en_US':
        formatPattern = 'MM/dd/yyyy'; // Format américain
        break;
      case 'de_DE':
        formatPattern = 'dd.MM.yyyy'; // Format allemand
        break;
      case 'nl_NL':
        formatPattern = 'dd-MM-yyyy'; // Format néerlandais
        break;
      case 'fr_FR':
      case 'es_ES':
      case 'it_IT':
      default:
        formatPattern = 'dd/MM/yyyy'; // Format européen standard
        break;
    }

    return DateFormat(formatPattern, localeCode).format(date);
  }

  /// Formate une heure selon la langue
  /// Format: "HH:mm" (format 24h pour la plupart des pays européens)
  /// ou "h:mm a" (format 12h pour les États-Unis)
  static String formatTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);

    // Format 12h pour les États-Unis, 24h pour les autres
    final formatPattern = localeCode == 'en_US' ? 'h:mm a' : 'HH:mm';
    return DateFormat(formatPattern, localeCode).format(date);
  }

  /// Formate une date avec l'heure selon la langue et la région
  /// Combine formatShortDateOnly et formatTime
  static String formatShortDateWithTime(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);

    String datePattern;
    switch (localeCode) {
      case 'en_US':
        datePattern = 'MM/dd/yyyy h:mm a'; // Format américain
        break;
      case 'de_DE':
        datePattern = 'dd.MM.yyyy HH:mm'; // Format allemand
        break;
      case 'nl_NL':
        datePattern = 'dd-MM-yyyy HH:mm'; // Format néerlandais
        break;
      case 'fr_FR':
      case 'es_ES':
      case 'it_IT':
      default:
        datePattern = 'dd/MM/yyyy HH:mm'; // Format européen standard
        break;
    }

    return DateFormat(datePattern, localeCode).format(date);
  }

  /// Retourne le nom du mois selon la langue
  /// Format: "janvier" / "January"
  static String formatMonth(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('MMMM', localeCode).format(date);
  }

  /// Retourne le nom du jour selon la langue
  /// Format: "lundi" / "Monday"
  static String formatDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('EEEE', localeCode).format(date);
  }

  /// Retourne le nom du jour court selon la langue
  /// Format: "lun" / "Mon"
  static String formatShortDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    final localeCode = _getLocaleCode(locale);
    return DateFormat('E', localeCode).format(date);
  }
}
