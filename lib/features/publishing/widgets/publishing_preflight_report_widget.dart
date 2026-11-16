import 'package:flutter/material.dart';

import '../services/publishing_preflight_report_builder.dart';

class PublishingPreflightReportWidget extends StatelessWidget {
  final PublishingPreflightReport report;

  const PublishingPreflightReportWidget({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  report.isReady
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: report.isReady
                      ? Colors.green
                      : theme.colorScheme.error,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Publishing Readiness',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.summary,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (report.errors.isNotEmpty) ...[
              _buildSectionTitle(
                context,
                'Errors to fix',
                theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
              ...report.errors.map(
                (message) => _buildIssue(
                  context,
                  message,
                  Icons.cancel_outlined,
                  theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (report.warnings.isNotEmpty) ...[
              _buildSectionTitle(
                context,
                'Warnings',
                Colors.orange.shade800,
              ),
              const SizedBox(height: 8),
              ...report.warnings.map(
                (message) => _buildIssue(
                  context,
                  message,
                  Icons.warning_amber_rounded,
                  Colors.orange.shade800,
                ),
              ),
            ],
            if (report.isReady && !report.hasWarnings)
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.verified_outlined,
                  color: Colors.green,
                ),
                title: Text('No issues found'),
                subtitle: Text(
                  'The available publishing checks have passed.',
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Report generated: ${_formatDate(report.generatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color color,
  ) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildIssue(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }
}
