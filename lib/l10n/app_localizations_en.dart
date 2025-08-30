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

  @override
  String get selected => 'Selected';

  @override
  String get progress => 'Progress';

  @override
  String get hash => 'Hash';

  @override
  String get size => 'Size';

  @override
  String get bytes => 'bytes';

  @override
  String get preview => 'Preview';

  @override
  String get delete => 'Delete';

  @override
  String get deleteFile => 'Delete File?';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to permanently delete this file?';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectGroupOrFile => 'Select a group or file to preview';

  @override
  String get noPreviewAvailable => 'No preview available for this file type';

  @override
  String get errorDeletingFile => 'Error deleting file';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';
}
