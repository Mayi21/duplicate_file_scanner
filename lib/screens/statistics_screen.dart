import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/statistics_provider.dart';
import '../utils/file_type_helper.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, stats, child) {
          if (stats.totalDuplicateGroups == 0) {
            return Center(
              child: Text(
                l10n.noStatistics ?? 'No statistics available. Please run a scan first.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return AnimationLimiter(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  _buildOverviewCard(context, stats, l10n),
                  const SizedBox(height: 16),
                  _buildFileTypeChart(context, stats, l10n),
                  const SizedBox(height: 16),
                  _buildSizeDistributionChart(context, stats, l10n),
                  const SizedBox(height: 16),
                  _buildTopDuplicatesCard(context, stats, l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overview ?? 'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.group,
                    l10n.duplicateGroups ?? 'Duplicate Groups',
                    '${stats.totalDuplicateGroups}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.file_copy,
                    l10n.duplicateFiles ?? 'Duplicate Files',
                    '${stats.totalDuplicateFiles}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.storage,
                    l10n.wastedSpace ?? 'Wasted Space',
                    FileTypeHelper.formatFileSize(stats.totalWastedSpace),
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.check_circle,
                    l10n.selectedFiles ?? 'Selected Files',
                    '${stats.totalSelectedFiles}',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFileTypeChart(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final typeStats = stats.fileTypeStatistics;
    if (typeStats.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.fileTypeDistribution ?? 'File Type Distribution',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...typeStats.entries.map((entry) {
              final percentage = (entry.value / stats.totalDuplicateFiles * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(
                        _getColorForFileType(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeDistributionChart(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final sizeDistribution = stats.fileSizeDistribution;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sizeDistribution ?? 'Size Distribution',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...sizeDistribution.entries.map((entry) {
              final percentage = stats.totalDuplicateFiles > 0 
                  ? (entry.value / stats.totalDuplicateFiles * 100) 
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation(Colors.purple),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDuplicatesCard(BuildContext context, StatisticsProvider stats, AppLocalizations l10n) {
    final largestGroup = stats.getLargestDuplicateGroup();
    final mostDuplicated = stats.getMostDuplicatedGroup();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.topDuplicates ?? 'Top Duplicates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (largestGroup != null) ...[
              ListTile(
                leading: Icon(Icons.storage, color: Colors.red),
                title: Text(l10n.largestDuplicate ?? 'Largest Duplicate'),
                subtitle: Text(FileTypeHelper.formatFileSize(largestGroup.size)),
                trailing: Text('${largestGroup.paths.length} ${l10n.files ?? 'files'}'),
              ),
            ],
            if (mostDuplicated != null) ...[
              ListTile(
                leading: Icon(Icons.content_copy, color: Colors.orange),
                title: Text(l10n.mostDuplicated ?? 'Most Duplicated'),
                subtitle: Text(FileTypeHelper.formatFileSize(mostDuplicated.size)),
                trailing: Text('${mostDuplicated.paths.length} ${l10n.copies ?? 'copies'}'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorForFileType(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Colors.green;
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'document':
        return Colors.blue;
      case 'spreadsheet':
        return Colors.orange;
      case 'presentation':
        return Colors.deepOrange;
      case 'archive':
        return Colors.brown;
      case 'executable':
        return Colors.grey;
      case 'code':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }
}