// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Duplicate File Scanner';

  @override
  String get selectDirectory => 'Select Directory';

  @override
  String get scan => 'Scan';

  @override
  String get scanning => 'Scanning...';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';
}
