import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/constants/app_constants.dart';
import 'package:pocketentry/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2E7D6F)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home,
            label: 'الرئيسية',
            route: AppRoutes.home,
          ),
          _DrawerItem(
            icon: Icons.people,
            label: 'الحسابات',
            route: AppRoutes.allPersons,
          ),
          _DrawerItem(
            icon: Icons.category,
            label: 'التصنيفات',
            route: AppRoutes.categories,
          ),
          _DrawerItem(
            icon: Icons.search,
            label: 'بحث',
            route: AppRoutes.search,
          ),
          _DrawerItem(
            icon: Icons.bar_chart,
            label: 'التقارير',
            route: AppRoutes.reports,
          ),
          _DrawerItem(
            icon: Icons.backup,
            label: 'النسخ الاحتياطي',
            route: AppRoutes.backup,
          ),
          _DrawerItem(
            icon: Icons.settings,
            label: 'الإعدادات',
            route: AppRoutes.settings,
          ),
          _DrawerItem(
            icon: Icons.support_agent,
            label: 'الدعم',
            route: AppRoutes.support,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        if (Get.currentRoute != route) {
          Get.toNamed(route);
        }
      },
    );
  }
}
