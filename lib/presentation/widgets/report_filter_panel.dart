import 'package:flutter/material.dart';
import 'package:pocketentry/core/enums/app_enums.dart';
import 'package:pocketentry/domain/entities/entities.dart';

class ReportFilterPanel extends StatefulWidget {
  const ReportFilterPanel({
    super.key,
    required this.filter,
    required this.categories,
    required this.persons,
    required this.onChanged,
  });

  final ReportFilter filter;
  final List<CategoryEntity> categories;
  final List<PersonEntity> persons;
  final ValueChanged<ReportFilter> onChanged;

  @override
  State<ReportFilterPanel> createState() => _ReportFilterPanelState();
}

class _ReportFilterPanelState extends State<ReportFilterPanel> {
  bool _expanded = false;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? widget.filter.startDate ?? DateTime.now()
        : widget.filter.endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );
    if (picked == null) return;
    widget.onChanged(
      isStart
          ? widget.filter.copyWith(startDate: picked)
          : widget.filter.copyWith(endDate: picked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: const Text('تصفية التقرير'),
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: true),
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          widget.filter.startDate != null
                              ? 'من: ${widget.filter.startDate!.toString().substring(0, 10)}'
                              : 'من تاريخ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: false),
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          widget.filter.endDate != null
                              ? 'إلى: ${widget.filter.endDate!.toString().substring(0, 10)}'
                              : 'إلى تاريخ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: widget.filter.categoryId,
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...widget.categories.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => widget.onChanged(
                    widget.filter.copyWith(
                      categoryId: v,
                      clearCategory: v == null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: widget.filter.personId,
                  decoration: const InputDecoration(labelText: 'الحساب'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...widget.persons.map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ),
                  ],
                  onChanged: (v) => widget.onChanged(
                    widget.filter.copyWith(personId: v, clearPerson: v == null),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppCurrency?>(
                  initialValue: widget.filter.currency,
                  decoration: const InputDecoration(labelText: 'العملة'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...AppCurrency.values.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c.labelAr)),
                    ),
                  ],
                  onChanged: (v) => widget.onChanged(
                    widget.filter.copyWith(
                      currency: v,
                      clearCurrency: v == null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => widget.onChanged(const ReportFilter()),
                  child: const Text('مسح التصفية'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
