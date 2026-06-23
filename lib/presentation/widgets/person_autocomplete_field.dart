import 'package:flutter/material.dart';
import 'package:pocketentry/core/constants/app_colors.dart';
import 'package:pocketentry/domain/entities/entities.dart';

class PersonAutocompleteField extends StatelessWidget {
  const PersonAutocompleteField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.showSuggestions,
    required this.onChanged,
    required this.onPersonSelected,
    required this.onAddNewPerson,
    this.onClear,
    this.selectedPerson,
    this.validator,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<PersonEntity> suggestions;
  final bool showSuggestions;
  final ValueChanged<String> onChanged;
  final ValueChanged<PersonEntity> onPersonSelected;
  final VoidCallback onAddNewPerson;
  final VoidCallback? onClear;
  final PersonEntity? selectedPerson;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final hasExactMatch = suggestions.any(
      (p) => p.name.toLowerCase() == query.toLowerCase(),
    );
    final showAddNew =
        query.isNotEmpty && !hasExactMatch && selectedPerson == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'اسم الحساب *',
            prefixIcon: const Icon(Icons.person_search),
            suffixIcon: selectedPerson != null
                ? IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      controller.clear();
                      onClear?.call();
                      onChanged('');
                    },
                  )
                : null,
            helperText: selectedPerson != null
                ? '${selectedPerson!.categoryName ?? ''} • ${selectedPerson!.phone}'
                : 'ابحث بالاسم أو رقم الهاتف',
          ),
          validator: validator,
          onChanged: onChanged,
        ),
        if (selectedPerson != null) ...[
          const SizedBox(height: 8),
          Card(
            color: const Color(AppColors.primary).withValues(alpha: 0.08),
            child: ListTile(
              dense: true,
              leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
              title: Text(selectedPerson!.name),
              subtitle: Text(
                '${selectedPerson!.categoryName ?? ''} • ${selectedPerson!.phone}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ],
        if (showSuggestions && selectedPerson == null) ...[
          const SizedBox(height: 4),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  if (suggestions.isEmpty && query.isNotEmpty)
                    ListTile(
                      leading: Icon(
                        Icons.person_off_outlined,
                        color: Colors.grey.shade600,
                      ),
                      title: Text('لا يوجد حساب باسم "$query"'),
                    ),
                  ...suggestions.map(
                    (person) => ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person, size: 18),
                      ),
                      title: Text(person.name),
                      subtitle: Text(
                        '${person.categoryName ?? ''} • ${person.phone}',
                        textDirection: TextDirection.ltr,
                      ),
                      onTap: () => onPersonSelected(person),
                    ),
                  ),
                  if (showAddNew)
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(AppColors.accent),
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text('إضافة حساب جديد: "$query"'),
                      subtitle: const Text('اضغط لإنشاء حساب بهذا الاسم'),
                      onTap: onAddNewPerson,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class RecentPersonsRow extends StatelessWidget {
  const RecentPersonsRow({
    super.key,
    required this.persons,
    required this.onPersonSelected,
  });

  final List<PersonEntity> persons;
  final ValueChanged<PersonEntity> onPersonSelected;

  @override
  Widget build(BuildContext context) {
    if (persons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'آخر الحسابات',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: persons.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final person = persons[index];
              return ActionChip(
                avatar: const Icon(Icons.history, size: 16),
                label: Text(person.name),
                onPressed: () => onPersonSelected(person),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
