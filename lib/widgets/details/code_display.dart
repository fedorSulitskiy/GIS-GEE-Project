import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/googlecode.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:frontend/helpers/custom_icons/custom_icons_icons.dart';
import 'package:frontend/app_theme.dart';

/// Widget to display source code of each algorithms.
class CodeDisplayWidget extends StatelessWidget {
  const CodeDisplayWidget(
      {super.key, required this.code, required this.apiType});

  /// Code displayed to the user.
  final String code;

  /// If 1 -> python api . If 0 -> JS api.
  final int apiType;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 10,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              SizedBox(
                width: 570.0,
                child: HighlightView(
                  code,
                  language: apiType == 1 ? 'python' : 'javascript',
                  theme: googlecodeTheme,
                  padding: const EdgeInsets.all(12.0),
                  textStyle: GoogleFonts.sourceCodePro(),
                ),
              ),
              Container(
                // height: 40.0,
                width: 570.0,
                decoration: const BoxDecoration(
                  color: GeeLogicColourScheme.lightGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 12.0,
                    left: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      apiType == 1
                          ? const Row(
                              children: [
                                Icon(CustomIcons.python,
                                    color: GeeLogicColourScheme.iconGrey),
                                Text('Python API'),
                              ],
                            )
                          : const Row(
                              children: [
                                Icon(CustomIcons.jsSquare,
                                    color: GeeLogicColourScheme.iconGrey),
                                Text('JavaScript API'),
                              ],
                            ),
                      CopyButton(code: code),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Copy button to copy the code to clipboard.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.code});

  final String code;

  @override
  CopyButtonState createState() => CopyButtonState();
}

class CopyButtonState extends State<CopyButton> {
  bool isCopied = false;

  void _copyToClipboard() {
    setState(() {
      isCopied = true;
    });

    Clipboard.setData(ClipboardData(text: widget.code));

    Timer(const Duration(seconds: 3), () {
      setState(() {
        isCopied = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isCopied
          ? const Text('Copied!')
          : const Icon(
              Icons.copy,
              size: 20.0,
            ),
      onPressed: _copyToClipboard,
    );
  }
}
