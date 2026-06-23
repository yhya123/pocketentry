import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/snackbar_helper.dart';
import 'package:pocketentry/core/utils/validators.dart';
import 'package:pocketentry/domain/entities/entities.dart';
import 'package:pocketentry/domain/usecases/usecases.dart';
import 'package:pocketentry/presentation/widgets/person_form_sheet.dart';
import 'package:pocketentry/services/image_service.dart';

class TransactionFormController extends GetxController {
  final TransactionUseCases _transactionUseCases = Get.find();
  final PersonUseCases _personUseCases = Get.find();
  final SettingsUseCases _settingsUseCases = Get.find();
  final ImageService _imageService = Get.find();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final person = Rxn<PersonEntity>();
  final existingTransaction = Rxn<TransactionEntity>();

  final amountController = TextEditingController();
  final detailsController = TextEditingController();
  final personSearchController = TextEditingController();
  final personFocusNode = FocusNode();

  final selectedType = TransactionType.debit.obs;
  final selectedCurrency = AppCurrency.yer.obs;
  final selectedDate = DateTime.now().obs;
  final imagePath = RxnString();

  final personSuggestions = <PersonEntity>[].obs;
  final showPersonSuggestions = false.obs;
  final recentPersons = <PersonEntity>[].obs;

  int? personId;
  int? transactionId;
  final formKey = GlobalKey<FormState>();

  Timer? _searchDebounce;

  bool get isEditing => transactionId != null;
  bool get isQuickAddMode => personId == null && !isEditing;
  bool get hasSelectedPerson => person.value != null && personId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    personId = args?['personId'] as int?;
    transactionId = args?['transactionId'] as int?;
    loadData();

    personSearchController.addListener(_onPersonSearchChanged);
    personFocusNode.addListener(() {
      if (personFocusNode.hasFocus && isQuickAddMode) {
        showPersonSuggestions.value = personSearchController.text.isNotEmpty;
      } else {
        showPersonSuggestions.value = false;
      }
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    personSearchController.removeListener(_onPersonSearchChanged);
    amountController.dispose();
    detailsController.dispose();
    personSearchController.dispose();
    personFocusNode.dispose();
    super.onClose();
  }

  void _onPersonSearchChanged() {
    if (!isQuickAddMode || hasSelectedPerson) return;
    searchPersons(personSearchController.text);
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      if (personId != null) {
        person.value = await _personUseCases.getById(personId!);
        personSearchController.text = person.value?.name ?? '';
      } else if (isQuickAddMode) {
        final ids = await _settingsUseCases.getRecentPersonIds();
        recentPersons.value = await _personUseCases.getByIds(ids);
      }

      if (!isEditing) {
        selectedCurrency.value = await _settingsUseCases.getPreferredCurrency();
      }

      if (transactionId != null) {
        final tx = await _transactionUseCases.getById(transactionId!);
        if (tx != null) {
          existingTransaction.value = tx;
          amountController.text = tx.amount.toString();
          detailsController.text = tx.details ?? '';
          selectedType.value = tx.type;
          selectedCurrency.value = tx.currency;
          selectedDate.value = tx.transactionDate;
          imagePath.value = tx.imagePath;
        }
      }
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void searchPersons(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        personSuggestions.clear();
        showPersonSuggestions.value = false;
        return;
      }

      try {
        personSuggestions.value = await _personUseCases.getAll(query: trimmed);
        showPersonSuggestions.value = personFocusNode.hasFocus;
      } catch (e) {
        SnackbarHelper.error(e.toString());
      }
    });
  }

  void selectPerson(PersonEntity selected) {
    person.value = selected;
    personId = selected.id;
    personSearchController.text = selected.name;
    showPersonSuggestions.value = false;
    personFocusNode.unfocus();
  }

  void clearSelectedPerson() {
    person.value = null;
    personId = null;
    personSearchController.clear();
    personSuggestions.clear();
    showPersonSuggestions.value = false;
  }

  Future<void> showAddNewPersonSheet() async {
    final name = personSearchController.text.trim();
    if (name.isEmpty) return;

    showPersonSuggestions.value = false;
    personFocusNode.unfocus();

    final created = await PersonFormSheet.show(initialName: name);
    if (created != null) {
      selectPerson(created);
    }
  }

  String? validatePersonField(String? _) {
    if (!isQuickAddMode) return null;
    if (hasSelectedPerson) return null;
    if (personSearchController.text.trim().isEmpty) {
      return 'يرجى اختيار حساب أو إضافته';
    }
    return 'يرجى اختيار حساب من القائمة أو إضافة حساب جديد';
  }

  Future<void> pickImage(ImageSource source) async {
    final path = await _imageService.pickAndSaveImage(source);
    if (path == null) {
      SnackbarHelper.info('لم يتم اختيار صورة');
      return;
    }
    if (imagePath.value != null &&
        imagePath.value != existingTransaction.value?.imagePath) {
      await _imageService.deleteImage(imagePath.value);
    }
    imagePath.value = path;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    if (isQuickAddMode && !hasSelectedPerson) {
      SnackbarHelper.error('يرجى اختيار حساب قبل حفظ العملية');
      return;
    }

    try {
      isSaving.value = true;
      final amount = Validators.parseAmount(amountController.text);
      final entity = TransactionEntity(
        id: transactionId,
        personId: personId!,
        type: selectedType.value,
        amount: amount,
        currency: selectedCurrency.value,
        details: detailsController.text.trim().isEmpty
            ? null
            : detailsController.text.trim(),
        transactionDate: selectedDate.value,
        imagePath: imagePath.value,
        createdAt: existingTransaction.value?.createdAt,
      );
      var message = "";
      if (isEditing) {
        final oldPath = existingTransaction.value?.imagePath;
        if (oldPath != null && oldPath != imagePath.value) {
          await _imageService.deleteImage(oldPath);
        }
        await _transactionUseCases.update(entity);
        message = 'تم تحديث العملية';
        // SnackbarHelper.success('تم تحديث العملية');
      } else {
        await _transactionUseCases.create(entity);
        await _settingsUseCases.saveLastUsedCurrency(selectedCurrency.value);
        await _settingsUseCases.addRecentPerson(personId!);
        message = 'تم إضافة العملية';
        // SnackbarHelper.success('تم إضافة العملية');
      }
      Get.back(result: true);
      SnackbarHelper.success(message);

      // await Future.delayed(const Duration(milliseconds: 1000));

      // if (Get.context != null) {
      //   Get.back(result: true);
      // }
      // Get.back(result: true);
    } catch (e) {
      SnackbarHelper.error(e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  void showImageSourcePicker() {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            if (imagePath.value != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('إزالة الصورة'),
                onTap: () async {
                  Get.back();
                  await _imageService.deleteImage(imagePath.value);
                  imagePath.value = null;
                },
              ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  File? get imageFile {
    final path = imagePath.value;
    if (path == null) return null;
    return File(path);
  }
}
