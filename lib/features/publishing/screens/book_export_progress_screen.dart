import 'package:flutter/material.dart';

class BookExportProgressScreen extends StatelessWidget {
  const BookExportProgressScreen({
    super.key,
    required this.progress,
    required this.statusMessage,
    this.bookTitle = 'Your Book',
    this.isCompleted = false,
    this.hasFailed = false,
    this.errorMessage,
  });

  final double progress;
  final String statusMessage;
  final String bookTitle;
  final bool isCompleted;
  final bool hasFailed;
  final String? errorMessage;

  double get _safeProgress {
    return progress.clamp(0.0, 1.0).toDouble();
  }

  String get _percentage {
    return '${(_safeProgress * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    final Color statusColor = hasFailed
        ? colors.error
        : isCompleted
            ? Colors.green
            : colors.primary;

    final IconData statusIcon = hasFailed
        ? Icons.error_outline_rounded
        : isCompleted
            ? Icons.check_circle_outline_rounded
            : Icons.auto_stories_rounded;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Progress'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 55,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                hasFailed
                    ? 'Export Failed'
                    : isCompleted
                        ? 'Export Completed'
                        : 'Creating Your Book',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                bookTitle,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              if (!hasFailed && !isCompleted) ...[
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: _safeProgress,
                          strokeWidth: 9,
                          backgroundColor:
                              colors.surfaceContainerHighest,
                        ),
                      ),
                      Text(
                        _percentage,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 65,
                ),

              if (hasFailed)
                Icon(
                  Icons.warning_amber_rounded,
                  color: colors.error,
                  size: 65,
                ),

              const SizedBox(height: 25),

              Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              if (hasFailed && errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: colors.onErrorContainer,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              if (!hasFailed && !isCompleted)
                const Text(
                  'Please keep BOOKADOW open while your document is being prepared.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
