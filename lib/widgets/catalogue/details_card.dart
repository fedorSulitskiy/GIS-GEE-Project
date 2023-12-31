import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:frontend/widgets/details/user_creator.dart';
import 'package:frontend/widgets/details/comment_section/comment_section.dart';
import 'package:frontend/widgets/details/tags_display.dart';
import 'package:frontend/widgets/details/description_text.dart';
import 'package:frontend/widgets/details/sub_title_text.dart';
import 'package:frontend/widgets/details/title_element.dart';
import 'package:frontend/widgets/details/code_display.dart';
import 'package:frontend/widgets/details/map.dart';
import 'package:frontend/providers/algo_selection_provider.dart';
import 'package:frontend/models/algo_data.dart';
import 'package:frontend/app_theme.dart';

/// The card that displays the details of the selected algorithm. Used by the [CatalogueScreen],
/// bears great resemblance to the [DetailsContent] widget.
class DetailsCard extends ConsumerWidget {
  const DetailsCard({super.key, required this.loadedAlgos});

  final List<AlgoData> loadedAlgos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedAlgoIndexProvider);
    final data = loadedAlgos[selectedIndex];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Stack(
        children: [
          Container(
            width: 700,
            decoration: BoxDecoration(
              border: Border.all(
                color: GeeLogicColourScheme.blue,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleElement(
                  title: data.title,
                  data: data,
                ),
                UserCreatorDisplay(
                  name: data.creatorName,
                  surname: data.creatorSurname,
                  imageURL: data.creatorImageURL,
                  dateCreated: data.formattedDate,
                ),
                MapWidget(code: data.code, api: data.api),
                CodeDisplayWidget(code: data.code, apiType: data.api),
                const SubTitleText(title: 'Description'),
                DescriptionText(text: data.description),
                const SubTitleText(title: 'Tags'),
                TagsDisplay(tags: data.tags),
                const SubTitleText(title: 'Comments'),
                CommentSection(algoId: data.id),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// USE THEM LATER FOR ADDED FEATURES: //

/// Widget for displaing an image from the internet.
class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.imageURI,
  });

  final String imageURI;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          height: 300,
          // width: 400,
          child: Image.network(
            imageURI,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying a web imbed.
class WebImbedWidget extends StatefulWidget {
  // THIS DOESN'T PROPERLY WORK WITH ANY LINK.
  // REFUSES TO WORK WITH YOUTUBE
  const WebImbedWidget({
    super.key,
    required this.uri,
  });

  final String uri;

  @override
  State<WebImbedWidget> createState() => _WebImbedWidgetState();
}

class _WebImbedWidgetState extends State<WebImbedWidget> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.uri),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          height: 400,
          width: 500,
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ),
      ],
    );
  }
}
