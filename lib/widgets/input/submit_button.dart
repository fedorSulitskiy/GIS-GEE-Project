import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/helpers/input/upload_logic.dart';
import 'package:frontend/providers/input_code_providers.dart';
import 'package:frontend/providers/input_description_provider.dart';
import 'package:frontend/providers/input_is_loading_provider.dart';
import 'package:frontend/providers/input_map_html_code_provider.dart';
import 'package:frontend/providers/input_tags_provider.dart';
import 'package:frontend/providers/input_title_provider.dart';
import 'package:frontend/screens/catalogue_screen.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/custom_page_route.dart';

const double borderRadius = 30.0;
const List<double> buttonDimensions = [30.0, 100.0];

/// Button found at the bottom of the input screen which on press launches the
/// [uploadLogic] conditional on if the [VerifyButton] has been pressed and
/// confirmed validy of code, as well as if all fields have some data.
///
/// If successful it will result in the algorithm being added to database, if
/// not user will be informed via [SnackBar]
class SubmitButton extends ConsumerStatefulWidget {
  // TODO: implment a better vision of user being released to CatalogueScreen
  //  during loading and all subsequent errors being sent to the screen wherever
  //  they are, with ability to return to this screen by clicking on it with all
  //  data saved.
  const SubmitButton({super.key});

  @override
  ConsumerState<SubmitButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<SubmitButton> {
  /// List of colors to be used for the background of the button when
  /// submission is not available.
  List<Color> colorList = [
    Colors.grey.shade900,
    Colors.blueGrey.shade900,
    Colors.grey.shade800,
    Colors.blueGrey.shade800
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.grey.shade900;
  Color topColor = Colors.blueGrey.shade800;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  bool _isUploading = false;

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
    final isValid = ref.watch(isValidProvider);
    final title = ref.watch(titleProvider);
    final description = ref.watch(descriptionProvider);
    final code = ref.watch(codeProvider);
    final tags = ref.watch(selectedTagsProvider);
    final mapCode = ref.watch(mapWidgetHTMLCodeProvider);
    final isPython = ref.watch(apiLanguageProvider);

    if (isValid.isValid == true) {
      /// Change colour of the button if submission is available.
      setState(() {
        colorList = [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
        ];
        bottomColor = Colors.red;
        topColor = Colors.yellow;
      });
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
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
                final scaffoldMessengerContext = ScaffoldMessenger.of(context);

                if (isValid.isValid != true ||
                    title.isEmpty ||
                    description.isEmpty ||
                    tags.isEmpty) {
                  String warningTitle = '';
                  String warningSubtitle = '';
                  if (isValid.isValid != true) {
                    warningTitle = "Verify your code";
                    warningSubtitle =
                        "Please ensure that your code is verified!";
                  } else if (title.isEmpty) {
                    warningTitle = "Submit a title";
                    warningSubtitle =
                        "Please ensure that your algorithm has a title";
                  } else if (description.isEmpty) {
                    warningTitle = "Submit description";
                    warningSubtitle = "Please describe your algorithm for us";
                  } else if (tags.isEmpty) {
                    warningTitle = "Submit tags";
                    warningSubtitle = "Please select at least one tag";
                  }
                  scaffoldMessengerContext.clearSnackBars();
                  scaffoldMessengerContext.showSnackBar(
                    snackBar(
                      color: GeeLogicColourScheme.red,
                      icon: Icons.error_outline_outlined,
                      subtitle: warningSubtitle,
                      title: warningTitle,
                    ),
                  );
                  return;
                }

                // Start uploading data
                setState(() {
                  _isUploading = true;
                });

                // Set loading status to true, for the [AddAlgorithmButton] to
                // animate.
                ref
                    .read(inputIsLoadingProvider.notifier)
                    .setLoadingStatus(true);

                // Navigate to CatalogueScreen by default so user has something
                // to do while loading occurs
                Navigator.of(context).push(
                  CustomPageRoute(
                    builder: (ctx) => const CatalogueScreen(),
                  ),
                );

                // Inform the user that their algorithm is being uploaded
                scaffoldMessengerContext.clearSnackBars();
                scaffoldMessengerContext.showSnackBar(
                  snackBar(
                    color: GeeLogicColourScheme.yellow,
                    icon: Icons.cloud_upload_outlined,
                    subtitle: "Your algorithm is being uploaded",
                    title: "Uploading!",
                  ),
                );

                // Get current user id
                await uploadLogic(
                  scaffoldMessengerContext: scaffoldMessengerContext,
                  context: context,
                  title: title,
                  description: description,
                  tags: tags,
                  code: code,
                  mapCode: mapCode,
                  isPython: isPython,
                );

                // Upon completion make algorithm code invalid, so when user
                // decides to input a new algorithm the isValid parameter will
                // be null by default.
                ref.read(isValidProvider.notifier).setValid(null);

                // Finish loading to allow the animation of the [AddAlgorithmButton]
                // to complete.
                ref
                    .read(inputIsLoadingProvider.notifier)
                    .setLoadingStatus(false);

                // Complete the task
                setState(() {
                  _isUploading = false;
                });
              },
              child: _isUploading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'submit',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Colors.white,
                            fontSize: 24.0,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
