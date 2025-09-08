import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiamondFilterPanel extends StatefulWidget {
  final Map<String, List<String>> filterOptions;
  final Function(Map<String, List<String>>) onFilterChanged;
  final Map<String, List<String>>? initialFilters;
  final bool isHorizontal;

  const DiamondFilterPanel({
    super.key,
    required this.filterOptions,
    required this.onFilterChanged,
    this.initialFilters,
    this.isHorizontal = false,
  });

  @override
  State<DiamondFilterPanel> createState() => _DiamondFilterPanelState();
}

class _DiamondFilterPanelState extends State<DiamondFilterPanel>
    with SingleTickerProviderStateMixin {
  late Map<String, List<String>> _selectedFilters;
  final TextEditingController _caratFromController = TextEditingController();
  final TextEditingController _caratToController = TextEditingController();
  String? _hoveredShape;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Track active filter section
  String _activeSection = 'Shape';

  // Collapse/expand state
  bool _isCollapsed = true;

  // Map of shape names to their respective icons and descriptions
  final Map<String, Map<String, dynamic>> shapeDetails = {
    'ALL': {
      'icon': Icons.select_all,
      'description': 'View all diamond shapes',
      'color': Colors.blue.shade100
    },
    'Round': {
      'icon': Icons.circle_outlined,
      'description': 'Classic and most popular shape',
      'color': Colors.pink.shade50
    },
    'Princess': {
      'icon': Icons.square_outlined,
      'description': 'Square-faced brilliant cut',
      'color': Colors.purple.shade50
    },
    'Cushion': {
      'icon': Icons.rectangle_outlined,
      'description': 'Square or rectangular with rounded corners',
      'color': Colors.indigo.shade50
    },
    'Oval': {
      'icon': Icons.panorama_horizontal_outlined,
      'description': 'Elongated round brilliant cut',
      'color': Colors.blue.shade50
    },
    'Emerald': {
      'icon': Icons.rectangle_outlined,
      'description': 'Step-cut with rectangular shape',
      'color': Colors.green.shade50
    },
    'Pear': {
      'icon': Icons.water_drop_outlined,
      'description': 'Teardrop-shaped brilliant cut',
      'color': Colors.amber.shade50
    },
    'Marquise': {
      'icon': Icons.lens_outlined,
      'description': 'Elongated shape with pointed ends',
      'color': Colors.orange.shade50
    },
    'Radiant': {
      'icon': Icons.crop_square_outlined,
      'description': 'Square or rectangular with cut corners',
      'color': Colors.red.shade50
    },
    'Heart': {
      'icon': Icons.favorite_outline,
      'description': 'Romantic heart-shaped brilliant cut',
      'color': Colors.pink.shade50
    },
    'Asscher': {
      'icon': Icons.stop_outlined,
      'description': 'Square step-cut with layered facets',
      'color': Colors.teal.shade50
    },
  };

  // Map of clarity grades to their descriptions
  final Map<String, String> clarityDescriptions = {
    'FL':
        'Flawless - No inclusions or blemishes visible under 10x magnification',
    'IF': 'Internally Flawless - No inclusions visible under 10x magnification',
    'VVS1':
        'Very Very Slightly Included 1 - Minute inclusions difficult to see',
    'VVS2':
        'Very Very Slightly Included 2 - Minute inclusions slightly easier to see',
    'VS1': 'Very Slightly Included 1 - Minor inclusions difficult to see',
    'VS2': 'Very Slightly Included 2 - Minor inclusions somewhat easy to see',
    'SI1': 'Slightly Included 1 - Noticeable inclusions under magnification',
    'SI2': 'Slightly Included 2 - Noticeable inclusions easily visible',
    'I1': 'Included 1 - Inclusions visible to the naked eye',
    'I2': 'Included 2 - Obvious inclusions visible to the naked eye',
  };

  // Map of color grades to their descriptions
  final Map<String, String> colorDescriptions = {
    'D': 'Absolutely colorless - Highest color grade',
    'E': 'Colorless - Minute traces of color detectable by gemologist',
    'F': 'Colorless - Slight color detected by gemologist',
    'G': 'Near-Colorless - Color noticeable in comparison',
    'H': 'Near-Colorless - Slight color visible',
    'I': 'Near-Colorless - Slight warmth of color visible',
    'J': 'Near-Colorless - Color easily detected',
    'K': 'Faint Color - Noticeable color tint',
    'L': 'Faint Color - Noticeable yellow or brown tint',
    'M': 'Faint Color - Color clearly visible',
    'N': 'Very Light Color',
    'Fancy': 'Natural colored diamonds',
  };

  // Icons for filter categories
  final Map<String, IconData> categoryIcons = {
    'Shape': Icons.diamond_outlined,
    'Carat': Icons.scale_outlined,
    'Color': Icons.color_lens_outlined,
    'Clarity': Icons.visibility_outlined,
    'Cut': Icons.cut_outlined,
    'Polish': Icons.auto_awesome_outlined,
    'Symmetry': Icons.sync_alt_outlined,
    'Lab': Icons.science_outlined,
  };

  @override
  void initState() {
    super.initState();
    _selectedFilters =
        Map<String, List<String>>.from(widget.initialFilters ?? {});
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _caratFromController.dispose();
    _caratToController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Get total selected filters count
  int get _totalSelectedFilters {
    int count = 0;
    _selectedFilters.forEach((key, value) {
      count += value.length;
    });
    if (_caratFromController.text.isNotEmpty ||
        _caratToController.text.isNotEmpty) {
      count += 1; // Count carat range as 1 filter
    }
    return count;
  }

  void _applyFilters() {
    // Create a new map to avoid reference issues
    Map<String, List<String>> filtersToApply = {};

    // Copy all existing filters
    _selectedFilters.forEach((key, value) {
      filtersToApply[key] = List<String>.from(value);
    });

    // Handle carat range if specified
    if (_caratFromController.text.isNotEmpty ||
        _caratToController.text.isNotEmpty) {
      double minCarat = double.tryParse(_caratFromController.text) ?? 0.0;
      double maxCarat = double.tryParse(_caratToController.text) ?? 0.0;

      // Only add carat range if both values are valid
      if (minCarat > 0 || maxCarat > 0) {
        filtersToApply['Carat'] = [
          '${minCarat.toStringAsFixed(2)}-${maxCarat.toStringAsFixed(2)}'
        ];
      }
    }

    // Apply the filters
    widget.onFilterChanged(filtersToApply);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied $_totalSelectedFilters filters'),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedFilters = {};
      _caratFromController.clear();
      _caratToController.clear();
    });
    widget.onFilterChanged({});

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All filters reset'),
        backgroundColor: Colors.blueGrey,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildShapeButton(String shape) {
    final isSelected = _selectedFilters['Shape']?.contains(shape) ?? false;
    final isAll = shape == 'ALL';
    final details = shapeDetails[shape]!;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredShape = shape);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _hoveredShape = null);
        _controller.reverse();
      },
      child: Tooltip(
        message: details['description'] as String,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _hoveredShape == shape ? _scaleAnimation.value : 1.0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFilters['Shape']?.remove(shape);
                      if (_selectedFilters['Shape']?.isEmpty == true) {
                        _selectedFilters.remove('Shape');
                      }
                    } else {
                      if (isAll) {
                        _selectedFilters.remove('Shape');
                      } else {
                        _selectedFilters
                            .putIfAbsent('Shape', () => [])
                            .add(shape);
                      }
                    }
                  });
                },
                child: Container(
                  width: 70,
                  height: 90,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? details['color'] as Color : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    // boxShadow: _hoveredShape == shape || isSelected
                    //     ? [
                    //         BoxShadow(
                    //           color: (isSelected
                    //                   ? Theme.of(context).primaryColor
                    //                   : Colors.grey)
                    //               .withOpacity(0.3),
                    //           spreadRadius: 1,
                    //           blurRadius: 5,
                    //           offset: const Offset(0, 2),
                    //         ),
                    //       ]
                    //     : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        details['icon'] as IconData,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade600,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        shape,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String category, String value) {
    final isSelected = _selectedFilters[category]?.contains(value) ?? false;
    String? tooltip;

    if (category == 'Clarity') {
      tooltip = clarityDescriptions[value];
    } else if (category == 'Color') {
      tooltip = colorDescriptions[value];
    }

    return Tooltip(
      message: tooltip ?? value,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 8),
        child: FilterChip(
          label: Text(value),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedFilters.putIfAbsent(category, () => []).add(value);
              } else {
                _selectedFilters[category]?.remove(value);
                if (_selectedFilters[category]?.isEmpty == true) {
                  _selectedFilters.remove(category);
                }
              }
            });
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          checkmarkColor: Theme.of(context).primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
          showCheckmark: true,
          elevation: isSelected ? 2 : 0,
          pressElevation: 4,
        ),
      ),
    );
  }

  Widget _buildCaratRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _caratFromController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Min Carat',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixText: 'ct',
                    suffixStyle: TextStyle(color: Colors.grey.shade500),
                    hoverColor: Colors.white,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _caratToController,
                  decoration: InputDecoration(
                    hintText: 'Max Carat',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: 'ct',
                    suffixStyle: TextStyle(color: Colors.grey.shade500),
                    hoverColor: Colors.white,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Add common carat values as quick-select buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var caratValue in [0.5, 1.0, 1.5, 2.0, 3.0])
              InkWell(
                onTap: () {
                  setState(() {
                    _caratFromController.text = '0';
                    _caratToController.text = caratValue.toString();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text('0-${caratValue.toString()} ct'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryNav() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var category in [
            'Shape',
            'Carat',
            'Color',
            'Clarity',
            'Cut',
            'Polish',
            'Symmetry',
            'Lab'
          ])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activeSection = category;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _activeSection == category
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _activeSection == category
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        categoryIcons[category] ?? Icons.filter_list,
                        color: _activeSection == category
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: TextStyle(
                          color: _activeSection == category
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: _activeSection == category
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (_selectedFilters[category]?.isNotEmpty == true ||
                          (category == 'Carat' &&
                              (_caratFromController.text.isNotEmpty ||
                                  _caratToController.text.isNotEmpty)))
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _activeSection == category
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              category == 'Carat'
                                  ? (_caratFromController.text.isNotEmpty ||
                                          _caratToController.text.isNotEmpty
                                      ? '1'
                                      : '0')
                                  : _selectedFilters[category]
                                          ?.length
                                          .toString() ??
                                      '0',
                              style: TextStyle(
                                color: _activeSection == category
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveSection() {
    switch (_activeSection) {
      case 'Shape':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              _buildShapeButton('ALL'),
              ...widget.filterOptions['Shape']
                      ?.map((shape) => _buildShapeButton(shape))
                      .toList() ??
                  [],
            ],
          ),
        );
      case 'Carat':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildCaratRangeFilter(),
        );
      default:
        // For all other filter categories (Color, Clarity, Cut, Polish, Symmetry, Lab)
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Wrap(
                children: [
                  ...widget.filterOptions[_activeSection]
                          ?.map((value) =>
                              _buildFilterChip(_activeSection, value))
                          .toList() ??
                      (_activeSection == 'Lab'
                          ? ['GIA', 'IGI', 'HRD', 'Other']
                              .map((value) =>
                                  _buildFilterChip(_activeSection, value))
                              .toList()
                          : []),
                ],
              ),
            ],
          ),
        );
    }
  }

  Widget _buildFilterSummary() {
    if (_totalSelectedFilters == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 16),
              const SizedBox(width: 8),
              Text(
                'Active Filters ($_totalSelectedFilters)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _resetFilters,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Carat range chip
              if (_caratFromController.text.isNotEmpty ||
                  _caratToController.text.isNotEmpty)
                Chip(
                  label: Text(
                      'Carat: ${_caratFromController.text}-${_caratToController.text}'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _caratFromController.clear();
                      _caratToController.clear();
                      _selectedFilters.remove('Carat');
                    });
                  },
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.1),
                  side: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3)),
                ),

              // Other filter chips
              for (var category in _selectedFilters.keys)
                for (var value in _selectedFilters[category] ?? [])
                  Chip(
                    label: Text('$category: $value'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedFilters[category]?.remove(value);
                        if (_selectedFilters[category]?.isEmpty == true) {
                          _selectedFilters.remove(category);
                        }
                      });
                    },
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    side: BorderSide(
                        color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and filter count + collapse/expand button
          Row(
            children: [
              const Icon(Icons.diamond_outlined, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Diamond Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_totalSelectedFilters Filters Applied',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon:
                    Icon(_isCollapsed ? Icons.expand_more : Icons.expand_less),
                tooltip: _isCollapsed ? 'Expand Filters' : 'Collapse Filters',
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
            ],
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 30,
                ),

                // Filter summary section
                _buildFilterSummary(),

                // Category navigation
                _buildCategoryNav(),

                const SizedBox(height: 16),
                // Active section content
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildActiveSection(),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _applyFilters,
                      icon: const Icon(Icons.check),
                      label: const Text('Apply Filters'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            crossFadeState: _isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
