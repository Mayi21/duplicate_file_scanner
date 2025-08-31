import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate File Scanner'**
  String get appTitle;

  /// No description provided for @selectDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select Directory'**
  String get selectDirectory;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @hash.
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get hash;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @bytes.
  ///
  /// In en, this message translates to:
  /// **'bytes'**
  String get bytes;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteFile.
  ///
  /// In en, this message translates to:
  /// **'Delete File?'**
  String get deleteFile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectGroupOrFile.
  ///
  /// In en, this message translates to:
  /// **'Select a group or file to preview'**
  String get selectGroupOrFile;

  /// No description provided for @noPreviewAvailable.
  ///
  /// In en, this message translates to:
  /// **'No preview available for this file type'**
  String get noPreviewAvailable;

  /// No description provided for @errorDeletingFile.
  ///
  /// In en, this message translates to:
  /// **'Error deleting file'**
  String get errorDeletingFile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @noStatistics.
  ///
  /// In en, this message translates to:
  /// **'No statistics available. Please run a scan first.'**
  String get noStatistics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @duplicateGroups.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Groups'**
  String get duplicateGroups;

  /// No description provided for @duplicateFiles.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Files'**
  String get duplicateFiles;

  /// No description provided for @wastedSpace.
  ///
  /// In en, this message translates to:
  /// **'Wasted Space'**
  String get wastedSpace;

  /// No description provided for @selectedFiles.
  ///
  /// In en, this message translates to:
  /// **'Selected Files'**
  String get selectedFiles;

  /// No description provided for @fileTypeDistribution.
  ///
  /// In en, this message translates to:
  /// **'File Type Distribution'**
  String get fileTypeDistribution;

  /// No description provided for @sizeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Size Distribution'**
  String get sizeDistribution;

  /// No description provided for @topDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Top Duplicates'**
  String get topDuplicates;

  /// No description provided for @largestDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Largest Duplicate'**
  String get largestDuplicate;

  /// No description provided for @mostDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Most Duplicated'**
  String get mostDuplicated;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get files;

  /// No description provided for @copies.
  ///
  /// In en, this message translates to:
  /// **'copies'**
  String get copies;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @moveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get moveToTrash;

  /// No description provided for @pauseScan.
  ///
  /// In en, this message translates to:
  /// **'Pause Scan'**
  String get pauseScan;

  /// No description provided for @resumeScan.
  ///
  /// In en, this message translates to:
  /// **'Resume Scan'**
  String get resumeScan;

  /// No description provided for @stopScan.
  ///
  /// In en, this message translates to:
  /// **'Stop Scan'**
  String get stopScan;

  /// No description provided for @filesScanned.
  ///
  /// In en, this message translates to:
  /// **'Files Scanned'**
  String get filesScanned;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get estimatedTime;

  /// No description provided for @scanSpeed.
  ///
  /// In en, this message translates to:
  /// **'Scan Speed'**
  String get scanSpeed;

  /// No description provided for @filesPerSecond.
  ///
  /// In en, this message translates to:
  /// **'files/sec'**
  String get filesPerSecond;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining Time'**
  String get remainingTime;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @keepNewest.
  ///
  /// In en, this message translates to:
  /// **'Keep Newest'**
  String get keepNewest;

  /// No description provided for @keepOldest.
  ///
  /// In en, this message translates to:
  /// **'Keep Oldest'**
  String get keepOldest;

  /// No description provided for @comparing.
  ///
  /// In en, this message translates to:
  /// **'Comparing'**
  String get comparing;

  /// No description provided for @showInFinder.
  ///
  /// In en, this message translates to:
  /// **'Show in Finder'**
  String get showInFinder;

  /// No description provided for @keepThis.
  ///
  /// In en, this message translates to:
  /// **'Keep This'**
  String get keepThis;

  /// No description provided for @smartTruncation.
  ///
  /// In en, this message translates to:
  /// **'Smart file name truncation'**
  String get smartTruncation;

  /// No description provided for @thumbnailPreview.
  ///
  /// In en, this message translates to:
  /// **'Thumbnail Preview'**
  String get thumbnailPreview;

  /// No description provided for @fileDetails.
  ///
  /// In en, this message translates to:
  /// **'File Details'**
  String get fileDetails;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full Screen'**
  String get fullScreen;

  /// No description provided for @exitFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Exit Full Screen'**
  String get exitFullScreen;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @comparisonView.
  ///
  /// In en, this message translates to:
  /// **'Comparison View'**
  String get comparisonView;

  /// No description provided for @exitComparison.
  ///
  /// In en, this message translates to:
  /// **'Exit Comparison'**
  String get exitComparison;

  /// No description provided for @comparisonMode.
  ///
  /// In en, this message translates to:
  /// **'Comparison Mode'**
  String get comparisonMode;

  /// No description provided for @compareFiles.
  ///
  /// In en, this message translates to:
  /// **'Compare Files'**
  String get compareFiles;

  /// No description provided for @noDuplicatesFound.
  ///
  /// In en, this message translates to:
  /// **'No duplicates found'**
  String get noDuplicatesFound;

  /// No description provided for @selectDirectoryAndScan.
  ///
  /// In en, this message translates to:
  /// **'Please select a directory and start scanning.'**
  String get selectDirectoryAndScan;

  /// No description provided for @comparisonGroupNotFound.
  ///
  /// In en, this message translates to:
  /// **'Comparison group not found'**
  String get comparisonGroupNotFound;

  /// No description provided for @backToList.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get backToList;

  /// No description provided for @selectAFileToPreview.
  ///
  /// In en, this message translates to:
  /// **'Select a file to preview'**
  String get selectAFileToPreview;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'⚠️ This action cannot be undone!'**
  String get actionCannotBeUndone;

  /// No description provided for @restoreFromTrash.
  ///
  /// In en, this message translates to:
  /// **'You can restore them from trash later.'**
  String get restoreFromTrash;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete {count} files?'**
  String deleteConfirmation(int count);

  /// No description provided for @filesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} files have been deleted.'**
  String filesDeleted(int count);

  /// No description provided for @moveFilesToTrashConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to move {count} files to trash?'**
  String moveFilesToTrashConfirmation(int count);

  /// No description provided for @filesMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count} files have been moved to trash.'**
  String filesMovedToTrash(int count);

  /// No description provided for @permissionErrorMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied. To fix this, go to System Settings > Privacy & Security > Automation, find \'Duplicate File Scanner\', and enable \'Finder\'.'**
  String get permissionErrorMoveToTrash;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
