import re

# 1. admin_overview_page.dart
with open('lib/features/admin/presentation/admin_overview_page.dart', 'r') as f:
    content = f.read()

content = re.sub(r'Theme\.of\(context\)\.dividerColor\.shade200', r'Theme.of(context).dividerColor', content)

with open('lib/features/admin/presentation/admin_overview_page.dart', 'w') as f:
    f.write(content)

# 2. cart_checkout_dialog.dart
with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'r') as f:
    content = f.read()

content = re.sub(r'Theme\.of\(context\)\.colorScheme\.scaffoldBackgroundColor', r'Theme.of(context).scaffoldBackgroundColor', content)

with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'w') as f:
    f.write(content)

