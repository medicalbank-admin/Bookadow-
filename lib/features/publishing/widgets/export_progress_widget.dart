
import 'package:flutter/material.dart';

class ExportProgressWidget extends StatelessWidget {
  const ExportProgressWidget({
    super.key,
    required this.progress,
    required this.status,
    this.isComplete = false,
    this.hasError = false,
    this.errorMessage,
  });

  final double progress;
  final String status;
  final bool isComplete;
  final bool hasError;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    final Color statusColor = hasError
        ? Colors.red
        : isComplete
            ? Colors.green
            : const Color(0xFF315B87);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError
                  ? Icons.error_outline
                  : isComplete
                      ? Icons.check_circle_outline
                      : Icons.auto_stories_outlined,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 16),
            Text(
              hasError
                  ? 'Export Failed'
                  : isComplete
                      ? 'Export Complete'
                      : 'Preparing Your Book',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasError
                  ? errorMessage ?? 'Something went wrong.'
                  : status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            if (!hasError) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: isComplete ? 1 : safeProgress,
                  minHeight: 9,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(safeProgress * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
