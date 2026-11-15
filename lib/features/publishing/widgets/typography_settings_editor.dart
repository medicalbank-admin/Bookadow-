
import 'package:flutter/material.dart';

class TypographySettingsEditor extends StatelessWidget {
  const TypographySettingsEditor({
    super.key,
    required this.fontFamily,
    required this.fontSize,
    required this.lineSpacing,
    required this.paragraphSpacing,
    required this.onChanged,
  });

  final String fontFamily;
  final double fontSize;
  final double lineSpacing;
  final double paragraphSpacing;

  final void Function({
    String? fontFamily,
    double? fontSize,
    double? lineSpacing,
    double? paragraphSpacing,
  }) onChanged;

  static const List<String> availableFonts = [
    'Georgia',
    'Times New Roman',
    'Arial',
    'Roboto',
    'Garamond',
    'Palatino',
    'Courier New',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Typography Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: availableFonts.contains(fontFamily)
              ? fontFamily
              : 'Georgia',
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Font Family',
            prefixIcon: Icon(Icons.font_download_outlined),
          ),
          items: availableFonts.map((font) {
            return DropdownMenuItem(
              value: font,
              child: Text(
                font,
                style: TextStyle(fontFamily: font),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(fontFamily: value);
            }
          },
        ),
        const SizedBox(height: 18),
        _buildSlider(
          label: 'Font Size',
          value: fontSize.clamp(8, 24).toDouble(),
          displayValue: '${fontSize.toStringAsFixed(1)} pt',
          min: 8,
          max: 24,
          divisions: 32,
          onChanged: (value) => onChanged(fontSize: value),
        ),
        _buildSlider(
          label: 'Line Spacing',
          value: lineSpacing.clamp(1.0, 2.5).toDouble(),
          displayValue: '${lineSpacing.toStringAsFixed(2)}×',
          min: 1.0,
          max: 2.5,
          divisions: 15,
          onChanged: (value) => onChanged(lineSpacing: value),
        ),
        _buildSlider(
          label: 'Paragraph Spacing',
          value: paragraphSpacing.clamp(0, 24).toDouble(),
          displayValue: '${paragraphSpacing.toStringAsFixed(1)} pt',
          min: 0,
          max: 24,
          divisions: 24,
          onChanged: (value) =>
              onChanged(paragraphSpacing: value),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
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
                displayValue,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
