import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:shellafood_delivery/features/html/controllers/html_controller.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/app_constants.dart';
import 'package:shellafood_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatefulWidget {
  final bool isPrivacyPolicy;
  const HtmlViewerScreen({super.key, required this.isPrivacyPolicy});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  void initState() {
    super.initState();

    Get.find<HtmlController>().getHtmlText(widget.isPrivacyPolicy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: widget.isPrivacyPolicy
              ? 'privacy_policy'.tr
              : 'terms_condition'.tr),
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).cardColor,
          child: htmlController.htmlText != null
              ? _buildHtmlOrWebView(htmlController.htmlText ?? '')
              : const Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }

  Widget _buildHtmlOrWebView(String html) {
    final bool looksLikeFullDoc = html.contains('<html') &&
        html.contains('<body') &&
        html.contains('id="root"');

    if (looksLikeFullDoc) {
      final String url = AppConstants.baseUrl +
          (widget.isPrivacyPolicy
              ? AppConstants.privacyPolicyUri
              : AppConstants.tramsAndConditionUri);
      return InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      physics: const BouncingScrollPhysics(),
      child: HtmlWidget(
        html,
        key: Key(
            widget.isPrivacyPolicy ? 'privacy_policy' : 'terms_condition'),
        onTapUrl: (url) {
          String safeUrl = url;
          if (safeUrl.startsWith('www.')) {
            safeUrl = 'https://$safeUrl';
          }
          launchUrlString(safeUrl, mode: LaunchMode.externalApplication);
          return true;
        },
      ),
    );
  }
}
