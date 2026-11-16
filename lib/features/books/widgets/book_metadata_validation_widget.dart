
import 'package:flutter/material.dart';

import '../services/book_metadata_validation_service.dart';

class BookMetadataValidationWidget extends StatelessWidget {
  final BookMetadataValidationResult result;

  const BookMetadataValidationWidget({
    super.key,
    required this.result,
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
                  result.isValid
                      ? Icons.verified_outlined
                      : Icons.error_outline,
                  color: result.isValid
                      ? Colors.green
                      : theme.colorScheme.error,
                  size: 25,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Metadata Validation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              result.isValid
                  ? 'No blocking metadata errors found.'
                  : '${result.errors.length} issue(s) require attention.',
              style: theme.textTheme.bodyMedium,
            ),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildHeading(
                context,
                'Required corrections',
                theme.colorScheme.error,
              ),
              const SizedBox(height: 10),
              ...result.errors.map(
                (message) => _buildMessage(
                  context,
                  message,
                  Icons.cancel_outlined,
                  theme.colorScheme.error,
                ),
              ),
            ],
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildHeading(
                context,
                'Recommendations',
                Colors.orange.shade800,
              ),
              const SizedBox(height: 10),
              ...result.warnings.map(
                (message) => _buildMessage(
                  context,
                  message,
                  Icons.warning_amber_rounded,
                  Colors.orange.shade800,
                ),
              ),
            ],
            if (result.issueCount == 0) ...[
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text('All checks passed'),
                subtitle: Text(
                  'No metadata errors or recommendations were found.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(
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

  Widget _buildMessage(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 19,
          ),
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
}
