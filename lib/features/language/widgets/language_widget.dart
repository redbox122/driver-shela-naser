// LanguageWidget
//
// Modern, list-style language selection tile used by the first-launch
// language picker as well as the in-app language settings screen.
//
// Each tile shows:
//   • a circular leading indicator with the language flag image when an
//     asset is provided, otherwise a textual fallback (language code) so
//     adding a new language does not require shipping a flag asset.
//   • the localized display name (e.g. "English", "العربية").
//   • the language's name written in its own native script when available
//     (e.g. "Español", "বাংলা") to make the choice unambiguous regardless
//     of the currently active locale.
//   • a checkmark on the trailing edge when the tile is the selected one.
//
// Tapping the tile only updates the controller's currently-highlighted
// index. The actual locale switch happens when the user presses Save on
// the parent screen so we do not flicker the UI direction (LTR/RTL) for
// every tap.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shellafood_delivery/features/language/controllers/language_controller.dart';
import 'package:shellafood_delivery/features/language/domain/models/language_model.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;

  const LanguageWidget({
    super.key,
    required this.languageModel,
    required this.localizationController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = localizationController.selectedIndex == index;
    final Color primary = Theme.of(context).primaryColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color borderColor =
        isSelected ? primary : Theme.of(context).dividerColor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      child: InkWell(
        onTap: () => localizationController.setSelectIndex(index),
        borderRadius: BorderRadius.circular(Dimensions.radiusModern),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusModern),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: Get.isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(children: [
            _LanguageLeading(languageModel: languageModel),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageModel.languageName ?? '',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  if ((languageModel.nativeName ?? '').isNotEmpty &&
                      languageModel.nativeName != languageModel.languageName)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        languageModel.nativeName!,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _SelectionIndicator(isSelected: isSelected, primary: primary),
          ]),
        ),
      ),
    );
  }
}

/// Circular leading widget that displays the language flag when an asset
/// is provided, falling back to a styled language code chip otherwise.
class _LanguageLeading extends StatelessWidget {
  final LanguageModel languageModel;
  const _LanguageLeading({required this.languageModel});

  @override
  Widget build(BuildContext context) {
    const double size = 44;
    final bool hasAsset = (languageModel.imageUrl ?? '').isNotEmpty;
    final Color borderColor = Theme.of(context).dividerColor;
    final Color codeColor = Theme.of(context).primaryColor;

    if (hasAsset) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        child: Image.asset(
          languageModel.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _languageCodeFallback(codeColor, borderColor, size),
        ),
      );
    }

    return _languageCodeFallback(codeColor, borderColor, size);
  }

  Widget _languageCodeFallback(
      Color codeColor, Color borderColor, double size) {
    final String code =
        (languageModel.languageCode ?? '').toUpperCase().padRight(2).substring(0, 2);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: codeColor.withValues(alpha: 0.08),
        border: Border.all(color: borderColor, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        code.trim(),
        style: robotoBold.copyWith(
          color: codeColor,
          fontSize: Dimensions.fontSizeDefault,
        ),
      ),
    );
  }
}

/// Trailing radio-style indicator. Shows a filled check circle when the
/// row is selected, an empty circle otherwise.
class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  final Color primary;
  const _SelectionIndicator({required this.isSelected, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Icon(Icons.check_circle, color: primary, size: 26);
    }
    return Icon(
      Icons.circle_outlined,
      color: Theme.of(context).dividerColor,
      size: 26,
    );
  }
}
