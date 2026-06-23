import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/constants/app_colors.dart';
import 'package:pocketentry/core/widgets/common_widgets.dart';
import 'package:pocketentry/presentation/controllers/categories_controller.dart';
import 'package:pocketentry/routes/app_routes.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.categories.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.category_outlined,
            title: 'لا توجد تصنيفات',
            subtitle: 'أضف تصنيفاً لتنظيم الحسابات',
            actionLabel: 'إضافة تصنيف',
            onAction: () => controller.showCategoryForm(),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadCategories,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(AppColors.primaryLight),
                    child: Text(
                      category.name.characters.first,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text('${category.personCount} حساب'),
                  trailing: category.isDefault
                      ? const Chip(label: Text('افتراضي'))
                      : PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              controller.showCategoryForm(category: category);
                            } else if (value == 'delete') {
                              controller.deleteCategory(category);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف'),
                            ),
                          ],
                        ),
                  onTap: () => Get.toNamed(
                    AppRoutes.persons,
                    arguments: {
                      'categoryId': category.id,
                      'categoryName': category.name,
                    },
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showCategoryForm2(),
        icon: const Icon(Icons.add),
        label: const Text('تصنيف جديد'),
      ),
    );
  }
}
