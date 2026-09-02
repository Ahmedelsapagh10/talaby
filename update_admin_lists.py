import os

def update_file(path):
    if not os.path.exists(path):
        return
    with open(path, 'r') as f:
        content = f.read()

    if 'phosphor_flutter' not in content:
        content = "import 'package:phosphor_flutter/phosphor_flutter.dart';\n" + content
    
    content = content.replace('AppTypography.bodyMedium', 'Theme.of(context).textTheme.bodyMedium')
    content = content.replace('AppTypography.bodyLarge', 'Theme.of(context).textTheme.bodyLarge')
    content = content.replace('AppTypography.caption', 'Theme.of(context).textTheme.labelSmall')
    
    # Common material icons to Phosphor
    content = content.replace('Icons.chevron_right', 'PhosphorIconsRegular.caretRight')
    content = content.replace('Icons.delete_outline', 'PhosphorIconsRegular.trash')
    content = content.replace('Icons.edit_outlined', 'PhosphorIconsRegular.pencilSimple')
    content = content.replace('Icons.add', 'PhosphorIconsRegular.plus')
    
    with open(path, 'w') as f:
        f.write(content)

update_file('lib/features/admin/presentation/widgets/admin_order_list.dart')
update_file('lib/features/admin/presentation/widgets/admin_product_tile.dart')
