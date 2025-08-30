// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '重复文件扫描器';

  @override
  String get selectDirectory => '选择目录';

  @override
  String get scan => '扫描';

  @override
  String get scanning => '扫描中...';

  @override
  String get error => '错误';

  @override
  String get ok => '确定';
}
