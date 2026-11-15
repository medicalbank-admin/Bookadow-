
import 'package:flutter/material.dart';

class PageMarginEditor extends StatelessWidget {
  const PageMarginEditor({
    super.key,
    required this.topMargin,
    required this.bottomMargin,
    required this.insideMargin,
    required this.outsideMargin,
    required this.onChanged,
  });

  final double topMargin;
  final double bottomMargin;
  final double insideMargin;
  final double outsideMargin;

  final void Function({
    double? top,
    double? bottom,
    double? inside,
    double? outside,
  }) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Margins',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        _buildMarginSlider(
          label: 'Top Margin',
          value: topMargin,
          onChanged: (value) => onChanged(top: value),
        ),
        _buildMarginSlider(
          label: 'Bottom Margin',
          value: bottomMargin,
          onChanged: (value) => onChanged(bottom: value),
        ),
        _buildMarginSlider(
          label: 'Inside Margin',
          value: insideMargin,
          onChanged: (value) => onChanged(inside: value),
        ),
        _buildMarginSlider(
          label: 'Outside Margin',
          value: outsideMargin,
          onChanged: (value) => onChanged(outside: value),
        ),
      ],
    );
  }

  Widget _buildMarginSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final safeValue = value.clamp(0.25, 2.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.toStringAsFixed(2)} in',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: safeValue,
            min: 0.25,
            max: 2.0,
            divisions: 35,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
