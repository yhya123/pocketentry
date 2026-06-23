import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:pocketentry/core/constants/app_colors.dart';

import 'package:pocketentry/core/utils/formatters.dart';

import 'package:pocketentry/presentation/controllers/home_controller.dart';

import 'package:pocketentry/presentation/widgets/app_drawer.dart';

import 'package:pocketentry/presentation/widgets/balance_chip.dart';

import 'package:pocketentry/core/widgets/common_widgets.dart';

import 'package:pocketentry/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.settings.value.businessName.isNotEmpty
                ? controller.settings.value.businessName
                : 'الرئيسية',
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),

            onPressed: () => Get.toNamed(AppRoutes.search),

            tooltip: 'بحث',
          ),
        ],
      ),

      drawer: const AppDrawer(),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.stats.value;

        return RefreshIndicator(
          onRefresh: controller.refreshData,

          child: ListView(
            padding: const EdgeInsets.all(16),

            children: [
              Text(
                'إجراءات سريعة',

                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _PrimaryActionButton(
                      label: 'إضافة عملية',

                      icon: Icons.add_circle_outline,

                      color: const Color(AppColors.accent),

                      onTap: controller.openAddTransaction,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _PrimaryActionButton(
                      label: 'إضافة حساب',

                      icon: Icons.person_add_outlined,

                      color: const Color(AppColors.primary),

                      onTap: controller.openAddPerson,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'ملخص سريع',

                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                mainAxisSpacing: 12,

                crossAxisSpacing: 12,

                childAspectRatio: 1.4,

                children: [
                  StatCard(
                    title: 'التصنيفات',

                    value: '${stats.totalCategories}',

                    icon: Icons.category_outlined,
                  ),

                  StatCard(
                    title: 'الحسابات',

                    value: '${stats.totalPersons}',

                    icon: Icons.people_outline,
                  ),

                  StatCard(
                    title: 'العمليات',

                    value: '${stats.totalTransactions}',

                    icon: Icons.receipt_long_outlined,
                  ),

                  StatCard(
                    title: 'الأرصدة',

                    value: '${stats.summaryItems.length}',

                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                'الأرصدة الإجمالية',

                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              if (stats.summaryItems.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),

                    child: Text(
                      'لا توجد عمليات مالية بعد.\nاضغط "إضافة عملية" للبدء مباشرة.',

                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...stats.summaryItems.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),

                    child: ListTile(
                      title: Text(item.currency.labelAr),

                      subtitle: Text(
                        'عليه: ${CurrencyFormatter.format(item.totalDebit, item.currency)} | '
                        'له: ${CurrencyFormatter.format(item.totalCredit, item.currency)}',
                      ),

                      trailing: BalanceChip(
                        balance: item.netBalance,

                        currency: item.currency,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              _MenuButton(
                icon: Icons.people,

                label: 'الحسابات',

                onTap: () => Get.toNamed(AppRoutes.allPersons),
              ),

              _MenuButton(
                icon: Icons.category,

                label: 'التصنيفات',

                onTap: () => Get.toNamed(AppRoutes.categories),
              ),

              _MenuButton(
                icon: Icons.bar_chart,

                label: 'التقارير',

                onTap: () => Get.toNamed(AppRoutes.reports),
              ),

              _MenuButton(
                icon: Icons.backup,

                label: 'النسخ الاحتياطي',

                onTap: () => Get.toNamed(AppRoutes.backup),
              ),

              _MenuButton(
                icon: Icons.settings,

                label: 'الإعدادات',

                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openAddTransaction,

        icon: const Icon(Icons.add),

        label: const Text('إضافة عملية'),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,

    required this.icon,

    required this.color,

    required this.onTap,
  });

  final String label;

  final IconData icon;

  final Color color;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),

          child: Column(
            children: [
              Icon(icon, color: color, size: 32),

              const SizedBox(height: 8),

              Text(
                label,

                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),

                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,

    required this.label,

    required this.onTap,
  });

  final IconData icon;

  final String label;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),

      child: ListTile(
        leading: Icon(icon, color: const Color(AppColors.primary)),

        title: Text(label),

        trailing: const Icon(Icons.arrow_back_ios, size: 16),

        onTap: onTap,
      ),
    );
  }
}
