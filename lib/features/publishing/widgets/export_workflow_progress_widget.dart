import 'package:flutter/material.dart';

import '../models/export_workflow_status.dart';

class ExportWorkflowProgressWidget extends StatelessWidget {
  const ExportWorkflowProgressWidget({
    super.key,
    required this.status,
    this.onRetry,
  });

  final ExportWorkflowStatus status;
  final VoidCallback? onRetry;

  String _stageLabel(ExportWorkflowStage stage) {
    switch (stage) {
      case ExportWorkflowStage.preparing:
        return 'Preparing';
      case ExportWorkflowStage.validating:
        return 'Validating';
      case ExportWorkflowStage.generating:
        return 'Generating';
      case ExportWorkflowStage.saving:
        return 'Saving';
      case ExportWorkflowStage.completed:
        return 'Completed';
      case ExportWorkflowStage.failed:
        return 'Failed';
      case ExportWorkflowStage.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(BuildContext context) {
    if (status.hasFailed) {
      return Theme.of(context).colorScheme.error;
    }

    if (status.isCompleted) {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.primary;
  }

  IconData _statusIcon() {
    if (status.hasFailed) {
      return Icons.error_outline;
    }

    if (status.isCompleted) {
      return Icons.check_circle_outline;
    }

    if (status.stage == ExportWorkflowStage.cancelled) {
      return Icons.cancel_outlined;
    }

    return Icons.auto_awesome;
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(context);

    final double progress =
        status.progress.clamp(0.0, 1.0).toDouble();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _statusIcon(),
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Book Export',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _stageLabel(status.stage),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              status.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (status.errorMessage != null &&
                status.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                status.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (status.hasFailed && onRetry != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
