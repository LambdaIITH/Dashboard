import 'package:dashbaord/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FaqAssistantScreen extends StatefulWidget {
  const FaqAssistantScreen({super.key});

  @override
  State<FaqAssistantScreen> createState() => _FaqAssistantScreenState();
}

class _FaqAssistantScreenState extends State<FaqAssistantScreen> {
  InAppWebViewController? webViewController;
  late PullToRefreshController pullToRefreshController;

  double progress = 0;
  Uri? currentUrl;

  final String userAgent =
      "Mozilla/5.0 (Linux; Android 11.0; IITH Dashboard Build/MRA58N) "
      "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36";

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        await webViewController?.reload();
      },
    );
  }

  Future<bool> _onWillPop() async {
    final url = currentUrl?.toString() ?? '';
    final isRootFaq = url == 'https://dost.iith.ac.in/faqassistant/' ||
        url == 'https://dost.iith.ac.in/faqassistant';

    if (webViewController != null &&
        await webViewController!.canGoBack() &&
        !isRootFaq) {
      await webViewController!.goBack();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'FAQ Assistant'),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri("https://dost.iith.ac.in/faqassistant/"),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      userAgent: userAgent,
                    ),
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        currentUrl = url;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
