
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../controllers/export_history_controller.dart';
import '../models/export_history_model.dart';

class ExportHistoryScreen extends StatefulWidget {
  const ExportHistoryScreen({
    super.key,
    this.bookId,
  });

  final String? bookId;

  @override
  State<ExportHistoryScreen> createState() =>
      _ExportHistoryScreenState();
}

class _ExportHistoryScreenState
    extends State<ExportHistoryScreen> {
  late final ExportHistoryController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ExportHistoryController();
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();

    if (!mounted) return;

    if (widget.bookId != null) {
      await _controller.loadExportsForBook(widget.bookId!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatName(String format) {
    switch (format.toLowerCase()) {
      case 'digitalpdf':
      case 'digital_pdf':
        return 'Digital PDF';
      case 'printreadypdf':
      case 'print_ready_pdf':
        return 'Print-ready PDF';
      case 'epub':
        return 'EPUB';
      case 'word':
        return 'Word Document';
      default:
        return format;
    }
  }

  IconData _formatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'epub':
        return Icons.menu_book_rounded;
      case 'word':
        return Icons.description_rounded;
      default:
        return Icons.picture_as_pdf_rounded;
    }
  }

  Future<void> _deleteExport(
    ExportHistoryModel record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete export record?'),
        content: const Text(
          'This removes the record from your export history. '
          'The exported file itself will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteExport(record.id);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear export history?'),
        content: const Text(
          'All export history records will be removed. '
          'Your exported files will remain untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear history'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AppTheme.paper,
          appBar: AppBar(
            title: const Text('Export History'),
            actions: [
              if (_controller.exports.isNotEmpty)
                IconButton(
                  tooltip: 'Clear history',
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading &&
        _controller.exports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.errorMessage != null &&
        _controller.exports.isEmpty) {
      return _buildError();
    }

    if (_controller.exports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSummary(),
          const SizedBox(height: 22),
          const Text(
            'Previous Exports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          ..._controller.exports.map(_buildExportCard),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Total',
            _controller.exportCount.toString(),
            Icons.folder_copy_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'Successful',
            _controller.successfulExports.toString(),
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'Failed',
            _controller.failedExports.toString(),
            Icons.error_outline,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.blue, size: 21),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(ExportHistoryModel record) {
    final successful = record.isSuccessful;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _formatIcon(record.format),
              color: AppTheme.blue,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatName(record.format),
                  style: const TextStyle(
                    color: AppTheme.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${DateFormat('dd MMM yyyy, hh:mm a').format(record.createdAt)}'
                  '  •  ${record.formattedFileSize}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      successful
                          ? Icons.check_circle
                          : Icons.error,
                      size: 14,
                      color: successful
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      successful ? 'Successful' : 'Failed',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: successful
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                if (!successful &&
                    record.errorMessage != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    record.errorMessage!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete record',
            onPressed: () => _deleteExport(record),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 65,
              color: AppTheme.blue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Export History Yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your exported books will appear here '
              'after you create your first export.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
