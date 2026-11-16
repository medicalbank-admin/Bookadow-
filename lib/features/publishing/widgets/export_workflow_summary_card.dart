
import 'package:flutter/material.dart';

import '../models/export_history_model.dart';

class ExportWorkflowSummaryCard extends StatelessWidget {
  const ExportWorkflowSummaryCard({
    super.key,
    required this.export,
    this.onOpen,
    this.onShare,
  });

  final ExportHistoryModel export;
  final VoidCallback? onOpen;
  final VoidCallback? onShare;

  String get _formatLabel {
    switch (export.format.toLowerCase()) {
      case 'digitalpdf':
      case 'digital_pdf':
        return 'Digital PDF';
      case 'printreadypdf':
      case 'print_ready_pdf':
        return 'Print-ready PDF';
      case 'epub':
        return 'EPUB eBook';
      case 'word':
      case 'docx':
        return 'Microsoft Word';
      default:
        return export.format;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color successColor = Colors.green;
    final Color statusColor =
        export.isSuccessful
            ? successColor
            : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  export.isSuccessful
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: statusColor,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    export.isSuccessful
                        ? 'Export Successful'
                        : 'Export Failed',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _detailRow(
              context,
              Icons.description_outlined,
              'File name',
              export.fileName,
            ),
            const SizedBox(height: 12),
            _detailRow(
              context,
              Icons.insert_drive_file_outlined,
              'Format',
              _formatLabel,
            ),
            const SizedBox(height: 12),
            _detailRow(
              context,
              Icons.storage_outlined,
              'File size',
              export.formattedFileSize,
            ),
            const SizedBox(height: 12),
            _detailRow(
              context,
              Icons.calendar_today_outlined,
              'Created',
              _formatDate(export.createdAt),
            ),
            if (export.filePath.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(
                context,
                Icons.folder_outlined,
                'Location',
                export.filePath,
              ),
            ],
            if (export.errorMessage != null &&
                export.errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                export.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (export.isSuccessful &&
                (onOpen != null || onShare != null)) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  if (onOpen != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onOpen,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open'),
                      ),
                    ),
                  if (onOpen != null && onShare != null)
                    const SizedBox(width: 10),
                  if (onShare != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Theme.of(context).colorScheme.secondary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
