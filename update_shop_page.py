import re

with open('lib/features/shop/presentation/shop_page.dart', 'r') as f:
    content = f.read()

# Remove hardcoded Colors.white in Scaffold
content = content.replace('backgroundColor: Colors.white,', '')
# Use AppTypography.titleLarge for 'products'
content = content.replace("Text('products'.tr(), style: AppTypography.h3),", "Text('products'.tr(), style: Theme.of(context).textTheme.headlineMedium),")

with open('lib/features/shop/presentation/shop_page.dart', 'w') as f:
    f.write(content)

with open('lib/features/shop/presentation/widgets/shop_hero_banner.dart', 'r') as f:
    banner_content = f.read()

banner_content = banner_content.replace('Color(0xFF111827)', 'Color(0xFF2E2910)')
banner_content = banner_content.replace('Color(0xFF31538E)', 'Color(0xFF2C5745)')
banner_content = banner_content.replace('Color(0xE6111827)', 'Color(0xE62E2910)')
banner_content = banner_content.replace('Color(0x4D111827)', 'Color(0x4D2E2910)')

# Import phosphor and replace shopping bag
if 'phosphor_flutter' not in banner_content:
    banner_content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + banner_content
banner_content = banner_content.replace('Icons.shopping_bag_outlined', 'PhosphorIconsRegular.bag')

with open('lib/features/shop/presentation/widgets/shop_hero_banner.dart', 'w') as f:
    f.write(banner_content)
