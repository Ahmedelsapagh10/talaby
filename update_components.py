import re

with open('lib/core/widgets/app_buttons.dart', 'r') as f:
    btn_content = f.read()

# Update AppButton styling
btn_content = btn_content.replace('AppTokens.r4', 'AppTokens.r12')
btn_content = btn_content.replace('Color(0xFF191B1A)', 'Theme.of(context).colorScheme.onSurface')

with open('lib/core/widgets/app_buttons.dart', 'w') as f:
    f.write(btn_content)
    
with open('lib/core/widgets/app_text_fields.dart', 'r') as f:
    tf_content = f.read()

# Update AppTextField styling to use Theme.of(context).inputDecorationTheme
# Actually, the ThemeData already has inputDecorationTheme configured perfectly.
# If AppTextField uses InputDecoration directly, it might be overriding the theme.
