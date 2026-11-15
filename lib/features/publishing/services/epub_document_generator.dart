import 'dart:convert';

import 'package:archive/archive.dart';

class EpubDocumentGenerator {
  List<int> generateEpub({
    required String bookTitle,
    required String authorName,
    required List<EpubChapterContent> chapters,
    String? subtitle,
    String languageCode = 'en',
    String? description,
  }) {
    if (chapters.isEmpty) {
      throw ArgumentError(
        'An EPUB must contain at least one chapter.',
      );
    }

    final archive = Archive();

    final bookIdentifier =
        'urn:uuid:bookadow-${DateTime.now().microsecondsSinceEpoch}';

    final modified = DateTime.now()
        .toUtc()
        .toIso8601String()
        .split('.')
        .first;

    _addTextFile(
      archive,
      'mimetype',
      'application/epub+zip',
    );

    _addTextFile(
      archive,
      'META-INF/container.xml',
      _containerXml,
    );

    _addTextFile(
      archive,
      'OEBPS/content.opf',
      _buildPackageDocument(
        bookTitle: bookTitle,
        authorName: authorName,
        identifier: bookIdentifier,
        modified: modified,
        languageCode: languageCode,
        description: description,
        chapters: chapters,
      ),
    );

    _addTextFile(
      archive,
      'OEBPS/nav.xhtml',
      _buildNavigationDocument(
        bookTitle: bookTitle,
        chapters: chapters,
      ),
    );

    _addTextFile(
      archive,
      'OEBPS/styles.css',
      _styles,
    );

    if (subtitle != null && subtitle.trim().isNotEmpty) {
      _addTextFile(
        archive,
        'OEBPS/title.xhtml',
        _buildTitlePage(
          bookTitle: bookTitle,
          authorName: authorName,
          subtitle: subtitle,
        ),
      );
    }

    for (var i = 0; i < chapters.length; i++) {
      final chapter = chapters[i];

      _addTextFile(
        archive,
        'OEBPS/chapter_${i + 1}.xhtml',
        _buildChapterDocument(
          chapter: chapter,
          index: i,
        ),
      );
    }

    final encoder = ZipEncoder();

    final encoded = encoder.encode(archive);

    if (encoded == null) {
      throw Exception('Unable to create EPUB archive.');
    }

    return encoded;
  }

  void _addTextFile(
    Archive archive,
    String fileName,
    String content,
  ) {
    final bytes = utf8.encode(content);

    archive.addFile(
      ArchiveFile(
        fileName,
        bytes.length,
        bytes,
      ),
    );
  }

  String _buildPackageDocument({
    required String bookTitle,
    required String authorName,
    required String identifier,
    required String modified,
    required String languageCode,
    required String? description,
    required List<EpubChapterContent> chapters,
  }) {
    final manifest = StringBuffer();
    final spine = StringBuffer();

    if (chapters.isNotEmpty) {
      manifest.writeln(
        '<item id="nav" href="nav.xhtml" '
        'media-type="application/xhtml+xml" properties="nav"/>',
      );

      manifest.writeln(
        '<item id="css" href="styles.css" '
        'media-type="text/css"/>',
      );

      if (chapters.isNotEmpty) {
        manifest.writeln(
          '<item id="title" href="title.xhtml" '
          'media-type="application/xhtml+xml"/>',
        );

        spine.writeln('<itemref idref="title"/>');
      }

      for (var i = 0; i < chapters.length; i++) {
        manifest.writeln(
          '<item id="chapter${i + 1}" '
          'href="chapter_${i + 1}.xhtml" '
          'media-type="application/xhtml+xml"/>',
        );

        spine.writeln(
          '<itemref idref="chapter${i + 1}"/>',
        );
      }
    }

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf"
 version="3.0" unique-identifier="book-id" xml:lang="${_escape(languageCode)}">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">${_escape(identifier)}</dc:identifier>
    <dc:title>${_escape(bookTitle)}</dc:title>
    <dc:creator>${_escape(authorName)}</dc:creator>
    <dc:language>${_escape(languageCode)}</dc:language>
    ${description == null ? '' : '<dc:description>${_escape(description)}</dc:description>'}
    <meta property="dcterms:modified">${modified}Z</meta>
  </metadata>
  <manifest>
    ${manifest.toString()}
  </manifest>
  <spine>
    ${spine.toString()}
  </spine>
</package>
''';
  }

  String _buildNavigationDocument({
    required String bookTitle,
    required List<EpubChapterContent> chapters,
  }) {
    final items = StringBuffer();

    for (var i = 0; i < chapters.length; i++) {
      items.writeln(
        '<li><a href="chapter_${i + 1}.xhtml">'
        '${_escape(chapters[i].title)}</a></li>',
      );
    }

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml"
 xmlns:epub="http://www.idpf.org/2007/ops">
<head>
  <title>Contents</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <nav epub:type="toc" id="toc">
    <h1>${_escape(bookTitle)}</h1>
    <ol>${items.toString()}</ol>
  </nav>
</body>
</html>
''';
  }

  String _buildTitlePage({
    required String bookTitle,
    required String authorName,
    required String subtitle,
  }) {
    return '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>${_escape(bookTitle)}</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body class="title-page">
  <h1>${_escape(bookTitle)}</h1>
  <h2>${_escape(subtitle)}</h2>
  <p class="author">${_escape(authorName)}</p>
</body>
</html>
''';
  }

  String _buildChapterDocument({
    required EpubChapterContent chapter,
    required int index,
  }) {
    final paragraphs = chapter.text
        .replaceAll('\r\n', '\n')
        .split('\n')
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .map(
          (paragraph) => '<p>${_escape(paragraph)}</p>',
        )
        .join('\n');

    return '''
<?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>${_escape(chapter.title)}</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
  <section epub:type="chapter">
    <h1>${_escape(chapter.title)}</h1>
    $paragraphs
  </section>
</body>
</html>
''';
  }

  String _escape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static const String _containerXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0"
 xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf"
     media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>
''';

  static const String _styles = '''
body {
  font-family: Georgia, serif;
  line-height: 1.6;
  margin: 5%;
}
h1 {
  text-align: center;
  margin-bottom: 2em;
}
h2 {
  text-align: center;
}
p {
  text-align: justify;
  margin-bottom: 1em;
}
.title-page {
  text-align: center;
  margin-top: 25%;
}
.author {
  margin-top: 3em;
}
''';
}

class EpubChapterContent {
  const EpubChapterContent({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}
