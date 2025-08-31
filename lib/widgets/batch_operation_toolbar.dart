import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum BatchAction {
  selectAll,
  deselectAll,
  keepNewest,
  keepOldest,
  deleteSelected,
  moveToTrash,
}

class BatchOperationToolbar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final Function(BatchAction) onAction;
  final bool isEnabled;

  const BatchOperationToolbar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onAction,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 选择状态显示
          Row(
            children: [
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '$selectedCount / $totalCount ${l10n.selectedFiles}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              if (selectedCount > 0)
                TextButton.icon(
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: Text(l10n.deselectAll),
                  onPressed: isEnabled ? () => onAction(BatchAction.deselectAll) : null,
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 操作按钮组
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // 选择操作
              _buildActionChip(
                context,
                icon: Icons.select_all,
                label: l10n.selectAll,
                onTap: isEnabled ? () => onAction(BatchAction.selectAll) : null,
                color: Colors.blue,
              ),
              // 智能保留操作
              _buildActionChip(
                context,
                icon: Icons.access_time,
                label: l10n.keepNewest,
                onTap: isEnabled ? () => onAction(BatchAction.keepNewest) : null,
                color: Colors.green,
              ),
              _buildActionChip(
                context,
                icon: Icons.history,
                label: l10n.keepOldest,
                onTap: isEnabled ? () => onAction(BatchAction.keepOldest) : null,
                color: Colors.green,
              ),
            ],
          ),
          if (selectedCount > 0) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // 危险操作
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_sweep),
                    label: Text('${l10n.deleteSelected} ($selectedCount)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isEnabled ? () => onAction(BatchAction.deleteSelected) : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.moveToTrash),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isEnabled ? () => onAction(BatchAction.moveToTrash) : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    Color? color,
  }) {
    color ??= Theme.of(context).colorScheme.primary;
    
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      onPressed: onTap,
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      visualDensity: VisualDensity.compact,
    );
  }
}