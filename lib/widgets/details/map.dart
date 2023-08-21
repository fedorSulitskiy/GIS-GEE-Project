import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/widget_map_provider.dart';
import 'package:frontend/widgets/common/loading_star.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A widget to display a map widget from the python api.
class MapWidget extends ConsumerStatefulWidget {
  const MapWidget(
      {super.key,
      required this.code,
      required this.api,
      this.height = 300.0,
      this.width = 700.0});

  final String code;
  final double height;
  final double width;
  final int api;

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  // Initialise the controller for the WebView widget
  final PlatformWebViewController _controller = PlatformWebViewController(
    const PlatformWebViewControllerCreationParams(),
  );

  @override
  Widget build(BuildContext context) {
    final String apiType;

    if (widget.api == 1) {
      apiType = 'python';
    } else {
      apiType = 'js';
    }

    final params = json.encode({
      "uri": 'get_map_widget/$apiType?height=${widget.height.toString()}',
      "code": widget.code,
    });

    final mapWidgetHTMLCode = ref.watch(mapWidgetCodeProvider(params));

    return mapWidgetHTMLCode.when(
      data: (data) {
        _controller.loadHtmlString(data);
        return Center(
          child: SizedBox(
            width: widget.width,
            height: widget.height + 20,
            child: PlatformWebViewWidget(
              PlatformWebViewWidgetCreationParams(controller: _controller),
            ).build(context),
          ),
        );
      },
      error: (error, stackTrace) {
        return Center(
          child: Center(
            child: SizedBox(
              width: widget.width,
              height: widget.height + 20,
              child: Text(error.toString()),
            ),
          ),
        );
      },
      loading: () {
        return Center(
          child: SizedBox(
            width: widget.width,
            height: widget.height + 20,
            child: const Center(
              child: LoadingStar(size: 50.0),
            ),
          ),
        );
      },
    );
  }
}
