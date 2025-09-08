import 'package:flutter/material.dart';

class FilterPanel extends StatefulWidget {
  final Map<String, List<String>> filterOptions;
  final Function(Map<String, List<String>>) onFilterChanged;
  final Map<String, List<String>>? initialFilters;

  const FilterPanel({
    super.key,
    required this.filterOptions,
    required this.onFilterChanged,
    this.initialFilters,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late Map<String, List<String>> _selectedFilters;
  final Map<String, bool> _expandedSections = {};

  String? _hoveredOption;

  final Color _textColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _selectedFilters =
        Map<String, List<String>>.from(widget.initialFilters ?? {});

    for (final key in widget.filterOptions.keys) {
      _expandedSections[key] = true;
    }
  }

  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilters != oldWidget.initialFilters) {
      setState(() {
        _selectedFilters =
            Map<String, List<String>>.from(widget.initialFilters ?? {});
      });
    }
  }

  void _applyFilters() {
    widget.onFilterChanged(_selectedFilters);
  }

  void _resetFilters() {
    setState(() {
      _selectedFilters = {};
    });
    widget.onFilterChanged({});
  }

  Widget _buildCategoryHeader(String title) {
    final isExpanded = _expandedSections[title] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedSections[title] = !isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            Icon(
              isExpanded ? Icons.remove : Icons.add,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElegantOption(String category, String option) {
    final isSelected = _selectedFilters[category]?.contains(option) ?? false;
    final isHovered = _hoveredOption == '$category:$option';

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredOption = '$category:$option'),
      onExit: (_) => setState(() => _hoveredOption = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedFilters[category]?.remove(option);
              if (_selectedFilters[category]?.isEmpty == true) {
                _selectedFilters.remove(category);
              }
            } else {
              _selectedFilters.putIfAbsent(category, () => []).add(option);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    color: isHovered || isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isHovered && !isSelected)
                Icon(
                  Icons.add,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    bool isExpanded = _expandedSections[title] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(title),
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: options
                  .map((option) => _buildElegantOption(title, option))
                  .toList(),
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildSelectedFiltersBar() {
    int totalFilters =
        _selectedFilters.values.fold(0, (sum, list) => sum + list.length);

    if (totalFilters == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SELECTED FILTERS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: _resetFilters,
                child: Text(
                  "Clear All",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var entry in _selectedFilters.entries)
                for (var option in entry.value)
                  _buildMinimalistFilterChip(entry.key, option),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistFilterChip(String category, String option) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
            color: Theme.of(context).colorScheme.primary, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilters[category]?.remove(option);
                if (_selectedFilters[category]?.isEmpty == true) {
                  _selectedFilters.remove(category);
                }
              });
            },
            child: Icon(
              Icons.close,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'REFINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ),
                if (_selectedFilters.isNotEmpty)
                  TextButton(
                    onPressed: _resetFilters,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _buildSelectedFiltersBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.filterOptions.entries
                    .map((entry) => _buildFilterSection(entry.key, entry.value))
                    .toList(),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
            ),
            child: FilledButton(
              onPressed: () {
                _applyFilters();
                if (MediaQuery.of(context).size.width < 800) {
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: const Text(
                'APPLY FILTERS',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
