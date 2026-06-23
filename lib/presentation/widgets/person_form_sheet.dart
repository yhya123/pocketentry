import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/core/utils/validators.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';

/// نموذج إضافة/تعديل حساب كـ Bottom Sheet قابل لإعادة الاستخدام
/// دون مغادرة الشاشة الحالية أو فقدان بيانات النماذج الأخرى.
class PersonFormSheet {
  PersonFormSheet._();

  static Future<PersonEntity?> show({
    PersonEntity? person,
    int? defaultCategoryId,
    String? initialName,
  }) async {
    final context = Get.context;
    if (context == null) return null;

    return showModalBottomSheet<PersonEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _PersonFormSheetContent(
        person: person,
        defaultCategoryId: defaultCategoryId,
        initialName: initialName,
      ),
    );
  }
}

class _PersonFormSheetContent extends StatefulWidget {
  const _PersonFormSheetContent({
    this.person,
    this.defaultCategoryId,
    this.initialName,
  });

  final PersonEntity? person;
  final int? defaultCategoryId;
  final String? initialName;

  @override
  State<_PersonFormSheetContent> createState() =>
      _PersonFormSheetContentState();
}

class _PersonFormSheetContentState extends State<_PersonFormSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  final _personUseCases = Get.find<PersonUseCases>();
  final _categoryUseCases = Get.find<CategoryUseCases>();

  List<CategoryEntity> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.person?.name ?? widget.initialName ?? '';
    _phoneController.text = widget.person?.phone ?? '';
    _addressController.text = widget.person?.address ?? '';
    _notesController.text = widget.person?.notes ?? '';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryUseCases.getAll();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategoryId =
            widget.person?.categoryId ??
            widget.defaultCategoryId ??
            _defaultCategoryId(categories);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.error(e.toString());
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int? _defaultCategoryId(List<CategoryEntity> categories) {
    for (final category in categories) {
      if (category.isDefault) return category.id;
    }
    return categories.isNotEmpty ? categories.first.id : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      final entity = PersonEntity(
        id: widget.person?.id,
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.person?.createdAt,
      );

      PersonEntity saved;
      if (_isEditing) {
        await _personUseCases.update(entity);
        saved = (await _personUseCases.getById(entity.id!)) ?? entity;
        SnackbarHelper.success('تم تحديث الحساب');
      } else {
        final id = await _personUseCases.create(entity);
        saved = (await _personUseCases.getById(id)) ?? entity.copyWith(id: id);
        SnackbarHelper.success('تم إضافة الحساب');
      }

      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _isEditing ? 'تعديل حساب' : 'إضافة حساب جديد',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textDirection: TextDirection.rtl,
                      autofocus: !_isEditing,
                      decoration: const InputDecoration(
                        labelText: 'الاسم *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف *',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'التصنيف',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isEditing ? 'حفظ التعديلات' : 'حفظ الحساب'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
