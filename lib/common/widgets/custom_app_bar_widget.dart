import 'package:get/get.dart';
import 'package:shellafood_delivery/helper/route_helper.dart';
import 'package:shellafood_delivery/util/dimensions.dart';
import 'package:shellafood_delivery/util/styles.dart';
import 'package:flutter/material.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final Widget? actionWidget;
  const CustomAppBarWidget(
      {super.key,
      required this.title,
      this.isBackButtonExist = true,
      this.onBackPressed,
      this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge!.color)),
      centerTitle: true,
      leading: isBackButtonExist
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else if (Get.previousRoute.isNotEmpty) {
                  Navigator.of(context, rootNavigator: true).maybePop();
                } else {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                }
              },
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
          child: actionWidget ?? const SizedBox(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size(1170, GetPlatform.isDesktop ? 70 : 50);
}
