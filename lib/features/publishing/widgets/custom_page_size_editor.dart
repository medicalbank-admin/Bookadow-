import 'package:flutter/material.dart';

class CustomPageSizeEditor extends StatefulWidget {
  const CustomPageSizeEditor({
    super.key,
    required this.width,
    required this.height,
    required this.onChanged,
  });

  final double width;
  final double height;
  final void Function(double width, double height) onChanged;

  @override
  State<CustomPageSizeEditor> createState() =>
      _CustomPageSizeEditorState();
}

class _CustomPageSizeEditorState
    extends State<CustomPageSizeEditor> {
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  String? _widthError;
  String? _heightError;

  @override
  void initState() {
    super.initState();

    _widthController = TextEditingController(
      text: widget.width.toStringAsFixed(2),
    );

    _heightController = TextEditingController(
      text: widget.height.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(covariant CustomPageSizeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width &&
        double.tryParse(_widthController.text) != widget.width) {
      _widthController.text = widget.width.toStringAsFixed(2);
    }

    if (oldWidget.height != widget.height &&
        double.tryParse(_heightController.text) != widget.height) {
      _heightController.text = widget.height.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateDimensions() {
    final width = double.tryParse(_widthController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    setState(() {
      _widthError = width == null || width <= 0 || width > 20
          ? 'Enter a width between 0 and 20 inches.'
          : null;

      _heightError = height == null || height <= 0 || height > 20
          ? 'Enter a height between 0 and 20 inches.'
          : null;
    });

    if (_widthError == null && _heightError == null) {
      widget.onChanged(width!, height!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Page Dimensions',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Width',
                  suffixText: 'in',
                  errorText: _widthError,
                ),
                onChanged: (_) => _updateDimensions(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Height',
                  suffixText: 'in',
                  errorText: _heightError,
                ),
                onChanged: (_) => _updateDimensions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Maximum supported dimension: 20 inches.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
