
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/book_metadata_model.dart';

class BookMetadataSummaryWidget extends StatelessWidget {
  final BookMetadataModel metadata;
  final VoidCallback? onEdit;

  const BookMetadataSummaryWidget({
    super.key,
    required this.metadata,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Publication Details',
                    style: TextStyle(
                      color: AppTheme.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Edit metadata',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.blue,
                    ),
                  ),
              ],
            ),
            const Divider(height: 22),
            _item('Book Title', metadata.title),
            _item('Subtitle', metadata.subtitle),
            _item('Author', metadata.author),
            _item('Contributors', metadata.contributors),
            _item('ISBN', metadata.isbn),
            _item('Publisher', metadata.publisher),
            _item('Publication Date', metadata.publicationDate),
            _item('Edition', metadata.edition),
            _item('Language', metadata.language),
            _item('Country', metadata.countryOfPublication),
            _item('Categories', metadata.categories),
            _item('Keywords', metadata.keywords),
            _item('Series', metadata.seriesName),
            _item('Series Number', metadata.seriesNumber),
            _item('Website', metadata.website),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
