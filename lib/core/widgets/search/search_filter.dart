import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:flutter/material.dart' hide showDialog;

enum Demographics {
  shounen,
  shoujo,
  seinen,
  josei,
  none,
}

class SearchFilter extends StatefulWidget {
  final void Function(Map<String, dynamic>) onApply;

  const SearchFilter({
    super.key,
    required this.onApply
  });

  @override
  State<SearchFilter> createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {

  final List<String> createdAtOptions = [
    '3 days ago', '7 days ago', '30 days ago', '3 month ago', '6 month ago', '1 year ago', '2 year ago'
  ];

  final List<String> statusOptions = ['Ongoing', 'Completed', 'Cancelled', 'Hiatus'];

  final List<String> tagsList = [
    'Gray-eyed character', 'Fashionable Male lead', 'Wanted', 'Action', 'Romance'
  ];

  final List<String> years = List.generate(36, (i) => (1990 + i).toString());

  final List<String> demographics = ['Shounen', 'Shoujo', 'Seinen', 'Josei', 'None'];
  
  String _selectedGenre = 'Action';
  String _createdAt = '7 days ago';
  String _status = 'Ongoing';
  List<String> _tags = [];
  final List<ComicType> _selectedComicTypes = [ComicType.manga];
  String _releasedFrom = '2010';
  String _releasedTo = '2010';
  final List<Demographics> _selectedDemographics = [Demographics.shounen];
  int _minChapters = 0;
  bool _hideInMyList = false;
  bool _includeWithoutChapters = false;

  String _getComicTypeLabel(ComicType type) {
    switch (type) {
      case ComicType.manga:
        return 'Manga';
      case ComicType.manhwa:
        return 'Manhwa';
      case ComicType.manhua:
        return 'Manhua';
    }
  }

  String _getDemographicLabel(Demographics type) {
    switch (type) {
      case Demographics.shounen:
        return 'Shounen';
      case Demographics.shoujo:
        return 'Shoujo';
      case Demographics.seinen:
        return 'Seinen';
      case Demographics.josei:
        return 'Josei';
      case Demographics.none:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 300),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Comic Filters'),
              const SizedBox(height: 24),
              _buildParameterRow(
                'Genre',
                _buildGenreSelector(),
              ),
              _buildParameterRow(
                'Created At',
                _buildDropdown(
                  createdAtOptions,
                  _createdAt, (val) => setState(() => _createdAt = val)
                ),
              ),
              _buildParameterRow(
                'Status',
                _buildDropdown(
                  statusOptions,
                  _status, (val) => setState(() => _status = val)
                ),
              ),
              _buildTagsField(),
              _buildComicTypesSelector(),
              _buildReleasedTimeSelector(),
              _buildDemographicSelector(),
              _buildParameterRow(
                'Minimum Chapters',
                _buildNumberField(
                  'Minimum Chapters', 
                  (val) => setState(() => _minChapters = int.tryParse(val) ?? 0)
                ),
              ),
              _buildCheckboxRow(),
              _buildApplyCancelButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return AppText(
      title,
      variant: TextVariant.titleLarge,
      color: AppColors.cardForeground,
      fontWeight: FontWeight.bold,
    );
  }

  Widget _buildParameterRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              label,
              variant: TextVariant.bodyLarge,
              fontWeight: FontWeight.w500,
              color: AppColors.cardForeground,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: control,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String> onChanged) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.subtleBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AppColors.card,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          style: const TextStyle(
            color: AppColors.cardForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGenreSelector() {
    return DropdownButtonFormField<String>(
      dropdownColor: AppColors.card,
      style: const TextStyle(
        color: AppColors.cardForeground,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardForeground.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: ['Action', 'Adventure', 'Comedy', 'Fantasy', 'Magic']
          .map((genre) => DropdownMenuItem(value: genre, child: Text(genre)))
          .toList(),
      onChanged: (value) => value != null ? setState(() => _selectedGenre = value) : null,
      value: 'Action',
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Tags',
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.cardForeground,
        ),
        const SizedBox(height: 12),
        TextField(
          style: const TextStyle(
            color: AppColors.cardForeground,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) {
            setState(() {
              _tags = value.split(',').map((tag) => tag.trim()).toList();
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardForeground.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Enter tags separated by commas',
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildComicTypesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Comic Types',
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.cardForeground,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ComicType.values.map((type) {
            final isSelected = _selectedComicTypes.contains(type);
            return FilterChip(
              label: AppText(
                _getComicTypeLabel(type),
                variant: TextVariant.labelMedium,
                color: isSelected
                    ? AppColors.primaryForeground
                    : AppColors.cardForeground,
              ),
              selected: isSelected,
              onSelected: (sel) => setState(() {
                if (sel) {
                  _selectedComicTypes.add(type);
                } else if (_selectedComicTypes.length > 1) {
                  _selectedComicTypes.remove(type);
                }
              }),
              backgroundColor: AppColors.subtleBackground,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.primaryForeground,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReleasedTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Released Time',
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.cardForeground,
        ),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(years, _releasedFrom, (val) => setState(() => _releasedFrom = val)),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward, color: AppColors.cardForeground),
            const SizedBox(width: 5),
            Expanded(
              child: _buildDropdown(years, _releasedTo, (val) => setState(() => _releasedTo = val)),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDemographicSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Demographic',
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.cardForeground,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Demographics.values.map((type) {
            final isSelected = _selectedDemographics.contains(type);
            return FilterChip(
              label: AppText(
                _getDemographicLabel(type),
                variant: TextVariant.labelMedium,
                color: isSelected
                    ? AppColors.primaryForeground
                    : AppColors.cardForeground,
              ),
              selected: isSelected,
              onSelected: (sel) => setState(() {
                if (sel) {
                  _selectedDemographics.add(type);
                } else if (_selectedDemographics.length > 1) {
                  _selectedDemographics.remove(type);
                }
              }),
              backgroundColor: AppColors.subtleBackground,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.primaryForeground,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNumberField(String label, ValueChanged<String> onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardForeground.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCheckboxRow() {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const AppText('Hide comics in my list', color: AppColors.cardForeground),
            side: const BorderSide(color: AppColors.border),
            value: _hideInMyList,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _hideInMyList = val ?? false),
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const AppText('Include comics without chapters', color: AppColors.cardForeground),
            side: const BorderSide(color: AppColors.border),
            value: _includeWithoutChapters,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => setState(() => _includeWithoutChapters = val ?? false),
          ),
        ),
      ],
    );
   }

  Widget _buildApplyCancelButtons() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.cardForeground.withValues(alpha: 0.7),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              final filter = {
                'genres': _selectedGenre,
                'createdAt': _createdAt,
                'status': _status,
                'tags': _tags,
                'types': _selectedComicTypes.map((e) => _getComicTypeLabel(e)).toList(),    
                'releasedFrom': _releasedFrom,
                'releasedTo': _releasedTo,
                'demographics': _selectedDemographics.map((e) => _getDemographicLabel(e)).toList(),
                'minChapters': _minChapters,
                'hideInMyList': _hideInMyList,
                'includeWithoutChapters': _includeWithoutChapters,
              };
              widget.onApply(filter);
              closeOverlayWithResult(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Apply'),
          ),
        ],
    );
  }
}