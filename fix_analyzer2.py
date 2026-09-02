import re

# 1. admin_overview_page.dart
with open('lib/features/admin/presentation/admin_overview_page.dart', 'r') as f:
    content = f.read()

content = content.replace("Theme.of(context).dividerColor.shade200", "Theme.of(context).dividerColor")

with open('lib/features/admin/presentation/admin_overview_page.dart', 'w') as f:
    f.write(content)

# 2. cart_checkout_dialog.dart
with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'r') as f:
    content = f.read()

# Remove the 'const' before Positioned.fill if it exists
content = re.sub(r'const\s+Positioned\.fill\(\s*child:\s*ColoredBox\(', r'Positioned.fill(child: ColoredBox(', content)

with open('lib/features/cart/presentation/widgets/cart_checkout_dialog.dart', 'w') as f:
    f.write(content)

# 3. order_tracking_page.dart
with open('lib/features/order_tracking/presentation/order_tracking_page.dart', 'r') as f:
    content = f.read()

# Some where there's `context` used outside of build or without it. Let's look at it.
# Usually this happens if I did `Theme.of(context)` inside a method that doesn't have `context`.
# My earlier replacement:
# content = content.replace('AppTypography.h3', 'Theme.of(context).textTheme.headlineSmall')
# If AppTypography.h3 was used in a static const or something.
# Let's just fix it by replacing back if needed or passing context.
# Actually I replaced `AppTypography.h4` with `Theme.of(context).textTheme.titleMedium`
# I replaced `AppTypography.bodyMedium` with `const TextStyle(...)`
# Let's replace `Theme.of(context).textTheme.headlineSmall` in order_tracking_page with `const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)`
# And `Theme.of(context).textTheme.titleMedium` with `const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)`

content = content.replace("Theme.of(context).textTheme.headlineSmall", "const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)")
content = content.replace("Theme.of(context).textTheme.titleMedium", "const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)")

with open('lib/features/order_tracking/presentation/order_tracking_page.dart', 'w') as f:
    f.write(content)

