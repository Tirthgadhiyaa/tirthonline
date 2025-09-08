import 'package:flutter/material.dart';

import 'cust_text_widget.dart';

class CustAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backGroundColor;
  final Color? foreGroundColor;
  final PreferredSizeWidget? bottom;

  const CustAppBar({
    super.key,
    this.title,
    this.actions,
    this.foreGroundColor,
    this.backGroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      child: AppBar(
        toolbarHeight: preferredSize.height,
        bottom: bottom,
        centerTitle: Navigator.canPop(context),
        backgroundColor:
            backGroundColor ?? Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: actions
            ?.map(
              (e) => SizedBox(
                width: 60,
                height: 60,
                child: Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: e,
                ),
              ),
            )
            .toList(),
        leadingWidth: 60,
        leading: Navigator.canPop(context)
            ? InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: foreGroundColor,
                ),
              )
            : null,
        title: CustText(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: foreGroundColor,
              ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
