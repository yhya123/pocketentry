import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/core/utils/validators.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';

class CategoriesController extends GetxController {
  final CategoryUseCases _useCases = Get.find();

  final isLoading = true.obs;
  final categories = <CategoryEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      categories.value = await _useCases.getAll();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showCategoryForm({CategoryEntity? category}) async {
    // final nameController = TextEditingController(text: category?.name ?? '');
    String categoryName = category?.name ?? '';
    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      AlertDialog(
        title: Text(category == null ? 'إضافة تصنيف' : 'تعديل تصنيف'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: categoryName,
            // controller: nameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'اسم التصنيف'),
            validator: Validators.name,
            autofocus: true,
            onChanged: (value) {
              categoryName = value;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('إلغاء')),

          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Get.back();
              await saveCategory(category: category, name: categoryName.trim());
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    // nameController.dispose();
  }

  Future<void> showCategoryForm2({CategoryEntity? category}) async {
    var nameController = TextEditingController(text: category?.name ?? '');

    // final nameController = TextEditingController(text: category?.name ?? '');
    String categoryName = category?.name ?? '';
    final formKey = GlobalKey<FormState>();

    await Get.dialog(
      AlertDialog(
        title: Text(category == null ? 'إضافة تصنيف' : 'تعديل تصنيف'),
        content: Form(
          key: formKey,
          child: TextFormField(
            // initialValue: categoryName,
            controller: nameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(labelText: 'اسم التصنيف'),
            validator: (value) => Validators.name(
              value,
            ), // تأكد من استدعاء الفالديتور بالشكل الصحيح
            // validator: Validators.name,
            autofocus: true,
            // onChanged: (value) {
            //   categoryName = value;
            // },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // isLoading.value = true;
            },
            child: const Text('إلغاء'),
          ),

          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              // إغلاق النافذة بنجاح
              Get.back();
              // isLoading.value = true;
              await saveCategory(
                category: category,
                name: nameController.text.trim(),
              );
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      nameController.dispose();
    });
    // nameController.dispose();
  }

  Future<void> saveCategory({
    CategoryEntity? category,
    required String name,
  }) async {
    try {
      if (category == null) {
        await _useCases.create(CategoryEntity(name: name));
        SnackbarHelper.success('تم إضافة التصنيف');
      } else {
        await _useCases.update(category.copyWith(name: name));
        SnackbarHelper.success('تم تحديث التصنيف');
      }
      await loadCategories();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    }
  }

  Future<void> deleteCategory(CategoryEntity category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف التصنيف'),
        content: Text('هل تريد حذف "${category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _useCases.delete(category.id!);
      SnackbarHelper.success('تم حذف التصنيف');
      await loadCategories();
    } catch (e) {
      SnackbarHelper.error(e.toString());
    }
  }
}
