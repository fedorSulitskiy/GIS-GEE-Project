import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/googlecode.dart';

import 'package:frontend/providers/input_code_providers.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/widgets/input/verify_button.dart';

/// Python code set-up to allow the user easier way to input valid geemap code.
const pythonDefaultCode =
    "# Create a map using GEE API and geemap\nMap = geemap.Map(\n\t**default_options,\n\tcenter=[21.79, 70.87], \n\tzoom=3,\n)\n\n# Input your code here please!\n\n";
const javaScriptDefaultCode = "// Input your code here please!\n\n";

/// Widget to display the code input field.
class CodeInput extends ConsumerStatefulWidget {
  const CodeInput({super.key, required this.controller, this.width = 900.0});

  final CodeController controller;
  final double width;

  @override
  ConsumerState<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends ConsumerState<CodeInput> {
  /// Boolean to check if the code has been changed.
  var _codeChanged = false;

  @override
  Widget build(BuildContext context) {
    final currentCode = ref.watch(codeProvider);
    final isPython = ref.watch(apiLanguageProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              SizedBox(
                width: widget.width,
                child: CodeTheme(
                  data: const CodeThemeData(styles: googlecodeTheme),
                  child: CodeField(
                    controller: widget.controller,
                    textStyle: GoogleFonts.sourceCodePro(),
                    onChanged: (code) {
                      // Every time code changes send update to the provider.
                      ref.read(codeProvider.notifier).getCode(code);
                      // With change invalidate the code, since it is no longer the same.
                      // Meaning, one will not be able to submit code that has been changed and not verified
                      ref.read(isValidProvider.notifier).setValid(null);
                      setState(() {
                        _codeChanged = true;
                      });
                    },
                  ),
                ),
              ),
              Container(
                // height: 40.0,
                width: 900.0,
                decoration: const BoxDecoration(
                  color: GeeLogicColourScheme.backgroundColour,
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Python or JavaScript API
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    ref
                                        .read(apiLanguageProvider.notifier)
                                        .setLanguage(true);
                                    widget.controller.language = python;
                                    widget.controller.text = _codeChanged
                                        ? currentCode
                                        : pythonDefaultCode;
                                  });
                                },
                                child: Text(
                                  '<< Python',
                                  style: GoogleFonts.sourceCodePro(
                                    color: isPython
                                        ? GeeLogicColourScheme.blue
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '/',
                                style: GoogleFonts.sourceCodePro(
                                    fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    ref
                                        .read(apiLanguageProvider.notifier)
                                        .setLanguage(false);
                                    widget.controller.language = javascript;
                                    widget.controller.text = _codeChanged
                                        ? currentCode
                                        : javaScriptDefaultCode;
                                  });
                                },
                                child: Text(
                                  'JavaScript >>',
                                  style: GoogleFonts.sourceCodePro(
                                    color: isPython
                                        ? Colors.black87
                                        : GeeLogicColourScheme.yellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (!isPython &&
                              MediaQuery.of(context).size.width > 1360)
                            Text(
                              "JavaScript API doesn't always work with any code!",
                              style: GoogleFonts.sourceCodePro(
                                color: GeeLogicColourScheme.red,
                              ),
                            ),
                          // Verify code
                          const VerifyButton(),
                        ],
                      ),
                      if (!isPython && MediaQuery.of(context).size.width < 1360)
                        Text(
                          "JavaScript API doesn't always work with any code!",
                          style: GoogleFonts.sourceCodePro(
                            color: GeeLogicColourScheme.red,
                          ),
                        ),
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
