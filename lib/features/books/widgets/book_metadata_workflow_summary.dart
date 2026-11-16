import 'package:flutter/material.dart';

import '../services/book_metadata_workflow_service.dart';

class BookMetadataWorkflowSummary extends StatelessWidget {
  const BookMetadataWorkflowSummary({
    super.key,
    required this.result,
  });

  final BookMetadataWorkflowResult result;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Book readiness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: (result.completionPercentage / 100)
                  .clamp(0.0, 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.completionPercentage.toStringAsFixed(0)}% metadata completed',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  result.canProceed
                      ? Icons.check_circle
                      : Icons.error,
                  color: result.canProceed
                      ? Colors.green
                      : colors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.canProceed
                        ? 'Metadata validation passed'
                        : 'Please fix metadata errors',
                  ),
                ),
              ],
            ),
            if (result.hasWarnings) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Some optional details need attention.'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
