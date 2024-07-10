import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class SunglassPage extends StatefulWidget {
  @override
  _SunglassPageState createState() => _SunglassPageState();
}

class _SunglassPageState extends State<SunglassPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params,
            onPermissionRequest: (resources) async {
      return resources.grant();
    });

    void _loadCamera() {
      // 'environment': rare camera; 'user': front camera;
      String facingMode = 'environment';
      controller.runJavaScript("""
      (function() {

        navigator.mediaDevices.getUserMedia({
          video: {
            facingMode: { exact: '$facingMode' } // 'environment' for rear camera, 'user' for front camera
          },
          audio: false
        })
        .then(function(stream) {
          videoElement = document.createElement('video');
          videoElement.srcObject = stream;
          videoElement.play();

          const canvasElement = document.getElementById('jeefitCanvas');
          const ctx = canvasElement.getContext('2d');

          videoElement.addEventListener('loadedmetadata', () => {
          const drawFrame = () => {
            ctx.drawImage(videoElement, 0, 0, canvasElement.width, canvasElement.height);
            requestAnimationFrame(drawFrame);
          };
          drawFrame();
        });
        // Stop any existing tracks on the stream
        if (canvasElement.stream) {
          let tracks = canvasElement.stream.getTracks();
          tracks.forEach(track => track.stop());
        }

        // Store the stream on the canvas element for future reference
        canvasElement.stream = stream;

        })
        .catch(function(err) {
          console.error('Error accessing camera: ', err);
        });
      })();
    """);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            _loadCamera();
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jeeliz.com/sunglasses'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView with Cam'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
