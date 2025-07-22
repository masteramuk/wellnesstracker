import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final Function(int) onMenuItemClicked;
  final bool isExpanded;

  const SideMenu({
    super.key,
    required this.onMenuItemClicked,
    required this.isExpanded,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int _selectedIndex = 0;
  final ExpansibleController _dashboardController = ExpansibleController();
  final ExpansibleController _reportsController = ExpansibleController();
  final ExpansibleController _dataController = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.isExpanded ? 250 : 80,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.teal,
              ),
              child: widget.isExpanded
                  ? const Text(
                      'Health Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
            _buildDashboardMenu(),
            _buildReportsMenu(),
            _buildDataMenu(),
            _buildMenuItem(
              icon: Icons.person,
              title: 'User Profile',
              index: 20,
            ),
            const Divider(),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Handle logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
    bool isSubMenu = false,
  }) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.teal : null),
      title: widget.isExpanded
          ? Text(title, style: TextStyle(color: isSelected ? Colors.teal : null))
          : null,
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (index != null) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onMenuItemClicked(index);
        }
      },
      tileColor: isSelected ? Colors.teal.withAlpha(51) : null,
      contentPadding:
          isSubMenu && widget.isExpanded ? const EdgeInsets.only(left: 40.0) : null,
    );
  }

  Widget _buildDashboardMenu() {
    return ExpansionTile(
      controller: _dashboardController,
      leading: const Icon(Icons.dashboard),
      title: widget.isExpanded ? const Text('Dashboard') : const SizedBox.shrink(),
      onExpansionChanged: (isExpanded) {
        if (isExpanded) {
          _reportsController.collapse();
          _dataController.collapse();
        }
      },
      children: [
        _buildMenuItem(
          icon: Icons.show_chart,
          title: 'Overall Statistics',
          index: 0,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.favorite_border,
          title: 'Blood Pressure',
          index: 1,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.local_drink,
          title: 'Sugar Measurement',
          index: 2,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.monitor_heart,
          title: 'Pulse Rate',
          index: 3,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.arrow_downward,
          title: 'Calories In',
          index: 4,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.arrow_upward,
          title: 'Calories Out',
          index: 5,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.sentiment_satisfied,
          title: 'Wellness Value',
          index: 6,
          isSubMenu: true,
        ),
      ],
    );
  }

  Widget _buildReportsMenu() {
    return ExpansionTile(
      controller: _reportsController,
      leading: const Icon(Icons.bar_chart),
      title: widget.isExpanded ? const Text('Reports') : const SizedBox.shrink(),
      onExpansionChanged: (isExpanded) {
        if (isExpanded) {
          _dashboardController.collapse();
          _dataController.collapse();
        }
      },
      children: [
        _buildMenuItem(
          icon: Icons.list_alt,
          title: 'All Records',
          index: 10,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.favorite_border,
          title: 'Blood Pressure',
          index: 11,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.local_drink,
          title: 'Sugar Measurement',
          index: 12,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.monitor_heart,
          title: 'Pulse Rate',
          index: 13,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.arrow_downward,
          title: 'Calories In',
          index: 14,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.arrow_upward,
          title: 'Calories Out',
          index: 15,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.sentiment_satisfied,
          title: 'Wellness',
          index: 16,
          isSubMenu: true,
        ),
      ],
    );
  }

  Widget _buildDataMenu() {
    return ExpansionTile(
      controller: _dataController,
      leading: const Icon(Icons.data_usage),
      title: widget.isExpanded ? const Text('Data') : const SizedBox.shrink(),
      onExpansionChanged: (isExpanded) {
        if (isExpanded) {
          _dashboardController.collapse();
          _reportsController.collapse();
        }
      },
      children: [
        _buildMenuItem(
          icon: Icons.arrow_downward,
          title: 'Calories In Data',
          index: 21,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.arrow_upward,
          title: 'Calories Out Data',
          index: 22,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.favorite_border,
          title: 'Blood Pressure Data',
          index: 23,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.local_drink,
          title: 'Sugar Data',
          index: 24,
          isSubMenu: true,
        ),
        
        _buildMenuItem(
          icon: Icons.calculate,
          title: 'Calories Value Data',
          index: 26,
          isSubMenu: true,
        ),
        _buildMenuItem(
          icon: Icons.sentiment_satisfied,
          title: 'Wellness Data',
          index: 27,
          isSubMenu: true,
        ),
      ],
    );
  }
}