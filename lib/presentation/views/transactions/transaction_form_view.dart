import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/core/utils/formatters.dart';
import 'package:pocketentry/core/utils/validators.dart';
import 'package:pocketentry/presentation/controllers/transaction_form_controller.dart';
import 'package:pocketentry/presentation/widgets/person_autocomplete_field.dart';

class TransactionFormView extends GetView<TransactionFormController> {
  const TransactionFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'تعديل عملية' : 'إضافة عملية'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.isQuickAddMode) ...[
                  Obx(
                    () => RecentPersonsRow(
                      persons: controller.recentPersons.toList(),
                      onPersonSelected: controller.selectPerson,
                    ),
                  ),
                  Obx(
                    () => PersonAutocompleteField(
                      controller: controller.personSearchController,
                      focusNode: controller.personFocusNode,
                      suggestions: controller.personSuggestions,
                      showSuggestions: controller.showPersonSuggestions.value,
                      selectedPerson: controller.hasSelectedPerson
                          ? controller.person.value
                          : null,
                      onChanged: controller.searchPersons,
                      onPersonSelected: controller.selectPerson,
                      onAddNewPerson: controller.showAddNewPersonSheet,
                      onClear: controller.clearSelectedPerson,
                      validator: controller.validatePersonField,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (controller.person.value != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(controller.person.value!.name),
                      subtitle: Text(
                        '${controller.person.value!.categoryName ?? ''} • ${controller.person.value!.phone}',
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                if (!controller.isQuickAddMode ||
                    controller.hasSelectedPerson) ...[
                  if (!controller.isQuickAddMode) const SizedBox(height: 16),
                  const Text(
                    'نوع العملية',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => SegmentedButton<TransactionType>(
                      segments: TransactionType.values
                          .map(
                            (t) => ButtonSegment(
                              value: t,
                              label: Text(t.labelAr),
                              icon: Icon(
                                t == TransactionType.debit
                                    ? Icons.add_circle_outline
                                    : Icons.remove_circle_outline,
                              ),
                            ),
                          )
                          .toList(),
                      selected: {controller.selectedType.value},
                      onSelectionChanged: (s) =>
                          controller.selectedType.value = s.first,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textDirection: TextDirection.ltr,
                    autofocus: !controller.isQuickAddMode,
                    decoration: const InputDecoration(
                      labelText: 'المبلغ *',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: Validators.amount,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<AppCurrency>(
                      value: controller.selectedCurrency.value,
                      decoration: const InputDecoration(labelText: 'العملة'),
                      items: AppCurrency.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.labelAr),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => controller.selectedCurrency.value = v!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('التاريخ'),
                      subtitle: Text(
                        DateFormatter.formatDate(controller.selectedDate.value),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => controller.pickDate(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.detailsController,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      labelText: 'التفاصيل',
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'صورة السند',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final file = controller.imageFile;
                    return Column(
                      children: [
                        if (file != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: controller.showImageSourcePicker,
                          icon: const Icon(Icons.add_a_photo),
                          label: Text(
                            file == null ? 'إرفاق صورة' : 'تغيير الصورة',
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.save,
                      child: controller.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.isEditing
                                  ? 'حفظ التعديلات'
                                  : 'حفظ العملية',
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
