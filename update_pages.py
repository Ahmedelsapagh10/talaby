import re
import os

def update_file(path):
    if not os.path.exists(path):
        return
    with open(path, 'r') as f:
        content = f.read()

    if 'phosphor_flutter' not in content:
        content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + content
    
    content = content.replace('AppTypography.h3', 'Theme.of(context).textTheme.headlineSmall')
    content = content.replace('AppTypography.h4', 'Theme.of(context).textTheme.titleMedium')
    
    # Common material icons to Phosphor
    content = content.replace('Icons.favorite_border', 'PhosphorIconsRegular.heart')
    content = content.replace('Icons.local_shipping_outlined', 'PhosphorIconsRegular.truck')
    content = content.replace('Icons.check_circle_outline', 'PhosphorIconsRegular.checkCircle')
    content = content.replace('Icons.access_time', 'PhosphorIconsRegular.clock')
    content = content.replace('Icons.cancel_outlined', 'PhosphorIconsRegular.xCircle')
    
    with open(path, 'w') as f:
        f.write(content)

update_file('lib/features/wishlist/presentation/wishlist_page.dart')
update_file('lib/features/order_tracking/presentation/order_tracking_page.dart')
