
import 'package:flutter/material.dart';

import '../services/publishing_validation_service.dart';

class ExportValidationWidget extends StatelessWidget {
  const ExportValidationWidget({
    super.key,
    required this.result,
    this.onContinue,
    this.onCancel,
  });

  final PublishingValidationResult result;
  final VoidCallback? onContinue;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final hasErrors = !result.isValid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasErrors
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: hasErrors ? Colors.orange : Colors.green,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasErrors
                        ? 'Export Needs Attention'
                        : 'Export Settings Valid',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasErrors)
              _buildMessageList(
                title: 'Errors',
                messages: result.errors,
                color: Colors.red,
                icon: Icons.error_outline,
              ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildMessageList(
                title: 'Warnings',
                messages: result.warnings,
                color: Colors.orange,
                icon: Icons.info_outline,
              ),
            ],
            if (!hasErrors && result.warnings.isEmpty)
              const Text(
                'All checks passed. Your settings are ready for export.',
                style: TextStyle(fontSize: 13),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                if (onCancel != null && onContinue != null)
                  const SizedBox(width: 10),
                if (onContinue != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasErrors ? null : onContinue,
                      child: const Text('Continue'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList({
    required String title,
    required List<String> messages,
    required Color color,
    required IconData icon,
  }) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...messages.map(
          (message) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 17, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
