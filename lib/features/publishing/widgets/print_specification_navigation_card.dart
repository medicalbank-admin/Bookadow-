
import 'package:flutter/material.dart';

import '../screens/print_specification_screen.dart';

class PrintSpecificationNavigationCard extends StatelessWidget {
  final double trimWidthInches;
  final double trimHeightInches;
  final int pageCount;
  final double paperCaliperInches;
  final double bleedInches;
  final double minimumSpineWidthInches;
  final double maximumSpineWidthInches;
  final ValueChanged<bool>? onReviewCompleted;

  const PrintSpecificationNavigationCard({
    super.key,
    required this.trimWidthInches,
    required this.trimHeightInches,
    required this.pageCount,
    required this.paperCaliperInches,
    this.bleedInches = 0.125,
    this.minimumSpineWidthInches = 0,
    this.maximumSpineWidthInches = 10,
    this.onReviewCompleted,
  });

  Future<void> _openReview(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PrintSpecificationScreen(
          trimWidthInches: trimWidthInches,
          trimHeightInches: trimHeightInches,
          pageCount: pageCount,
          paperCaliperInches: paperCaliperInches,
          bleedInches: bleedInches,
          minimumSpineWidthInches: minimumSpineWidthInches,
          maximumSpineWidthInches: maximumSpineWidthInches,
        ),
      ),
    );

    if (result != null) {
      onReviewCompleted?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openReview(context),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.print_outlined,
                  size: 27,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Print Specifications',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Check trim size, spine and cover dimensions.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
