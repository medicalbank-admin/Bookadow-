
import 'package:flutter/material.dart';

import '../controllers/print_specification_controller.dart';
import '../widgets/print_specification_report_widget.dart';

class PrintSpecificationScreen extends StatefulWidget {
  final double trimWidthInches;
  final double trimHeightInches;
  final int pageCount;
  final double paperCaliperInches;
  final double bleedInches;
  final double minimumSpineWidthInches;
  final double maximumSpineWidthInches;

  const PrintSpecificationScreen({
    super.key,
    required this.trimWidthInches,
    required this.trimHeightInches,
    required this.pageCount,
    required this.paperCaliperInches,
    this.bleedInches = 0.125,
    this.minimumSpineWidthInches = 0,
    this.maximumSpineWidthInches = 10,
  });

  @override
  State<PrintSpecificationScreen> createState() =>
      _PrintSpecificationScreenState();
}

class _PrintSpecificationScreenState
    extends State<PrintSpecificationScreen> {
  late final PrintSpecificationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PrintSpecificationController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _runValidation();
      }
    });
  }

  Future<void> _runValidation() async {
    await _controller.validateSpecifications(
      trimWidthInches: widget.trimWidthInches,
      trimHeightInches: widget.trimHeightInches,
      pageCount: widget.pageCount,
      paperCaliperInches: widget.paperCaliperInches,
      bleedInches: widget.bleedInches,
      minimumSpineWidthInches: widget.minimumSpineWidthInches,
      maximumSpineWidthInches: widget.maximumSpineWidthInches,
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
        title: const Text('Print Specifications'),
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
            return _buildErrorState();
          }

          if (!_controller.hasResult) {
            return _buildEmptyState();
          }

          return _buildResultState();
        },
      ),
    );
  }

  Widget _buildResultState() {
    final result = _controller.result!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Physical Book Review',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review the estimated cover dimensions and spine width. '
          'Confirm all measurements with your printing provider.',
        ),
        const SizedBox(height: 20),
        PrintSpecificationReportWidget(result: result),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, result.isValid),
          icon: const Icon(Icons.check),
          label: const Text('Finish Review'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _runValidation,
          child: const Text('Recalculate'),
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
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to validate print specifications',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _controller.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _runValidation,
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
        onPressed: _runValidation,
        child: const Text('Calculate Specifications'),
      ),
    );
  }
}
