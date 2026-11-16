import 'package:flutter/material.dart';

import '../models/export_history_model.dart';
import '../services/export_file_open_service.dart';
import '../services/export_sharing_service.dart';
import '../widgets/export_workflow_summary_card.dart';

class ExportWorkflowResultScreen extends StatelessWidget {
  const ExportWorkflowResultScreen({
    super.key,
    required this.export,
    this.onContinue,
  });

  final ExportHistoryModel export;
  final VoidCallback? onContinue;

  Future<void> _openFile(BuildContext context) async {
    final result = await ExportFileOpenService().openExportedFile(
      filePath: export.filePath,
    );

    if (!context.mounted) return;

    if (!result.isSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
        ),
      );
    }
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      await ExportSharingService().shareExportedFile(
        filePath: export.filePath,
        subject: export.fileName,
        text: 'Created with BOOKADOW',
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to share file: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Result'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
          Icon(
            export.isSuccessful
                ? Icons.celebration_outlined
                : Icons.error_outline,
            size: 72,
            color: export.isSuccessful
                ? Colors.green
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            export.isSuccessful
                ? 'Your book is ready!'
                : 'Export could not be completed',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            export.isSuccessful
                ? 'Your manuscript has been exported successfully.'
                : 'Please review the error details below and try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          ExportWorkflowSummaryCard(
            export: export,
            onOpen: export.isSuccessful &&
                    export.filePath.isNotEmpty
                ? () => _openFile(context)
                : null,
            onShare: export.isSuccessful &&
                    export.filePath.isNotEmpty
                ? () => _shareFile(context)
                : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue ??
                  () => Navigator.of(context).pop(),
              child: const Text('Return to Publishing Studio'),
            ),
          ),
        ],
      ),
    );
  }
}
