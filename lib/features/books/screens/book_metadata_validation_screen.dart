import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/book_metadata_validation_controller.dart';
import '../models/book_metadata_model.dart';
import '../widgets/book_metadata_validation_widget.dart';

class BookMetadataValidationScreen extends StatefulWidget {
  final BookMetadataModel metadata;

  const BookMetadataValidationScreen({
    super.key,
    required this.metadata,
  });

  @override
  State<BookMetadataValidationScreen> createState() =>
      _BookMetadataValidationScreenState();
}

class _BookMetadataValidationScreenState
    extends State<BookMetadataValidationScreen> {
  late final BookMetadataValidationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = BookMetadataValidationController();
    _runValidation();
  }

  Future<void> _runValidation() async {
    await _controller.validate(widget.metadata);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metadata Review'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isValidating) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.errorMessage != null) {
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
                    Text(
                      _controller.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _runValidation,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final result = _controller.result;

          if (result == null) {
            return const Center(
              child: Text('No validation results available.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: AppTheme.gold,
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Publication Readiness Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Review your book information before proceeding with publication.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              BookMetadataValidationWidget(
                result: result,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _runValidation,
                icon: const Icon(Icons.refresh),
                label: const Text('Run Validation Again'),
              ),
              const SizedBox(height: 12),
              if (result.isValid)
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Continue'),
                  ),
                )
              else
                const Text(
                  'Correct the errors in your book metadata before continuing.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
