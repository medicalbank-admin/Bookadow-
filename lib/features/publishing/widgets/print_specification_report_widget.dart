import 'package:flutter/material.dart';

import '../services/print_specification_validator.dart';

class PrintSpecificationReportWidget extends StatelessWidget {
  final PrintSpecificationResult result;

  const PrintSpecificationReportWidget({
    super.key,
    required this.result,
  });

  String _inches(double value) {
    return '${value.toStringAsFixed(3)} inches';
  }

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
                      ? Icons.print_outlined
                      : Icons.error_outline,
                  color: result.isValid
                      ? Colors.green
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Print Specification Report',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildMeasurement(
              context,
              'Calculated spine width',
              _inches(result.calculatedSpineWidthInches),
            ),
            _buildMeasurement(
              context,
              'Full cover width',
              _inches(result.totalCoverWidthInches),
            ),
            _buildMeasurement(
              context,
              'Full cover height',
              _inches(result.totalCoverHeightInches),
            ),
            const SizedBox(height: 16),
            if (result.errors.isNotEmpty) ...[
              _buildHeading(
                context,
                'Errors',
                theme.colorScheme.error,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
              _buildHeading(
                context,
                'Important warnings',
                Colors.orange.shade800,
              ),
              const SizedBox(height: 8),
              ...result.warnings.map(
                (message) => _buildMessage(
                  context,
                  message,
                  Icons.warning_amber_rounded,
                  Colors.orange.shade800,
                ),
              ),
            ],
            if (result.isValid && !result.hasWarnings)
              const Text('No issues found.'),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurement(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
