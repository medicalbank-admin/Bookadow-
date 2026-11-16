import 'package:flutter/material.dart';

class ExportWorkflowActionPanel extends StatelessWidget {
  const ExportWorkflowActionPanel({
    super.key,
    required this.isRunning,
    required this.isCompleted,
    required this.hasFailed,
    required this.onStart,
    this.onOpenFile,
    this.onReturn,
  });

  final bool isRunning;
  final bool isCompleted;
  final bool hasFailed;

  final VoidCallback onStart;
  final VoidCallback? onOpenFile;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    if (isRunning) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Please wait while your book is being exported...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onOpenFile != null)
            ElevatedButton.icon(
              onPressed: onOpenFile,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Exported File'),
            ),
          if (onReturn != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onReturn,
              child: const Text('Return to Studio'),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onStart,
          icon: Icon(
            hasFailed
                ? Icons.refresh
                : Icons.file_download_outlined,
          ),
          label: Text(
            hasFailed ? 'Retry Export' : 'Start Export',
          ),
        ),
        if (onReturn != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onReturn,
            child: const Text('Cancel and Return'),
          ),
        ],
      ],
    );
  }
}
