import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/helpers/uri_parser/uri_parse.dart';
import 'package:http/http.dart' as http;

import 'package:frontend/providers/input_code_providers.dart';
import 'package:frontend/providers/input_map_html_code_provider.dart';
import 'package:frontend/app_theme.dart';

const double borderRadius = 15.0;
const List<double> buttonDimensions = [32.0, 80.0];

/// Button found at the bottom of the code input on input screen. It verifies
/// if the algorithm input by the user can be handled by the backend.
/// It sends an http POST request to the 'python API' and depending on if the
/// response status is successful will verify the algorithm.
class VerifyButton extends ConsumerStatefulWidget {
  const VerifyButton({super.key});

  @override
  ConsumerState<VerifyButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<VerifyButton> {
  List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.yellow;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  /// Determines if the function is waiting for response from the backend.
  var _isLoading = false;

  /// Custom [SnackBar] to display communication with the user, regarding validity
  /// of their inputs.
  SnackBar snackBar({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SnackBar(
      backgroundColor: color,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 45.0,
          ),
          const SizedBox(width: 5.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2), () {
      if (mounted) {
        setState(() {
          bottomColor = Colors.blue;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final code = ref.watch(codeProvider);
    final isValid = ref.watch(isValidProvider);
    final apiBool = ref.watch(apiLanguageProvider);
    final String apiType;
    if (apiBool) {
      apiType = 'python';
    } else {
      apiType = 'js';
    }
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedContainer(
              height: buttonDimensions[0],
              width: buttonDimensions[1],
              duration: const Duration(seconds: 2),
              curve: Curves.linear,
              onEnd: () {
                setState(() {
                  index = index + 1;
                  // animate the color
                  bottomColor = colorList[index % colorList.length];
                  topColor = colorList[(index + 1) % colorList.length];

                  // animate the alignment
                  begin = alignmentList[index % alignmentList.length];
                  end = alignmentList[(index + 2) % alignmentList.length];
                });
              },
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.circular(borderRadius)),
                gradient: LinearGradient(
                  begin: begin,
                  end: end,
                  colors: [bottomColor, topColor],
                ),
              ),
            ),
            SizedBox(
              height: buttonDimensions[0],
              width: buttonDimensions[1],
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                    ),
                  ),
                ),
                onPressed: () async {
                  // If code is empty or no new code has been added, tell user.
                  if (code.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      snackBar(
                        color: GeeLogicColourScheme.yellow,
                        icon: Icons.warning_rounded,
                        subtitle: "Please submit new code!",
                        title: "Old code",
                      ),
                    );
                    return;
                  }

                  // Establish context before async gap.
                  final messenger = ScaffoldMessenger.of(context);

                  // Initialise loading animation.
                  setState(() {
                    _isLoading = true;
                    colorList = [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow
                    ];
                  });

                  // Send request to the backend, to verify the code. If valid,
                  // set the [isValid] provider to true, else false. Furthermore
                  // the [mapWidgetHTMLCodeProvider] is set to the response body,
                  // which is the HTML code for the map widget.
                  final url = pythonUri('get_map_widget/$apiType');
                  final headers = {
                    'Content-Type': 'application/x-www-form-urlencoded'
                  };
                  final body = {'code': code};

                  final response =
                      await http.post(url, headers: headers, body: body);
                  ref
                      .read(mapWidgetHTMLCodeProvider.notifier)
                      .getCode(response.body);

                  // Stop loading animation.
                  setState(() {
                    _isLoading = false;
                  });

                  // Success
                  if (response.statusCode == 200) {
                    // Request was successful, handle the response here
                    ref.read(isValidProvider.notifier).setValid(true);
                    setState(() {
                      colorList = const [
                        Color.fromARGB(255, 59, 183, 143),
                        Color.fromARGB(255, 11, 171, 100),
                      ];
                    });
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      snackBar(
                        color: GeeLogicColourScheme.green,
                        icon: Icons.check_circle_outline_outlined,
                        subtitle: "Perfect, you can submit the algorithm!",
                        title: "Code Verified",
                      ),
                    );
                  } else {
                    // Failure
                    // TODO: Request failed, handle the error here
                    setState(() {
                      ref.read(isValidProvider.notifier).setValid(false);
                      colorList = const [
                        Color.fromARGB(255, 217, 131, 36),
                        Color.fromARGB(255, 164, 6, 6),
                      ];
                    });
                    messenger.clearSnackBars();
                    messenger.showSnackBar(
                      snackBar(
                        color: GeeLogicColourScheme.red,
                        icon: Icons.error_outline_rounded,
                        subtitle:
                            "Please try to rewrite your code to specification!",
                        title: "Invalid code",
                      ),
                    );
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 25.0,
                          width: 25.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : isValid.isValid.isNull
                          ? Text(
                              'Verify',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                      color: Colors.white, fontSize: 20.0),
                            )
                          : isValid.isValid!
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 25.0,
                                )
                              : const Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 25.0,
                                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
