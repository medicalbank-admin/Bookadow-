import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/book_cover_model.dart';

class CoverPreviewWidget extends StatelessWidget {
  const CoverPreviewWidget({
    super.key,
    required this.cover,
    this.showLabels = true,
    this.showShadow = true,
  });

  final BookCoverModel cover;
  final bool showLabels;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final preview = AspectRatio(
      aspectRatio: 1.65,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _buildBackCover(),
          ),
          SizedBox(
            width: 12,
            child: ColoredBox(
              color: Color(cover.spineBackgroundColor),
              child: RotatedBox(
                quarterTurns: 3,
                child: Center(
                  child: Text(
                    cover.showSpineTitle ? cover.title : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(cover.spineTextColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: _buildFrontCover(),
          ),
        ],
      ),
    );

    return Container(
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: preview,
      ),
    );
  }

  Widget _buildFrontCover() {
    return Container(
      color: Color(cover.frontBackgroundColor),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            cover.title.isEmpty ? 'Your Book Title' : cover.title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(cover.titleTextColor),
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: cover.titleFontFamily,
            ),
          ),
          if (cover.showSubtitle && cover.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cover.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(cover.subtitleTextColor),
                fontSize: 9,
                fontFamily: cover.subtitleFontFamily,
              ),
            ),
          ],
          const Spacer(),
          if (cover.showAuthorName)
            Text(
              cover.authorName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(cover.authorTextColor),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (cover.showPublisherName &&
              cover.publisherName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cover.publisherName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(cover.authorTextColor),
                fontSize: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackCover() {
    return Container(
      color: Color(cover.backBackgroundColor),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabels)
            const Text(
              'ABOUT THIS BOOK',
              style: TextStyle(
                color: AppTheme.gold,
                fontSize: 7,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              cover.backCoverBlurb.isEmpty
                  ? 'Your book description will appear here.'
                  : cover.backCoverBlurb,
              maxLines: 9,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(cover.backTextColor),
                fontSize: 8,
                height: 1.5,
              ),
            ),
          ),
          if (cover.authorBio.isNotEmpty)
            Text(
              cover.authorBio,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(cover.backTextColor).withValues(alpha: 0.8),
                fontSize: 7,
              ),
            ),
          if (cover.showBarcodeArea)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 42,
                height: 23,
                color: Colors.white,
                padding: const EdgeInsets.all(3),
                child: const Icon(
                  Icons.barcode_reader,
                  size: 16,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
