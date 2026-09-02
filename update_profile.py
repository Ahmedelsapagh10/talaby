import re

with open('lib/features/profile/presentation/profile_page.dart', 'r') as f:
    content = f.read()

if 'phosphor_flutter' not in content:
    content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + content

content = content.replace('AppTypography.h2', 'Theme.of(context).textTheme.headlineMedium')
content = content.replace('Icons.receipt_long_outlined', 'PhosphorIconsRegular.receipt')
content = content.replace('Icons.favorite_border', 'PhosphorIconsRegular.heart')
content = content.replace('Icons.logout', 'PhosphorIconsRegular.signOut')

with open('lib/features/profile/presentation/profile_page.dart', 'w') as f:
    f.write(content)

