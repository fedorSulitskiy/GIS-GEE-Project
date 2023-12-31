import 'package:flutter/material.dart';
import 'package:frontend/models/tag.dart';
import 'package:frontend/widgets/common/tag_bubble_plain.dart';

/// A simple widget to display a list of tags.
class TagsDisplay extends StatelessWidget {
  const TagsDisplay({super.key, required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 4.0,
        runSpacing: 4.0,
        children: tags.map((tag) {
          return TagBubblePlain(
            title: tag.tagName,
            id: tag.tagId,
          );
        }).toList(),
      ),
    );
  }
}
