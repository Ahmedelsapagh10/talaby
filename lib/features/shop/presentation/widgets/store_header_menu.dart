import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../config/routes/app_routes.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../../../../../core/config/app_flavor.dart';
import 'package:new_strucuture/injector.dart' as injector;

Future<void> openProtectedStoreRoute(BuildContext context, String route) async {
  if (await requireSocialSignIn(context) && context.mounted) {
    context.push(route);
  }
}

void showStoreMenu(BuildContext context) {
  final isAdmin = context.read<AuthCubit>().state.isAdmin;
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(
            context,
            sheetContext,
            PhosphorIconsRegular.user,
            'profile',
            Routes.profileRoute,
          ),
          _item(
            context,
            sheetContext,
            PhosphorIconsRegular.heart,
            'wishlist',
            Routes.wishlistRoute,
          ),
          _item(
            context,
            sheetContext,
            PhosphorIconsRegular.receipt,
            'my_orders',
            Routes.accountRoute,
          ),
          if (isAdmin && injector.serviceLocator<AppFlavor>() == AppFlavor.admin)
            ListTile(
              leading: const Icon(PhosphorIconsRegular.shieldCheck),
              title: Text('dashboard'.tr()),
              onTap: () {
                Navigator.pop(sheetContext);
                context.go('/admin');
              },
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

