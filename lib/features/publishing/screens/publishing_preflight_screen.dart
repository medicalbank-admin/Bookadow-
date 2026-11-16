
import 'package:flutter/material.dart';

import '../controllers/publishing_preflight_controller.dart';
import '../models/book_cover_model.dart';
import '../models/book_layout_model.dart';
import '../services/book_export_manager.dart';
import '../widgets/publishing_preflight_report_widget.dart';

class PublishingPreflightScreen extends StatefulWidget {
  final String bookTitle;
  final String authorName;
  final String fileName;
  final List<ExportChapter> chapters;
  final BookLayoutModel layout;
  final BookCoverModel cover;

  const PublishingPreflightScreen({
    super.key,
    required this.bookTitle,
    required this.authorName,
    required this.fileName,
    required this.chapters,
    required this.layout,
    required this.cover,
  });

  @override
  State<PublishingPreflightScreen> createState() =>
      _PublishingPreflightScreenState();
}

class _PublishingPreflightScreenState
    extends State<PublishingPreflightScreen> {
  late final PublishingPreflightController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PublishingPreflightController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _runChecks();
      }
    });
  }

  Future<void> _runChecks() async {
    await _controller.runChecks(
      bookTitle: widget.bookTitle,
      authorName: widget.authorName,
      fileName: widget.fileName,
      chapters: widget.chapters,
      layout: widget.layout,
      cover: widget.cover,
    );
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
        title: const Text('Publishing Review'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isChecking) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.errorMessage != null) {
            return _buildErrorState();
          }

          if (!_controller.hasReport) {
            return _buildEmptyState();
          }

          return _buildReportState();
        },
      ),
    );
  }

  Widget _buildReportState() {
    final report = _controller.report!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Final publishing checks',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review the available checks before proceeding with your export.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        PublishingPreflightReportWidget(report: report),
        const SizedBox(height: 20),
        if (report.isReady)
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Continue to Export'),
          )
        else
          FilledButton.icon(
            onPressed: _runChecks,
            icon: const Icon(Icons.refresh),
            label: const Text('Run Checks Again'),
          ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Return to Editing'),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Review could not be completed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _runChecks,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FilledButton(
        onPressed: _runChecks,
        child: const Text('Start Publishing Checks'),
      ),
    );
  }
}
