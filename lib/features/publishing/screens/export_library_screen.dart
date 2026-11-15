import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/export_file_management_service.dart';
import '../services/export_file_open_service.dart';
import '../services/export_sharing_service.dart';

class ExportLibraryScreen extends StatefulWidget {
  const ExportLibraryScreen({super.key});

  @override
  State<ExportLibraryScreen> createState() =>
      _ExportLibraryScreenState();
}

class _ExportLibraryScreenState
    extends State<ExportLibraryScreen> {
  final ExportFileManagementService _managementService =
      ExportFileManagementService();

  final ExportFileOpenService _openService =
      const ExportFileOpenService();

  final ExportSharingService _sharingService =
      ExportSharingService();

  final TextEditingController _searchController =
      TextEditingController();

  List<ManagedExportFile> _files = [];

  bool _isLoading = true;
  String _searchQuery = '';
  int _storageUsed = 0;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);

    try {
      final List<ManagedExportFile> files =
          await _managementService.searchFiles(_searchQuery);

      final int storage =
          await _managementService.getTotalStorageUsed();

      if (!mounted) return;

      setState(() {
        _files = files;
        _storageUsed = storage;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load exports: $error'),
        ),
      );
    }
  }

  Future<void> _openFile(ManagedExportFile file) async {
    final result = await _openService.openFile(file.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
  }

  Future<void> _shareFile(ManagedExportFile file) async {
    try {
      await _sharingService.shareExportedFile(
        filePath: file.path,
        subject: file.name,
        text: 'Created with BOOKADOW',
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share file: $error')),
      );
    }
  }

  Future<void> _deleteFile(ManagedExportFile file) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete export?'),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
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

    if (confirmed != true) return;

    final bool deleted =
        await _managementService.deleteFile(file.path);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Export deleted.' : 'Unable to delete export.',
        ),
      ),
    );

    await _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Library'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadFiles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStorageCard(colors),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _loadFiles();
              },
              decoration: InputDecoration(
                hintText: 'Search exported books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _loadFiles();
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          ),
          Expanded(
            child: _buildFileList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard(ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.folder_copy_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your exported documents',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_files.length} files • '
                  '${_managementService.formatStorageSize(_storageUsed)} used',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_files.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 58,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 14),
              Text(
                _searchQuery.isEmpty
                    ? 'No exported books yet'
                    : 'No matching files found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              const Text(
                'Your exported documents will appear here.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _files.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final ManagedExportFile file = _files[index];

          return _buildFileCard(file);
        },
      ),
    );
  }

  Widget _buildFileCard(ManagedExportFile file) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 52,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _fileIcon(file.extension),
                color: colors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${file.extension.toUpperCase().replaceFirst('.', '')} '
                    '• ${_managementService.formatStorageSize(file.sizeBytes)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a')
                        .format(file.modifiedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'open':
                    _openFile(file);
                    break;
                  case 'share':
                    _shareFile(file);
                    break;
                  case 'delete':
                    _deleteFile(file);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'open',
                  child: Text('Open'),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Text('Share'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _fileIcon(String extension) {
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf_rounded;
      case '.epub':
        return Icons.menu_book_rounded;
      case '.docx':
      case '.doc':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
