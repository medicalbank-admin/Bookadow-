
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

class WordDocumentGenerator {
  Uint8List generateDocument({
    required String bookTitle,
    required String authorName,
    required List<WordChapterContent> chapters,
    String? subtitle,
    String? description,
  }) {
    final archive = Archive();

    _addFile(
      archive,
      '[Content_Types].xml',
      _contentTypesXml,
    );

    _addFile(
      archive,
      '_rels/.rels',
      _rootRelationshipsXml,
    );

    _addFile(
      archive,
      'word/_rels/document.xml.rels',
      _documentRelationshipsXml,
    );

    _addFile(
      archive,
      'word/styles.xml',
      _stylesXml,
    );

    _addFile(
      archive,
      'word/document.xml',
      _buildDocumentXml(
        bookTitle: bookTitle,
        authorName: authorName,
        chapters: chapters,
        subtitle: subtitle,
        description: description,
      ),
    );

    final encoded = ZipEncoder().encode(archive);

    if (encoded == null) {
      throw Exception(
        'Unable to generate Word document.',
      );
    }

    return Uint8List.fromList(encoded);
  }

  void _addFile(
    Archive archive,
    String name,
    String content,
  ) {
    final bytes = XmlDocument.parse(content).toXmlString(
      pretty: false,
    );

    final encoded = bytes.codeUnits;

    archive.addFile(
      ArchiveFile(
        name,
        encoded.length,
        encoded,
      ),
    );
  }

  String _buildDocumentXml({
    required String bookTitle,
    required String authorName,
    required List<WordChapterContent> chapters,
    String? subtitle,
    String? description,
  }) {
    final body = StringBuffer();

    body.write(
      _paragraph(
        bookTitle,
        style: 'Title',
        alignment: 'center',
      ),
    );

    if (subtitle != null && subtitle.trim().isNotEmpty) {
      body.write(
        _paragraph(
          subtitle,
          style: 'Subtitle',
          alignment: 'center',
        ),
      );
    }

    body.write(
      _paragraph(
        authorName,
        alignment: 'center',
      ),
    );

    body.write(_pageBreak());

    if (description != null && description.trim().isNotEmpty) {
      body.write(
        _paragraph(
          'About This Book',
          style: 'Heading1',
        ),
      );

      body.write(_paragraph(description));
      body.write(_pageBreak());
    }

    body.write(
      _paragraph(
        'Contents',
        style: 'Heading1',
      ),
    );

    for (final chapter in chapters) {
      body.write(
        _paragraph(
          chapter.title,
        ),
      );
    }

    body.write(_pageBreak());

    for (final chapter in chapters) {
      body.write(
        _paragraph(
          chapter.title,
          style: 'Heading1',
        ),
      );

      final paragraphs = chapter.text
          .replaceAll('\r\n', '\n')
          .split('\n');

      for (final paragraph in paragraphs) {
        if (paragraph.trim().isNotEmpty) {
          body.write(_paragraph(paragraph));
        }
      }

      body.write(_pageBreak());
    }

    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document
 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
 <w:body>
  ${body.toString()}
  <w:sectPr>
   <w:pgSz w:w="8640" w:h="12960"/>
   <w:pgMar
    w:top="1080"
    w:right="1080"
    w:bottom="1080"
    w:left="1080"/>
  </w:sectPr>
 </w:body>
</w:document>
''';
  }

  String _paragraph(
    String text, {
    String? style,
    String alignment = 'both',
  }) {
    final escaped = _escape(text);

    final styleXml = style == null
        ? ''
        : '<w:pStyle w:val="$style"/>';

    return '''
<w:p>
 <w:pPr>
  $styleXml
  <w:jc w:val="$alignment"/>
 </w:pPr>
 <w:r>
  <w:t xml:space="preserve">$escaped</w:t>
 </w:r>
</w:p>
''';
  }

  String _pageBreak() {
    return '''
<w:p>
 <w:r>
  <w:br w:type="page"/>
 </w:r>
</w:p>
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

  static const String _contentTypesXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
 <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
 <Default Extension="xml" ContentType="application/xml"/>
 <Override PartName="/word/document.xml"
 ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
 <Override PartName="/word/styles.xml"
 ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
</Types>
''';

  static const String _rootRelationshipsXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Id="rId1"
 Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
 Target="word/document.xml"/>
</Relationships>
''';

  static const String _documentRelationshipsXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
 <Relationship Id="rId1"
 Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles"
 Target="styles.xml"/>
</Relationships>
''';

  static const String _stylesXml = '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
 <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
  <w:name w:val="Normal"/>
  <w:rPr>
   <w:rFonts w:ascii="Georgia" w:hAnsi="Georgia"/>
   <w:sz w:val="22"/>
  </w:rPr>
 </w:style>
 <w:style w:type="paragraph" w:styleId="Title">
  <w:name w:val="Title"/>
  <w:rPr>
   <w:b/>
   <w:sz w:val="36"/>
  </w:rPr>
 </w:style>
 <w:style w:type="paragraph" w:styleId="Subtitle">
  <w:name w:val="Subtitle"/>
  <w:rPr>
   <w:i/>
   <w:sz w:val="26"/>
  </w:rPr>
 </w:style>
 <w:style w:type="paragraph" w:styleId="Heading1">
  <w:name w:val="heading 1"/>
  <w:rPr>
   <w:b/>
   <w:sz w:val="30"/>
  </w:rPr>
 </w:style>
</w:styles>
''';
}

class WordChapterContent {
  const WordChapterContent({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;
}
