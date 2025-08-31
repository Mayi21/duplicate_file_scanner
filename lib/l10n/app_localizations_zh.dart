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

  @override
  String get keepNewest => '保留最新';

  @override
  String get keepOldest => '保留最旧';

  @override
  String get comparing => '正在对比';

  @override
  String get showInFinder => '在访达中显示';

  @override
  String get keepThis => '保留此文件';

  @override
  String get smartTruncation => '智能文件名截断';

  @override
  String get thumbnailPreview => '缩略图预览';

  @override
  String get fileDetails => '文件详情';

  @override
  String get modified => '修改时间';

  @override
  String get folder => '文件夹';

  @override
  String get type => '类型';

  @override
  String get fullScreen => '全屏';

  @override
  String get exitFullScreen => '退出全屏';

  @override
  String get listView => '列表视图';

  @override
  String get comparisonView => '对比视图';

  @override
  String get exitComparison => '退出对比';

  @override
  String get comparisonMode => '对比模式';

  @override
  String get compareFiles => '对比文件';

  @override
  String get noDuplicatesFound => '未找到重复文件';

  @override
  String get selectDirectoryAndScan => '请选择一个目录并开始扫描。';

  @override
  String get comparisonGroupNotFound => '未找到对比组';

  @override
  String get backToList => '返回列表';

  @override
  String get selectAFileToPreview => '选择一个文件以预览';

  @override
  String get actionCannotBeUndone => '⚠️ 此操作无法撤销！';

  @override
  String get restoreFromTrash => '您可以稍后从废纸篓恢复它们。';

  @override
  String deleteConfirmation(int count) {
    return '确定要永久删除 $count 个文件吗？';
  }

  @override
  String filesDeleted(int count) {
    return '$count 个文件已被删除。';
  }

  @override
  String moveFilesToTrashConfirmation(int count) {
    return '确定要将 $count 个文件移至废纸篓吗？';
  }

  @override
  String filesMovedToTrash(int count) {
    return '$count 个文件已被移至废纸篓。';
  }

  @override
  String get permissionErrorMoveToTrash =>
      '权限不足。请前往“系统设置 > 隐私与安全性 > 自动化”，找到“Duplicate File Scanner”，并勾选“访达”（Finder）以授予权限。';
}
