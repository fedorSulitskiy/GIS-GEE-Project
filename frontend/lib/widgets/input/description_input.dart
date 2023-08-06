import 'package:flutter/material.dart';
import 'package:frontend/widgets/input/input_content.dart';
import 'package:languagetool_textfield/languagetool_textfield.dart';

class DescriptionInput extends StatelessWidget {
  const DescriptionInput(
      {super.key, required this.controller, this.width = 900.0});

  final LanguageToolController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LanguageToolTextField(
          padding: 8.0,
          controller: controller,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'What is your research all about?',
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: googleGreen),
            ),
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            constraints: BoxConstraints(
              maxWidth: width,
            ),
            contentPadding: const EdgeInsets.only(
              top: 8.0,
              bottom: 34.0,
              left: 8.0,
              right: 8.0,
            ),
          ),
          maxLines: null,
          minLines: 5,
          language: 'en-US',
          cursorColor: googleGreen,
        ),
        Positioned(
          bottom: 10.0,
          right: 20.0,
          child: Text(
            'Spelling and grammar checking courtesy of LanguageTool',
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontSize: 12.0),
          ),
        ),
      ],
    );
  }
}
