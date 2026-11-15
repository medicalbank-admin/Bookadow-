
import 'package:flutter/material.dart';

import '../models/book_layout_model.dart';

class PublishingSettingsSummary extends StatelessWidget {
  const PublishingSettingsSummary({
    super.key,
    required this.layout,
  });

  final BookLayoutModel layout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fact_check_outlined),
                SizedBox(width: 10),
                Text(
                  'Publishing Settings Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRow(
              'Trim Size',
              '${layout.effectivePageWidth.toStringAsFixed(2)} × '
                  '${layout.effectivePageHeight.toStringAsFixed(2)} inches',
            ),
            _buildRow(
              'Orientation',
              layout.orientation.name.toUpperCase(),
            ),
            _buildRow(
              'Font Family',
              layout.fontFamily,
            ),
            _buildRow(
              'Font Size',
              '${layout.fontSize.toStringAsFixed(1)} pt',
            ),
            _buildRow(
              'Line Spacing',
              '${layout.lineSpacing.toStringAsFixed(2)}×',
            ),
            _buildRow(
              'Paragraph Spacing',
              '${layout.paragraphSpacing.toStringAsFixed(1)} pt',
            ),
            const Divider(height: 24),
            const Text(
              'Page Margins',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            _buildRow('Top', '${layout.topMargin.toStringAsFixed(2)} in'),
            _buildRow(
              'Bottom',
              '${layout.bottomMargin.toStringAsFixed(2)} in',
            ),
            _buildRow(
              'Inside',
              '${layout.insideMargin.toStringAsFixed(2)} in',
            ),
            _buildRow(
              'Outside',
              '${layout.outsideMargin.toStringAsFixed(2)} in',
            ),
            const Divider(height: 24),
            _buildStatus(
              'Page Numbers',
              layout.showPageNumbers,
            ),
            _buildStatus(
              'Running Headers',
              layout.showRunningHeaders,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(String label, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel_outlined,
            size: 17,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            enabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              fontSize: 12,
              color: enabled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
