import 'package:flutter/material.dart';

import '../../../../../core/design_system/tokens.dart';

/// Shared desktop table surface for dense admin data. Mobile layouts continue
/// to use purpose-built cards so actions remain touch friendly.
class AdminTable extends StatelessWidget {
  const AdminTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth = 880,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(AppTokens.r16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = constraints.maxWidth > minWidth
              ? constraints.maxWidth
              : minWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: tableWidth),
              child: DataTable(
                columns: columns,
                rows: rows,
                showCheckboxColumn: false,
                horizontalMargin: AppTokens.s20,
                columnSpacing: AppTokens.s32,
                headingRowHeight: 52,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 76,
              ),
            ),
          );
        },
      ),
    );
  }
}
