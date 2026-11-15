import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../models/export_history_model.dart';

class ExportHistoryCard extends StatelessWidget {
  const ExportHistoryCard({
    super.key,
    required this.record,
    this.onDelete,
    this.onOpen,
    this.compact = false,
  });

  final ExportHistoryModel record;
  final VoidCallback? onDelete;
  final VoidCallback? onOpen;
  final bool compact;

  String get _formatLabel {
    switch (record.format.toLowerCase()) {
      case 'digitalpdf':
      case 'digital_pdf':
        return 'Digital PDF';
      case 'printreadypdf':
      case 'print_ready_pdf':
        return 'Print-ready PDF';
      case 'epub':
        return 'EPUB';
      case 'word':
        return 'Word Document';
      default:
        return record.format;
    }
  }

  IconData get _formatIcon {
    switch (record.format.toLowerCase()) {
      case 'epub':
        return Icons.menu_book_rounded;
      case 'word':
        return Icons.description_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final successful = record.isSuccessful;

    final statusColor =
        successful ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      margin: EdgeInsets.only(
        bottom: compact ? 8 : 12,
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Row(
            children: [
              _buildFormatIcon(),
              const SizedBox(width: 13),
              Expanded(
                child: _buildDetails(statusColor, successful),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete export record',
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatIcon() {
    return Container(
      width: compact ? 42 : 50,
      height: compact ? 42 : 50,
      decoration: BoxDecoration(
        color: AppTheme.blue.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        _formatIcon,
        color: AppTheme.blue,
        size: compact ? 21 : 25,
      ),
    );
  }

  Widget _buildDetails(
    Color statusColor,
    bool successful,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.fileName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _formatLabel,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${DateFormat('dd MMM yyyy, hh:mm a').format(record.createdAt)}'
          ' • ${record.formattedFileSize}',
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Icon(
              successful
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              size: 14,
              color: statusColor,
            ),
            const SizedBox(width: 5),
            Text(
              successful ? 'Successful' : 'Failed',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!successful &&
            record.errorMessage != null &&
            !compact) ...[
          const SizedBox(height: 6),
          Text(
            record.errorMessage!,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
