
import 'package:flutter/material.dart';

import '../models/book_layout_model.dart';

class PageLayoutOptions extends StatelessWidget {
  const PageLayoutOptions({
    super.key,
    required this.orientation,
    required this.showPageNumbers,
    required this.showRunningHeaders,
    required this.firstLineIndent,
    required this.onChanged,
  });

  final PageOrientation orientation;
  final bool showPageNumbers;
  final bool showRunningHeaders;
  final double firstLineIndent;

  final void Function({
    PageOrientation? orientation,
    bool? showPageNumbers,
    bool? showRunningHeaders,
    double? firstLineIndent,
  }) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Layout Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PageOrientation>(
          initialValue: orientation,
          decoration: const InputDecoration(
            labelText: 'Page Orientation',
            prefixIcon: Icon(Icons.crop_rotate),
          ),
          items: const [
            DropdownMenuItem(
              value: PageOrientation.portrait,
              child: Text('Portrait'),
            ),
            DropdownMenuItem(
              value: PageOrientation.landscape,
              child: Text('Landscape'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(orientation: value);
            }
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Show Page Numbers'),
          subtitle: const Text(
            'Display page numbers in the book interior.',
          ),
          value: showPageNumbers,
          onChanged: (value) {
            onChanged(showPageNumbers: value);
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Running Headers'),
          subtitle: const Text(
            'Display a header at the top of pages.',
          ),
          value: showRunningHeaders,
          onChanged: (value) {
            onChanged(showRunningHeaders: value);
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'First-line Indentation',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text('${firstLineIndent.toStringAsFixed(2)} in'),
          ],
        ),
        Slider(
          value: firstLineIndent.clamp(0, 0.75).toDouble(),
          min: 0,
          max: 0.75,
          divisions: 15,
          onChanged: (value) {
            onChanged(firstLineIndent: value);
          },
        ),
      ],
    );
  }
}
