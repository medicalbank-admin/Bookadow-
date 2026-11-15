import 'package:flutter/material.dart';

import '../models/book_layout_model.dart';

class InteriorPagePreview extends StatelessWidget {
  const InteriorPagePreview({
    super.key,
    required this.layout,
    this.chapterTitle = 'Chapter One',
    this.sampleText =
        'Every great book begins with an idea. '
        'A writer gives that idea structure, meaning, '
        'and a voice that readers can understand.\n\n'
        'The pages of a book should feel comfortable '
        'to read. Proper margins, clear typography, '
        'and balanced spacing help create a professional '
        'reading experience.',
  });

  final BookLayoutModel layout;
  final String chapterTitle;
  final String sampleText;

  @override
  Widget build(BuildContext context) {
    final pageWidth = layout.effectivePageWidth;
    final pageHeight = layout.effectivePageHeight;

    return Center(
      child: AspectRatio(
        aspectRatio: pageWidth / pageHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth *
                ((layout.insideMargin + layout.outsideMargin) /
                    pageWidth);

            final verticalPadding =
                constraints.maxHeight *
                ((layout.topMargin + layout.bottomMargin) /
                    pageHeight);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (layout.showRunningHeaders)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'BOOKADOW',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 7,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      chapterTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: layout.fontFamily,
                        fontSize: layout.fontSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      flex: 5,
                      child: Text(
                        sampleText,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontFamily: layout.fontFamily,
                          fontSize: layout.fontSize,
                          height: layout.lineSpacing,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (layout.showPageNumbers)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: layout.fontFamily,
                            fontSize: 9,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
