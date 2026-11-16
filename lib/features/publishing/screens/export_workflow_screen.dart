import 'package:flutter/material.dart';

import '../controllers/export_workflow_controller.dart';
import '../models/book_export_model.dart';
import '../models/book_layout_model.dart';
import '../services/book_export_manager.dart';
import '../widgets/export_workflow_progress_widget.dart';
import '../widgets/export_workflow_stage_indicator.dart';

class ExportWorkflowScreen extends StatefulWidget {
  const ExportWorkflowScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.settings,
    required this.layout,
    required this.chapters,
    this.subtitle,
    this.description,
    this.languageCode = 'en',
    this.onExportCompleted,
  });

  final String bookId;
  final String bookTitle;
  final String authorName;
  final BookExportModel settings;
  final BookLayoutModel layout;
  final List<ExportChapter> chapters;
  final String? subtitle;
  final String? description;
  final String languageCode;

  final VoidCallback? onExportCompleted;

  @override
  State<ExportWorkflowScreen> createState() =>
      _ExportWorkflowScreenState();
}

class _ExportWorkflowScreenState
    extends State<ExportWorkflowScreen> {
  late final ExportWorkflowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExportWorkflowController();
  }

  Future<void> _startExport() async {
    final result = await _controller.startExport(
      bookId: widget.bookId,
      bookTitle: widget.bookTitle,
      authorName: widget.authorName,
      settings: widget.settings,
      layout: widget.layout,
      chapters: widget.chapters,
      subtitle: widget.subtitle,
      description: widget.description,
      languageCode: widget.languageCode,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your book has been exported successfully.'),
        ),
      );

      widget.onExportCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Your Book'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final status = _controller.status;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.bookTitle,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prepare your manuscript for publishing.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ExportWorkflowStageIndicator(
                currentStage: status.stage,
              ),
              const SizedBox(height: 12),
              ExportWorkflowProgressWidget(
                status: status,
                onRetry: _startExport,
              ),
              const SizedBox(height: 16),
              if (!_controller.isRunning &&
                  !status.isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startExport,
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text(
                      status.hasFailed
                          ? 'Try Export Again'
                          : 'Start Export',
                    ),
                  ),
                ),
              ],
              if (status.isCompleted) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onExportCompleted ??
                        () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Continue'),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
