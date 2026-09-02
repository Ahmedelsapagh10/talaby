import re

with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'r') as f:
    content = f.read()

# Add PhosphorIcons import
if 'phosphor_flutter' not in content:
    content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + content

# Replace icons
content = content.replace('Icons.shopping_cart_outlined', 'PhosphorIconsRegular.shoppingCart')
content = content.replace('Icons.close', 'PhosphorIconsRegular.x')
content = content.replace('Icons.broken_image', 'PhosphorIconsRegular.imageBroken')
content = content.replace('Icons.image', 'PhosphorIconsRegular.image')
content = content.replace('Icons.delete_outline', 'PhosphorIconsRegular.trash')

# Replace styles
content = content.replace('AppTypography.h4', 'Theme.of(context).textTheme.titleMedium')
content = content.replace('AppTypography.bodyMedium', 'Theme.of(context).textTheme.bodyMedium')
content = content.replace('AppTypography.bodyLarge', 'Theme.of(context).textTheme.bodyLarge')

# Replace colors
content = content.replace('Colors.grey.shade50', 'Theme.of(context).colorScheme.surface')
content = content.replace('color: Colors.grey.shade100,', 'color: Theme.of(context).dividerColor.withValues(alpha: 0.1),')
content = content.replace('color: Colors.grey', 'color: Theme.of(context).dividerColor')
content = content.replace('color: Colors.black26', 'color: Theme.of(context).colorScheme.scaffoldBackgroundColor.withValues(alpha: 0.7)')
content = content.replace('color: Colors.red', 'color: Theme.of(context).colorScheme.error')
content = content.replace('color: Theme.of(context).primaryColor', 'color: Theme.of(context).colorScheme.primary')

with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'w') as f:
    f.write(content)

