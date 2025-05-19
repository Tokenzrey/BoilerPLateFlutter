import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:flutter/material.dart' hide Form;
import 'package:boilerplate/core/widgets/components/forms/form.dart';
import 'package:boilerplate/core/widgets/components/forms/select.dart';

class SelectSandbox extends StatefulWidget {
  const SelectSandbox({super.key});
  static const List<String> fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
  ];

  @override
  State<SelectSandbox> createState() => _SelectSandboxState();
}

class _SelectSandboxState extends State<SelectSandbox> {
  // Controllers untuk ControlledSelect
  late final SelectController<String> _singleCtrl;
  late final MultiSelectController<String> _multiCtrl;

  late final Future<SelectItemDelegate> _itemsFuture;
  String? _selectedSingle;

  @override
  void initState() {
    super.initState();
    _singleCtrl = SelectController<String>();
    _multiCtrl = MultiSelectController<String>();
    _itemsFuture = Future.value(
      SelectItemList(
        children: SelectSandbox.fruits
            .map((f) => SelectItem(
                  value: f,
                  builder: (ctx, selected, highlighted) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: Text(f)),
                        if (selected) Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                ))
            .toList(),
        itemValues: SelectSandbox.fruits,
      ),
    );
  }

  @override
  void dispose() {
    _singleCtrl.dispose();
    _multiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('1. Standalone Single Select (controlled)'),
        _buildControlledSingle(),
        _section('2. Styled SelectField'),
        _buildStyledSelect(),
        _section('3. Standalone Multi Select (controlled)'),
        _buildControlledMulti(),
        _section('4. Form Single Select with Validation'),
        _buildFormSingle(),
        _section('5. Form Multi Select with Validation'),
        _buildFormMulti(),
        _section('6. Advanced Popup Features'),
        _buildAdvanced(),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _buildControlledSingle() {
    return ControlledSelect<String>(
      selectController: _singleCtrl,
      popupWidthConstraint: PopoverConstraint.fixed,
      canUnselect: true,
      autoClosePopover: false,
      placeholder: const Text('Choose a fruit...'),
      popup: (_) => SelectPopup<String>(items: _itemsFuture),
      itemBuilder: (_, v) => Text(v),
    );
  }

  Widget _buildStyledSelect() {
    return SelectField<String>(
      placeholder: const Text('Styled placeholder...'),
      value: _selectedSingle,
      onChanged: (v) {
        setState(() {
          _selectedSingle = v;
        });
      },
      itemBuilder: (_, v) => Text(v),
      popup: (_) => SelectPopup<String>(items: _itemsFuture),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      focusedDecoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
      ),
      hoverDecoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade700, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildControlledMulti() {
    return ControlledMultiSelect<String>(
      multiSelectController: _multiCtrl,
      allItems: SelectSandbox.fruits,
      placeholder: const Text('Pick fruits...'),
      popup: (_) => SelectPopup<String>(items: _itemsFuture),
      itemBuilder: (_, v) => Chip(label: Text(v)),
      showSelectAll: true,
      selectAllLabel: 'Select All Fruits',
      clearAllLabel: 'Clear All Fruits',
    );
  }

  // 4. Form Single Select
  Widget _buildFormSingle() {
    return Form(
      onSubmit: (values) => debugPrint('Form submitted: $values'),
      onError: (errors) => debugPrint('Form errors: $errors'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSelectField<String>(
            formKey: const FormKey<String?>('favFruit'),
            label: 'Favorite Fruit',
            isRequired: true,
            validators: [NonNullValidator(message: 'Please pick one')],
            placeholder: const Text('Select...'),
            popup: (ctx) => SelectPopup.builder(
              builder: (ctx, query) async {
                await Future.delayed(const Duration(milliseconds: 300));
                final filtered = SelectSandbox.fruits.where((f) =>
                    query == null ||
                    f.toLowerCase().contains(query.toLowerCase()));
                return SelectItemList(
                  children: filtered
                      .map((f) => SelectItem(
                            value: f,
                            builder: (ctx, selected, _) => Row(
                              children: [
                                Expanded(child: Text(f)),
                                if (selected)
                                  Icon(Icons.check, color: Colors.green),
                              ],
                            ),
                          ))
                      .toList(),
                  itemValues: SelectSandbox.fruits,
                );
              },
              enableSearch: true,
              searchPlaceholder: 'Filter…',
              divider: const Divider(height: 1),
            ),
            itemBuilder: (ctx, v) => Text(v),
          ),
          const SizedBox(height: 12),
          const SubmitButton(child: Text('Submit Single')),
        ],
      ),
    );
  }

  // 5. Form Multi Select
  Widget _buildFormMulti() {
    return Form(
      onSubmit: (values) => debugPrint('Form multi submitted: $values'),
      onError: (errors) => debugPrint('Form multi errors: $errors'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormMultiSelectField<String>(
            formKey: const FormKey<Iterable<String>>('myFruits'),
            label: 'Your Fruits',
            helperText: 'Choose at least two',
            isRequired: true,
            validators: [
              ValidatorBuilder<Iterable<String>>(
                (vals, mode) {
                  if (vals == null || vals.length < 2) {
                    return InvalidResult('Select 2+', mode: mode);
                  }
                  return ValidResult.instance;
                },
              )
            ],
            placeholder: const Text('Select fruits...'),
            allItems: SelectSandbox.fruits,
            showSelectAll: true,
            selectAllLabel: 'All Fruits',
            clearAllLabel: 'None',
            popup: (_) => SelectPopup<String>(items: _itemsFuture),
            itemBuilder: (_, v) => Chip(label: Text(v)),
          ),
          const SizedBox(height: 12),
          const SubmitButton(child: Text('Submit Multi')),
        ],
      ),
    );
  }

  // 6. Advanced Popup (search + infinite scroll)
  Widget _buildAdvanced() {
    return SelectField<String>(
      placeholder: const Text('Search & infinite scroll…'),
      itemBuilder: (_, v) => Text(v),
      popup: (ctx) => SelectPopup.builder(
        builder: (ctx, query) async {
          // simulate paginated fetch
          final all = List.generate(100, (i) => 'Item $i');
          final filtered = query == null
              ? all
              : all.where((e) => e.contains(query)).toList();
          await Future.delayed(const Duration(milliseconds: 300));
          return SelectItemList(
            children: filtered
                .map((e) => SelectItem(
                      value: e,
                      builder: (ctx, selected, _) => Row(
                        children: [
                          Expanded(child: Text(e)),
                          if (selected) Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                    ))
                .toList(),
            itemValues: filtered,
          );
        },
        enableSearch: true,
        searchPlaceholder: 'Type to filter…',
        divider: const Divider(height: 1),
      ),
      onChanged: (_) {},
    );
  }
}
