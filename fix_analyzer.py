import re

# 1. app_buttons.dart
with open('lib/core/widgets/app_buttons.dart', 'r') as f:
    content = f.read()

content = content.replace('const Theme.of(context).colorScheme', 'Theme.of(context).colorScheme')

with open('lib/core/widgets/app_buttons.dart', 'w') as f:
    f.write(content)

# 2. admin_overview_page.dart
with open('lib/features/admin/presentation/admin_overview_page.dart', 'r') as f:
    content = f.read()

content = content.replace('AppTypography.bodySmall.copyWith(', 'AppTypography.bodySmall.copyWith(') # Wait, it was replaced.
content = content.replace("Theme.of(context).textTheme.bodySmall.copyWith", "Theme.of(context).textTheme.bodySmall?.copyWith")
content = content.replace("alert ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor.shade200", "alert ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor") # Actually it's `Colors.grey.shade200` but I replaced it.
# Let's fix line 116 properly:
content = content.replace("Theme.of(context).dividerColor.shade200", "Theme.of(context).dividerColor")

with open('lib/features/admin/presentation/admin_overview_page.dart', 'w') as f:
    f.write(content)

# 3. cart_checkout_dialog.dart
with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'r') as f:
    content = f.read()

content = content.replace("Theme.of(context).textTheme.titleMedium.copyWith", "Theme.of(context).textTheme.titleMedium?.copyWith")
content = content.replace("Theme.of(context).textTheme.bodyMedium.copyWith", "Theme.of(context).textTheme.bodyMedium?.copyWith")

content = content.replace("const ColoredBox(\n                  color: Theme.of(context).colorScheme.scaffoldBackgroundColor.withValues(alpha: 0.7)", "ColoredBox(\n                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7)")

content = content.replace("const Icon(PhosphorIconsRegular.imageBroken, color: Theme.of(context).dividerColor)", "Icon(PhosphorIconsRegular.imageBroken, color: Theme.of(context).dividerColor)")
content = content.replace("const Icon(PhosphorIconsRegular.image, color: Theme.of(context).dividerColor)", "Icon(PhosphorIconsRegular.image, color: Theme.of(context).dividerColor)")
content = content.replace("const Icon(PhosphorIconsRegular.trash, color: Theme.of(context).colorScheme.error)", "Icon(PhosphorIconsRegular.trash, color: Theme.of(context).colorScheme.error)")

with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'w') as f:
    f.write(content)

# 4. order_tracking_page.dart
with open('lib/features/order_tracking/presentation/order_tracking_page.dart', 'r') as f:
    content = f.read()

content = content.replace("style: Theme.of(context).textTheme.titleMedium,", "style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),")
content = content.replace("style: Theme.of(context).textTheme.bodyMedium,", "style: const TextStyle(fontSize: 14),")

with open('lib/features/order_tracking/presentation/order_tracking_page.dart', 'w') as f:
    f.write(content)

