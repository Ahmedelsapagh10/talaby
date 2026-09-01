import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../config/routes/app_routes.dart';
import '../../../auth/presentation/widgets/social_sign_in_dialog.dart';

Future<void> openProtectedStoreRoute(BuildContext context, String route) async {
  if (await requireSocialSignIn(context) && context.mounted) {
    context.push(route);
  }
}

void showStoreMenu(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            context,
            sheetContext,
            Icons.person_outline,
            'profile',
            Routes.profileRoute,
          ),
          _item(
            context,
            sheetContext,
            Icons.favorite_border,
            'wishlist',
            Routes.wishlistRoute,
          ),
          _item(
            context,
            sheetContext,
            Icons.receipt_long_outlined,
            'my_orders',
            Routes.accountRoute,
          ),
        ],
      ),
    ),
  );
}

Widget _item(
  BuildContext context,
  BuildContext sheetContext,
  IconData icon,
  String label,
  String route,
) => ListTile(
  leading: Icon(icon),
  title: Text(label.tr()),
  onTap: () {
    Navigator.pop(sheetContext);
    openProtectedStoreRoute(context, route);
  },
);
