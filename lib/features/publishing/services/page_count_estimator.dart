import '../models/book_layout_model.dart';

class PageCountEstimator {
  PageCountEstimator._();

  /// Estimates the number of manuscript pages.
  ///
  /// This is a planning estimate, not final pagination.
  /// Exact page counts require rendering the manuscript
  /// with the selected fonts and layout.
  static int estimatePageCount({
    required int wordCount,
    required BookLayoutModel layout,
    int additionalPages = 0,
  }) {
    if (wordCount < 0) {
      throw ArgumentError.value(
        wordCount,
        'wordCount',
        'Word count cannot be negative.',
      );
    }

    if (additionalPages < 0) {
      throw ArgumentError.value(
        additionalPages,
        'additionalPages',
        'Additional pages cannot be negative.',
      );
    }

    if (wordCount == 0) {
      return additionalPages;
    }

    final wordsPerPage = estimateWordsPerPage(layout);

    if (wordsPerPage <= 0) {
      throw ArgumentError(
        'The selected layout does not provide enough usable page space.',
      );
    }

    final manuscriptPages = (wordCount / wordsPerPage).ceil();

    return manuscriptPages + additionalPages;
  }

  /// Estimates how many words fit on one page.
  ///
  /// Uses approximate typography measurements.
  static int estimateWordsPerPage(BookLayoutModel layout) {
    final usableWidthPoints = layout.usableWidth * 72;
    final usableHeightPoints = layout.usableHeight * 72;

    if (usableWidthPoints <= 0 || usableHeightPoints <= 0) {
      throw ArgumentError(
        'Page margins leave no usable writing area.',
      );
    }

    if (layout.fontSize <= 0 || layout.lineSpacing <= 0) {
      throw ArgumentError(
        'Font size and line spacing must be greater than zero.',
      );
    }

    // Approximate average word width, including a space.
    final averageWordWidth = layout.fontSize * 2.7;

    // Approximate number of words per line.
    final wordsPerLine =
        (usableWidthPoints / averageWordWidth).floor();

    // Approximate line height in points.
    final lineHeight = layout.fontSize * layout.lineSpacing;

    // Approximate number of text lines per page.
    final linesPerPage =
        (usableHeightPoints / lineHeight).floor();

    if (wordsPerLine <= 0 || linesPerPage <= 0) {
      return 0;
    }

    // Reserve a small percentage for headings and paragraph gaps.
    final estimatedWords =
        (wordsPerLine * linesPerPage * 0.88).floor();

    return estimatedWords < 1 ? 1 : estimatedWords;
  }

  /// Estimates the number of pages for several manuscript sections.
  static int estimateTotalPages({
    required List<int> sectionWordCounts,
    required BookLayoutModel layout,
    int frontMatterPages = 0,
    int backMatterPages = 0,
  }) {
    if (frontMatterPages < 0 || backMatterPages < 0) {
      throw ArgumentError(
        'Additional page counts cannot be negative.',
      );
    }

    var totalPages = frontMatterPages + backMatterPages;

    for (final wordCount in sectionWordCounts) {
      totalPages += estimatePageCount(
        wordCount: wordCount,
        layout: layout,
      );
    }

    return totalPages;
  }

  /// Estimates a page count rounded up to the next even number.
  ///
  /// Useful for preliminary print planning. Actual printer
  /// requirements may differ.
  static int roundUpToEvenPages(int pageCount) {
    if (pageCount < 0) {
      throw ArgumentError.value(
        pageCount,
        'pageCount',
        'Page count cannot be negative.',
      );
    }

    if (pageCount.isEven) {
      return pageCount;
    }

    return pageCount + 1;
  }
}

