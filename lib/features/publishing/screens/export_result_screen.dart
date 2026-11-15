
import 'dart:io';

import 'package:flutter/material.dart';

class ExportResultScreen extends StatelessWidget {
  const ExportResultScreen({
    super.key,
    required this.filePath,
    required this.fileName,
    this.errorMessage,
    this.onOpenFile,
    this.onShareFile,
  });

  final String? filePath;
  final String fileName;
  final String? errorMessage;
  final VoidCallback? onOpenFile;
  final VoidCallback? onShareFile;

  bool get isSuccessful =>
      filePath != null && errorMessage == null;

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        isSuccessful ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Result'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccessful
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: statusColor,
                  size: 58,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isSuccessful
                    ? 'Your Book Is Ready!'
                    : 'Export Failed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccessful
                    ? 'BOOKADOW has finished generating your book.'
                    : errorMessage ?? 'An unexpected error occurred.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (isSuccessful) ...[
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.insert_drive_file_outlined,
                    ),
                    title: Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text('Exported file'),
                  ),
                ),
                const SizedBox(height: 20),
                if (onOpenFile != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onOpenFile,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open File'),
                    ),
                  ),
                if (onShareFile != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onShareFile,
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share Book'),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Publishing Studio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
