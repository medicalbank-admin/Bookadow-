
import 'package:flutter/material.dart';

import '../models/book_layout_model.dart';

class BookFormatSelector extends StatelessWidget {
  const BookFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onChanged,
  });

  final BookFormat selectedFormat;
  final ValueChanged<BookFormat> onChanged;

  static const Map<BookFormat, String> formatLabels = {
    BookFormat.pocket: 'Pocket (5 × 8 inches)',
    BookFormat.digest: 'Digest (5.5 × 8.5 inches)',
    BookFormat.trade: 'Trade Paperback (6 × 9 inches)',
    BookFormat.letter: 'US Letter (8.5 × 11 inches)',
    BookFormat.a4: 'A4 (8.27 × 11.69 inches)',
    BookFormat.a5: 'A5 (5.83 × 8.27 inches)',
    BookFormat.custom: 'Custom Size',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book Trim Size',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<BookFormat>(
          initialValue: selectedFormat,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.menu_book_outlined),
            hintText: 'Select book size',
          ),
          items: BookFormat.values.map((format) {
            return DropdownMenuItem<BookFormat>(
              value: format,
              child: Text(
                formatLabels[format] ?? format.name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (format) {
            if (format != null) {
              onChanged(format);
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          _description(selectedFormat),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _description(BookFormat format) {
    switch (format) {
      case BookFormat.pocket:
        return 'Compact size, suitable for pocket-sized books.';
      case BookFormat.digest:
        return 'A popular compact format for novels and general books.';
      case BookFormat.trade:
        return 'A common paperback size for novels and nonfiction.';
      case BookFormat.letter:
        return 'Suitable for workbooks, manuals, and larger documents.';
      case BookFormat.a4:
        return 'A standard international page size.';
      case BookFormat.a5:
        return 'A compact international book and document size.';
      case BookFormat.custom:
        return 'Set your own page width and height.';
    }
  }
}
