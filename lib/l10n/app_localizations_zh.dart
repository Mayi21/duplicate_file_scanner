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

  @override
  String get statistics => '统计信息';

  @override
  String get noStatistics => '无统计数据。请先运行扫描。';

  @override
  String get overview => '概览';

  @override
  String get duplicateGroups => '重复文件组';

  @override
  String get duplicateFiles => '重复文件';

  @override
  String get wastedSpace => '浪费空间';

  @override
  String get selectedFiles => '已选择文件';

  @override
  String get fileTypeDistribution => '文件类型分布';

  @override
  String get sizeDistribution => '大小分布';

  @override
  String get topDuplicates => '热门重复';

  @override
  String get largestDuplicate => '最大重复文件';

  @override
  String get mostDuplicated => '最多重复文件';

  @override
  String get files => '个文件';

  @override
  String get copies => '份副本';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get deleteSelected => '删除选中';

  @override
  String get moveToTrash => '移至废纸篓';

  @override
  String get pauseScan => '暂停扫描';

  @override
  String get resumeScan => '恢复扫描';

  @override
  String get stopScan => '停止扫描';

  @override
  String get filesScanned => '已扫描文件';

  @override
  String get estimatedTime => '预计时间';

  @override
  String get scanSpeed => '扫描速度';

  @override
  String get filesPerSecond => '文件/秒';

  @override
  String get remainingTime => '剩余时间';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get help => '帮助';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '浅色模式';
}
