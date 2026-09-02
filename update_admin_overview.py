import re

with open('lib/features/admin/presentation/admin_overview_page.dart', 'r') as f:
    content = f.read()

if 'phosphor_flutter' not in content:
    content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + content

# Typography
content = content.replace('AppTypography.h2', 'Theme.of(context).textTheme.headlineMedium')
content = content.replace('AppTypography.h3', 'Theme.of(context).textTheme.titleLarge')
content = content.replace('AppTypography.bodySmall', 'Theme.of(context).textTheme.bodySmall')

# Colors
content = content.replace('Colors.grey', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)')
content = content.replace('color: alert ? Colors.orange.shade50 : Colors.white', 'color: alert ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface')
content = content.replace('color: alert ? Colors.orange.shade200 : Colors.grey.shade200', 'color: alert ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor')

# Icons
content = content.replace('Icons.receipt_long_outlined', 'PhosphorIconsRegular.receipt')

# Radius
content = content.replace('AppTokens.r8', 'AppTokens.r16')

with open('lib/features/admin/presentation/admin_overview_page.dart', 'w') as f:
    f.write(content)

