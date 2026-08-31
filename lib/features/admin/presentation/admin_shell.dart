import 'package:flutter/material.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const AdminShell({super.key, required this.child, this.selectedIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(child: child),
        BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF191B1A),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Customers',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Text('TALABY ADMIN', style: AppTypography.h4),
          ),
          const SizedBox(height: AppTokens.s32),
          _buildSidebarItem(
            Icons.dashboard_outlined,
            'Overview',
            selectedIndex == 0,
          ),
          _buildSidebarItem(
            Icons.shopping_bag_outlined,
            'Orders',
            selectedIndex == 1,
          ),
          _buildSidebarItem(
            Icons.inventory_2_outlined,
            'Products',
            selectedIndex == 2,
          ),
          _buildSidebarItem(
            Icons.people_outline,
            'Customers',
            selectedIndex == 3,
          ),
          _buildSidebarItem(Icons.star_outline, 'Reviews', selectedIndex == 4),
          const Spacer(),
          _buildSidebarItem(
            Icons.settings_outlined,
            'Settings',
            selectedIndex == 5,
          ),
          const SizedBox(height: AppTokens.s24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected) {
    return Container(
      color: isSelected ? Colors.grey.shade200 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF191B1A) : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? const Color(0xFF191B1A) : Colors.grey.shade700,
          ),
        ),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
      ),
    );
  }
}
