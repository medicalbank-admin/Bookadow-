import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../controllers/publishing_controller.dart';
import '../models/book_cover_model.dart';

class CoverDesignerScreen extends StatefulWidget {
  const CoverDesignerScreen({
    super.key,
    required this.controller,
  });

  final PublishingController controller;

  @override
  State<CoverDesignerScreen> createState() =>
      _CoverDesignerScreenState();
}

class _CoverDesignerScreenState extends State<CoverDesignerScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _authorController;
  late final TextEditingController _blurbController;
  late final TextEditingController _bioController;
  late final TextEditingController _publisherController;

  static const List<int> _colorOptions = [
    0xFF142238,
    0xFF315B87,
    0xFF263D35,
    0xFF702F3B,
    0xFF452C55,
    0xFFB58A54,
    0xFFE8DCC8,
    0xFFFFFFFF,
    0xFF202B38,
    0xFF000000,
  ];

  @override
  void initState() {
    super.initState();

    final cover = widget.controller.cover;

    _titleController = TextEditingController(text: cover.title);
    _subtitleController =
        TextEditingController(text: cover.subtitle);
    _authorController =
        TextEditingController(text: cover.authorName);
    _blurbController =
        TextEditingController(text: cover.backCoverBlurb);
    _bioController =
        TextEditingController(text: cover.authorBio);
    _publisherController =
        TextEditingController(text: cover.publisherName);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _authorController.dispose();
    _blurbController.dispose();
    _bioController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  BookCoverModel get _cover => widget.controller.cover;

  void _updateCover(BookCoverModel updated) {
    widget.controller.updateCover(updated);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cover Designer'),
            actions: [
              IconButton(
                tooltip: 'Preview cover',
                icon: const Icon(Icons.visibility_outlined),
                onPressed: _showLargePreview,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeading(),
              const SizedBox(height: 18),
              _buildCoverPreview(),
              const SizedBox(height: 24),
              _buildTextSettings(),
              const SizedBox(height: 24),
              _buildColorSettings(),
              const SizedBox(height: 24),
              _buildSpineSettings(),
              const SizedBox(height: 24),
              _buildBackCoverSettings(),
              const SizedBox(height: 24),
              _buildVisibilitySettings(),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Finish Cover Design'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Design your book cover',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Customize all three surfaces of your book: '
          'front, back, and spine.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCoverPreview() {
    final cover = _cover;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIVE COVER PREVIEW',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AspectRatio(
              aspectRatio: 1.65,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 100,
                    child: _coverSurface(
                      background: cover.backBackgroundColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            cover.backCoverBlurb.isEmpty
                                ? 'Back cover description'
                                : cover.backCoverBlurb,
                            maxLines: 7,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(cover.backTextColor),
                              fontSize: 7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 13,
                    color: Color(cover.spineBackgroundColor),
                    alignment: Alignment.center,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        cover.showSpineTitle
                            ? (cover.title.isEmpty
                                ? 'BOOK TITLE'
                                : cover.title)
                            : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(cover.spineTextColor),
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 100,
                    child: _coverSurface(
                      background: cover.frontBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              cover.title.isEmpty
                                  ? 'YOUR BOOK TITLE'
                                  : cover.title,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(cover.titleColor),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (cover.showSubtitle &&
                                cover.subtitle.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Text(
                                cover.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(cover.subtitleColor),
                                  fontSize: 7,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (cover.showAuthorName)
                              Text(
                                cover.authorName.isEmpty
                                    ? 'AUTHOR NAME'
                                    : cover.authorName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(cover.authorColor),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Back cover     Spine     Front cover',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverSurface({
    required int background,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(background),
        border: Border.all(
          color: Colors.black12,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildTextSettings() {
    return _sectionCard(
      title: 'Front cover text',
      icon: Icons.title,
      children: [
        _textField(
          label: 'Book title',
          controller: _titleController,
          onChanged: (value) {
            _updateCover(_cover.copyWith(title: value));
          },
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Subtitle',
          controller: _subtitleController,
          onChanged: (value) {
            _updateCover(_cover.copyWith(subtitle: value));
          },
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Author name',
          controller: _authorController,
          onChanged: (value) {
            _updateCover(_cover.copyWith(authorName: value));
          },
        ),
      ],
    );
  }

  Widget _buildColorSettings() {
    return _sectionCard(
      title: 'Cover colors',
      icon: Icons.color_lens_outlined,
      children: [
        _colorSelector(
          label: 'Front background',
          color: _cover.frontBackgroundColor,
          onSelected: (value) {
            _updateCover(
              _cover.copyWith(frontBackgroundColor: value),
            );
          },
        ),
        _colorSelector(
          label: 'Back background',
          color: _cover.backBackgroundColor,
          onSelected: (value) {
            _updateCover(
              _cover.copyWith(backBackgroundColor: value),
            );
          },
        ),
        _colorSelector(
          label: 'Spine background',
          color: _cover.spineBackgroundColor,
          onSelected: (value) {
            _updateCover(
              _cover.copyWith(spineBackgroundColor: value),
            );
          },
        ),
        const Divider(height: 24),
        _colorSelector(
          label: 'Title text',
          color: _cover.titleColor,
          onSelected: (value) {
            _updateCover(_cover.copyWith(titleColor: value));
          },
        ),
        _colorSelector(
          label: 'Subtitle text',
          color: _cover.subtitleColor,
          onSelected: (value) {
            _updateCover(_cover.copyWith(subtitleColor: value));
          },
        ),
        _colorSelector(
          label: 'Author text',
          color: _cover.authorColor,
          onSelected: (value) {
            _updateCover(_cover.copyWith(authorColor: value));
          },
        ),
      ],
    );
  }

  Widget _buildSpineSettings() {
    return _sectionCard(
      title: 'Spine and print dimensions',
      icon: Icons.straighten,
      children: [
        Text(
          'Spine width: '
          '${_cover.spineWidthInches.toStringAsFixed(3)} inches',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _cover.spineWidthInches.clamp(0.05, 2.0).toDouble(),
          min: 0.05,
          max: 2.0,
          divisions: 39,
          onChanged: (value) {
            _updateCover(
              _cover.copyWith(spineWidthInches: value),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Print bleed: '
          '${_cover.bleedInches.toStringAsFixed(3)} inches',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _cover.bleedInches.clamp(0.0, 0.25).toDouble(),
          min: 0,
          max: 0.25,
          divisions: 10,
          onChanged: (value) {
            _updateCover(
              _cover.copyWith(bleedInches: value),
            );
          },
        ),
        const Text(
          'Use the paper thickness and printer specifications '
          'to determine the final spine and bleed measurements.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildBackCoverSettings() {
    return _sectionCard(
      title: 'Back cover content',
      icon: Icons.article_outlined,
      children: [
        _textField(
          label: 'Book description / blurb',
          controller: _blurbController,
          maxLines: 5,
          onChanged: (value) {
            _updateCover(
              _cover.copyWith(backCoverBlurb: value),
            );
          },
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Author biography',
          controller: _bioController,
          maxLines: 4,
          onChanged: (value) {
            _updateCover(_cover.copyWith(authorBio: value));
          },
        ),
        const SizedBox(height: 12),
        _textField(
          label: 'Publisher name',
          controller: _publisherController,
          onChanged: (value) {
            _updateCover(_cover.copyWith(publisherName: value));
          },
        ),
      ],
    );
  }

  Widget _buildVisibilitySettings() {
    return _sectionCard(
      title: 'Cover elements',
      icon: Icons.tune,
      children: [
        _switch(
          'Show subtitle',
          _cover.showSubtitle,
          (value) => _updateCover(
            _cover.copyWith(showSubtitle: value),
          ),
        ),
        _switch(
          'Show author name',
          _cover.showAuthorName,
          (value) => _updateCover(
            _cover.copyWith(showAuthorName: value),
          ),
        ),
        _switch(
          'Show title on spine',
          _cover.showSpineTitle,
          (value) => _updateCover(
            _cover.copyWith(showSpineTitle: value),
          ),
        ),
        _switch(
          'Show author on spine',
          _cover.showSpineAuthor,
          (value) => _updateCover(
            _cover.copyWith(showSpineAuthor: value),
          ),
        ),
        _switch(
          'Reserve barcode area',
          _cover.showBarcodeArea,
          (value) => _updateCover(
            _cover.copyWith(showBarcodeArea: value),
          ),
        ),
        _switch(
          'Show publisher name',
          _cover.showPublisherName,
          (value) => _updateCover(
            _cover.copyWith(showPublisherName: value),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.blue),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _colorSelector({
    required String label,
    required int color,
    required ValueChanged<int> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          InkWell(
            onTap: () => _showColorPicker(
              label: label,
              selectedColor: color,
              onSelected: onSelected,
            ),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Color(color),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '#${color.toRadixString(16).substring(2).toUpperCase()}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showColorPicker({
    required String label,
    required int selectedColor,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(label),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _colorOptions.map((value) {
              final isSelected = value == selectedColor;

              return InkWell(
                onTap: () {
                  Navigator.pop(dialogContext, value);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color(value),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.gold
                          : Colors.black26,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 19,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      onSelected(selected);
    }
  }

  Widget _switch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 13),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showLargePreview() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Full Cover Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.65,
                  child: _buildCoverPreview(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
