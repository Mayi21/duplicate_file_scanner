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

  @override
  String get selected => '已选择';

  @override
  String get progress => '进度';

  @override
  String get hash => '哈希值';

  @override
  String get size => '大小';

  @override
  String get bytes => '字节';

  @override
  String get preview => '预览';

  @override
  String get delete => '删除';

  @override
  String get deleteFile => '删除文件？';

  @override
  String get deleteConfirmation => '确定要永久删除此文件吗？';

  @override
  String get cancel => '取消';

  @override
  String get selectGroupOrFile => '选择一个组或文件来预览';

  @override
  String get noPreviewAvailable => '此文件类型无法预览';

  @override
  String get errorDeletingFile => '删除文件时出错';

  @override
  String get language => '语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文';
}
