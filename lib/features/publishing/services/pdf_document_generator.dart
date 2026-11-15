import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/book_layout_model.dart';

class PdfDocumentGenerator {
  Future<Uint8List> generatePdf({
    required String bookTitle,
    required String authorName,
    required List<PdfChapterContent> chapters,
    required BookLayoutModel layout,
    String? subtitle,
    bool includeTitlePage = true,
    bool includePageNumbers = true,
    bool includeTableOfContents = true,
  }) async {
    final document = pw.Document(
      title: bookTitle,
      author: authorName,
      subject: 'BOOKADOW Book Publication',
      creator: 'BOOKADOW',
    );

    final pageFormat = PdfPageFormat(
      layout.effectivePageWidth * PdfPageFormat.inch,
      layout.effectivePageHeight * PdfPageFormat.inch,
    );

    final pageTheme = pw.PageTheme(
      pageFormat: pageFormat,
      orientation: layout.orientation == PageOrientation.landscape
          ? pw.PageOrientation.landscape
          : pw.PageOrientation.portrait,
      margin: pw.EdgeInsets.only(
        top: layout.topMargin * PdfPageFormat.inch,
        bottom: layout.bottomMargin * PdfPageFormat.inch,
        left: layout.insideMargin * PdfPageFormat.inch,
        right: layout.outsideMargin * PdfPageFormat.inch,
      ),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
        boldItalic: pw.Font.helveticaBoldOblique(),
      ),
      buildBackground: (context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            color: PdfColors.white,
          ),
        );
      },
    );

    if (includeTitlePage) {
      document.addPage(
        pw.Page(
          pageTheme: pageTheme,
          build: (context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    bookTitle,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null &&
                      subtitle.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 16),
                    pw.Text(
                      subtitle,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 45),
                  pw.Text(
                    authorName,
                    style: const pw.TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    if (includeTableOfContents) {
      document.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          header: _buildHeader(bookTitle, layout),
          footer: _buildFooter(layout, includePageNumbers),
          build: (context) {
            return [
              pw.Center(
                child: pw.Text(
                  'Contents',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 25),
              ...chapters.asMap().entries.map((entry) {
                final chapter = entry.value;

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          chapter.title,
                          style: const pw.TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Text(
                        '${entry.key + 1}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ];
          },
        ),
      );
    }

    for (final chapter in chapters) {
      document.addPage(
        pw.MultiPage(
          pageTheme: pageTheme,
          header: _buildHeader(bookTitle, layout),
          footer: _buildFooter(layout, includePageNumbers),
          build: (context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  chapter.title,
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              ..._buildParagraphs(
                chapter.text,
                layout,
              ),
            ];
          },
        ),
      );
    }

    return document.save();
  }

  List<pw.Widget> _buildParagraphs(
    String content,
    BookLayoutModel layout,
  ) {
    final paragraphs = content
        .replaceAll('\r\n', '\n')
        .split('\n');

    return paragraphs.map((paragraph) {
      if (paragraph.trim().isEmpty) {
        return pw.SizedBox(height: layout.paragraphSpacing);
      }

      return pw.Padding(
        padding: pw.EdgeInsets.only(
          bottom: layout.paragraphSpacing,
          left: layout.firstLineIndent * PdfPageFormat.inch,
        ),
        child: pw.Text(
          paragraph,
          textAlign: pw.TextAlign.justify,
          style: pw.TextStyle(
            fontSize: layout.fontSize,
            lineSpacing: layout.lineSpacing,
          ),
        ),
      );
    }).toList();
  }

  pw.Widget Function(pw.Context) _buildHeader(
    String bookTitle,
    BookLayoutModel layout,
  ) {
    return (context) {
      if (!layout.showRunningHeaders) {
        return pw.SizedBox();
      }

      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Text(
          bookTitle,
          style: const pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      );
    };
  }

  pw.Widget Function(pw.Context) _buildFooter(
    BookLayoutModel layout,
    bool includePageNumbers,
  ) {
    return (context) {
      if (!includePageNumbers || !layout.showPageNumbers) {
        return pw.SizedBox();
      }

      return pw.Container(
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 12),
        child: pw.Text(
          '${context.pageNumber}',
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey700,
          ),
        ),
      );
    };
  }
}

class PdfChapterContent {
  const PdfChapterContent({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}
