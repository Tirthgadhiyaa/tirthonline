// lib/screens/buyer_panel/saved_search/saved_search_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../bloc/saved_search_bloc/saved_search_bloc.dart';
import '../../../bloc/saved_search_bloc/saved_search_event.dart';
import '../../../bloc/saved_search_bloc/saved_search_state.dart';
import '../../../models/saved_search_model.dart';

class SavedSearchFormScreen extends StatefulWidget {
  final SavedSearchModel? initialSearch;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;

  const SavedSearchFormScreen({
    super.key,
    this.initialSearch,
    this.onCancel,
    this.onSave,
  });

  @override
  State<SavedSearchFormScreen> createState() => SavedSearchFormScreenState();
}

class SavedSearchFormScreenState extends State<SavedSearchFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _caratFromController = TextEditingController();
  final TextEditingController _caratToController = TextEditingController();
  final TextEditingController _priceFromController = TextEditingController();
  final TextEditingController _priceToController = TextEditingController();

  String? _selectedShape;
  List<String> _selectedColors = [];
  List<String> _selectedClarity = [];
  List<String> _selectedCut = [];
  List<String> _selectedPolish = [];
  List<String> _selectedSymmetry = [];
  List<String> _selectedLab = [];

  bool _isDefault = false;
  bool _isSaving = false;
  int _activeStep = 0;

  late AnimationController _animationController;
  late Animation<double> _formAnimation;

  // Shape details with icons and colors
  final Map<String, Map<String, dynamic>> shapeDetails = {
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

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
    _formAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation
    _animationController.forward();

    // Initialize form with data if editing
    if (widget.initialSearch != null) {
      _nameController.text = widget.initialSearch!.name;
      _descriptionController.text = widget.initialSearch!.description ?? '';
      _isDefault = widget.initialSearch!.isDefault;

      // Set shape
      _selectedShape = (widget.initialSearch!.filters['shape'] ?? []).isNotEmpty
          ? widget.initialSearch!.filters['shape']![0]
          : null;

      // Set color, clarity, cut, polish, symmetry, lab
      _selectedColors =
          List<String>.from(widget.initialSearch!.filters['color'] ?? []);
      _selectedClarity =
          List<String>.from(widget.initialSearch!.filters['clarity'] ?? []);
      _selectedCut =
          List<String>.from(widget.initialSearch!.filters['cut'] ?? []);
      _selectedPolish =
          List<String>.from(widget.initialSearch!.filters['polish'] ?? []);
      _selectedSymmetry =
          List<String>.from(widget.initialSearch!.filters['symmetry'] ?? []);
      _selectedLab =
          List<String>.from(widget.initialSearch!.filters['lab'] ?? []);

      // Parse carat range if present
      final carat = widget.initialSearch!.filters['carat'];
      if (carat != null && carat.isNotEmpty) {
        final parts = carat[0].split('-');
        if (parts.length == 2) {
          _caratFromController.text = parts[0];
          _caratToController.text = parts[1];
        }
      }

      // Parse price range if present
      final price = widget.initialSearch!.filters['price'];
      if (price != null && price.isNotEmpty) {
        final parts = price[0].split('-');
        if (parts.length == 2) {
          _priceFromController.text = parts[0];
          _priceToController.text = parts[1];
        }
      }
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _caratFromController.dispose();
    _caratToController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    super.dispose();
  }

  // Check if form is valid
  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty &&
      (_selectedShape != null ||
          _selectedColors.isNotEmpty ||
          _selectedClarity.isNotEmpty ||
          (_caratFromController.text.isNotEmpty &&
              _caratToController.text.isNotEmpty) ||
          (_priceFromController.text.isNotEmpty &&
              _priceToController.text.isNotEmpty));

  // Save the form
  void _save() {
    if (!_isFormValid) return;

    if (widget.onSave != null) {
      widget.onSave!();
      return;
    }

    setState(() => _isSaving = true);

    final model = SavedSearchModel(
      id: widget.initialSearch?.id ?? '',
      userId: widget.initialSearch?.userId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      isDefault: _isDefault,
      filters: {
        if (_selectedShape != null) 'shape': [_selectedShape!],
        if (_caratFromController.text.isNotEmpty &&
            _caratToController.text.isNotEmpty)
          'carat': ['${_caratFromController.text}-${_caratToController.text}'],
        if (_priceFromController.text.isNotEmpty &&
            _priceToController.text.isNotEmpty)
          'price': ['${_priceFromController.text}-${_priceToController.text}'],
        if (_selectedColors.isNotEmpty) 'color': _selectedColors,
        if (_selectedClarity.isNotEmpty) 'clarity': _selectedClarity,
        if (_selectedCut.isNotEmpty) 'cut': _selectedCut,
        if (_selectedPolish.isNotEmpty) 'polish': _selectedPolish,
        if (_selectedSymmetry.isNotEmpty) 'symmetry': _selectedSymmetry,
        if (_selectedLab.isNotEmpty) 'lab': _selectedLab,
      },
      dateSaved: widget.initialSearch?.dateSaved ?? DateTime.now(),
    );

    if (widget.initialSearch == null) {
      context.read<SavedSearchBloc>().add(CreateSavedSearch(model));
    //  _resetForm();
    } else {
      context.read<SavedSearchBloc>().add(UpdateSavedSearch(model));
  //    _resetForm();
    }
  }

  // Build a card for each filter section
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget content,
    required double width,
    Color? iconColor,
    Color? headerColor,
  }) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveHeaderColor =
        headerColor ?? theme.colorScheme.primary.withOpacity(0.12);

    return Container(
      width: width,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: effectiveHeaderColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: effectiveIconColor, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectiveIconColor,
                  ),
                ),
              ],
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      // Clear text controllers
      _nameController.clear();
      _descriptionController.clear();
      _caratFromController.clear();
      _caratToController.clear();
      _priceFromController.clear();
      _priceToController.clear();

      // Reset dropdown / single selections
      _selectedShape = null;

      // Clear multi-select lists
      _selectedColors.clear();
      _selectedClarity.clear();
      _selectedCut.clear();
      _selectedPolish.clear();
      _selectedSymmetry.clear();
      _selectedLab.clear();

      // Reset flags
      _isDefault = false;
      _activeStep = 0;

    });
  }

  // Build the shape selection section
  Widget _buildShapeSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: shapeDetails.keys.map((shape) {
        final details = shapeDetails[shape]!;
        final isSelected = _selectedShape == shape;

        return Tooltip(
          message: details['description'] as String,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedShape = shape;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 90,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? details['color'] as Color : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    details['icon'] as IconData,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shape,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
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
      }).toList(),
    );
  }

  // Build the carat range section
  Widget _buildRangeSection({
    required TextEditingController fromController,
    required TextEditingController toController,
    required String label,
    required IconData icon,
    String? fromHint,
    String? toHint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: fromController,
                decoration: InputDecoration(
                  labelText: 'From',
                  hintText: fromHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(icon),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: toController,
                decoration: InputDecoration(
                  labelText: 'To',
                  hintText: toHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(icon),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build a filter chip section
  Widget _buildFilterChipSection({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
    Map<String, Color>? optionColors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            if (selectedValues.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    onChanged([]);
                  });
                },
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = selectedValues.contains(option);
            final color = optionColors?[option];

            return FilterChip(
              label: Text(option),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    onChanged([...selectedValues, option]);
                  } else {
                    onChanged(
                        selectedValues.where((e) => e != option).toList());
                  }
                });
              },
              selectedColor: color ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: color != null
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              backgroundColor: color != null && selected
                  ? color.withOpacity(0.8)
                  : Colors.grey.shade100,
              labelStyle: TextStyle(
                color: selected && color != null
                    ? Colors.white
                    : selected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black87,
                fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected
                      ? color ?? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: selected ? 1 : 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Build the basic info section
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Filter Name',
            hintText: 'Enter a name for this saved filter',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.bookmark_outline),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name for your filter';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Add notes about this search',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          maxLines: 2,
        ),
        // const SizedBox(height: 16),
        // SwitchListTile(
        //   title: const Text('Set as Default Search'),
        //   subtitle: const Text(
        //       'This search will be applied automatically when you visit the diamond listing'),
        //   value: _isDefault,
        //   onChanged: (value) {
        //     setState(() {
        //       _isDefault = value;
        //     });
        //   },
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(8),
        //     side: BorderSide(color: Colors.grey.shade300),
        //   ),
        //   contentPadding:
        //       const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // ),
      ],
    );
  }

  // Build the color section with color-coded chips
  Widget _buildColorSection() {
    final colorOptions = [
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'Fancy'
    ];

    // Color gradient for diamond colors
    final colorMap = {
      'D': Colors.blue.shade100,
      'E': Colors.blue.shade200,
      'F': Colors.blue.shade300,
      'G': Colors.green.shade200,
      'H': Colors.green.shade300,
      'I': Colors.green.shade400,
      'J': Colors.amber.shade200,
      'K': Colors.amber.shade300,
      'L': Colors.amber.shade400,
      'M': Colors.amber.shade500,
      'N': Colors.amber.shade600,
      'Fancy': Colors.pink.shade300,
    };

    return _buildFilterChipSection(
      title: 'Color Grade',
      options: colorOptions,
      selectedValues: _selectedColors,
      onChanged: (values) {
        setState(() {
          _selectedColors = values;
        });
      },
      optionColors: colorMap,
    );
  }

  // Build the clarity section
  Widget _buildClaritySection() {
    final clarityOptions = [
      'FL',
      'IF',
      'VVS1',
      'VVS2',
      'VS1',
      'VS2',
      'SI1',
      'SI2',
      'I1',
      'I2'
    ];

    return _buildFilterChipSection(
      title: 'Clarity Grade',
      options: clarityOptions,
      selectedValues: _selectedClarity,
      onChanged: (values) {
        setState(() {
          _selectedClarity = values;
        });
      },
    );
  }

  // Build the cut section
  Widget _buildCutSection() {
    final cutOptions = ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'];

    return _buildFilterChipSection(
      title: 'Cut Grade',
      options: cutOptions,
      selectedValues: _selectedCut,
      onChanged: (values) {
        setState(() {
          _selectedCut = values;
        });
      },
    );
  }

  // Build the polish section
  Widget _buildPolishSection() {
    final polishOptions = ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'];

    return _buildFilterChipSection(
      title: 'Polish',
      options: polishOptions,
      selectedValues: _selectedPolish,
      onChanged: (values) {
        setState(() {
          _selectedPolish = values;
        });
      },
    );
  }

  // Build the symmetry section
  Widget _buildSymmetrySection() {
    final symmetryOptions = ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'];

    return _buildFilterChipSection(
      title: 'Symmetry',
      options: symmetryOptions,
      selectedValues: _selectedSymmetry,
      onChanged: (values) {
        setState(() {
          _selectedSymmetry = values;
        });
      },
    );
  }

  // Build the lab section
  Widget _buildLabSection() {
    final labOptions = ['GIA', ' IGI', 'HRD', 'AGS', 'GCAL'];

    return _buildFilterChipSection(
      title: 'Certificate Lab',
      options: labOptions,
      selectedValues: _selectedLab,
      onChanged: (values) {
        setState(() {
          _selectedLab = values;
        });
      },
    );
  }

  // Allow parent to set the form from a model
  void setFromModel(SavedSearchModel? model) {
    setState(() {
      if (model == null) {
        _nameController.clear();
        _descriptionController.clear();
        _selectedShape = null;
        _caratFromController.clear();
        _caratToController.clear();
        _priceFromController.clear();
        _priceToController.clear();
        _selectedColors = [];
        _selectedClarity = [];
        _selectedCut = [];
        _selectedPolish = [];
        _selectedSymmetry = [];
        _selectedLab = [];
        _isDefault = false;
      } else {
        _nameController.text = model.name;
        _descriptionController.text = model.description ?? '';
        _isDefault = model.isDefault;

        _selectedShape = (model.filters['shape'] ?? []).isNotEmpty
            ? model.filters['shape']![0]
            : null;

        _selectedColors = List<String>.from(model.filters['color'] ?? []);
        _selectedClarity = List<String>.from(model.filters['clarity'] ?? []);
        _selectedCut = List<String>.from(model.filters['cut'] ?? []);
        _selectedPolish = List<String>.from(model.filters['polish'] ?? []);
        _selectedSymmetry = List<String>.from(model.filters['symmetry'] ?? []);
        _selectedLab = List<String>.from(model.filters['lab'] ?? []);

        final carat = model.filters['carat'];
        if (carat != null && carat.isNotEmpty) {
          final parts = carat[0].split('-');
          if (parts.length == 2) {
            _caratFromController.text = parts[0];
            _caratToController.text = parts[1];
          }
        } else {
          _caratFromController.clear();
          _caratToController.clear();
        }

        final price = model.filters['price'];
        if (price != null && price.isNotEmpty) {
          final parts = price[0].split('-');
          if (parts.length == 2) {
            _priceFromController.text = parts[0];
            _priceToController.text = parts[1];
          }
        } else {
          _priceFromController.clear();
          _priceToController.clear();
        }
      }
    });
  }

  // Allow parent to check if form is valid
  bool get isFormValid => _isFormValid;

  // Allow parent to extract a model from the form
  SavedSearchModel toModel(SavedSearchModel? base) {
    return SavedSearchModel(
      id: base?.id ?? '',
      userId: base?.userId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      isDefault: _isDefault,
      filters: {
        if (_selectedShape != null) 'shape': [_selectedShape!],
        if (_caratFromController.text.isNotEmpty &&
            _caratToController.text.isNotEmpty)
          'carat': ['${_caratFromController.text}-${_caratToController.text}'],
        if (_priceFromController.text.isNotEmpty &&
            _priceToController.text.isNotEmpty)
          'price': ['${_priceFromController.text}-${_priceToController.text}'],
        if (_selectedColors.isNotEmpty) 'color': _selectedColors,
        if (_selectedClarity.isNotEmpty) 'clarity': _selectedClarity,
        if (_selectedCut.isNotEmpty) 'cut': _selectedCut,
        if (_selectedPolish.isNotEmpty) 'polish': _selectedPolish,
        if (_selectedSymmetry.isNotEmpty) 'symmetry': _selectedSymmetry,
        if (_selectedLab.isNotEmpty) 'lab': _selectedLab,
      },
      dateSaved: base?.dateSaved ?? DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialSearch != null;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 900;
    final maxFormWidth = 1900.0;

    // Count active filters
    final filtersApplied = [
      if (_selectedShape != null) 1,
      if (_caratFromController.text.isNotEmpty &&
          _caratToController.text.isNotEmpty)
        1,
      if (_priceFromController.text.isNotEmpty &&
          _priceToController.text.isNotEmpty)
        1,
      if (_selectedColors.isNotEmpty) 1,
      if (_selectedClarity.isNotEmpty) 1,
      if (_selectedCut.isNotEmpty) 1,
      if (_selectedPolish.isNotEmpty) 1,
      if (_selectedSymmetry.isNotEmpty) 1,
      if (_selectedLab.isNotEmpty) 1,
    ].length;

    // Get last updated date
    final lastUpdated = widget.initialSearch?.dateSaved;

    return BlocListener<SavedSearchBloc, SavedSearchState>(
      listener: (context, state) {
        if (state is SavedSearchActionSuccess || state is SavedSearchError) {
          setState(() {
            _isSaving = false;
          });
        }
      },
      child: FadeTransition(
        opacity: _formAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxFormWidth),
            child: Material(
              color: Colors.transparent,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Basic info card
                              _buildCard(
                                title: 'Search Information',
                                icon: FontAwesomeIcons.circleInfo,
                                content: _buildBasicInfoSection(),
                                width: double.infinity,
                                iconColor: Colors.blue,
                                headerColor: Colors.blue.withOpacity(0.1),
                              ),

                              // Filter cards in a responsive grid
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWideScreen =
                                      constraints.maxWidth > 900;
                                  final cardWidth = isWideScreen
                                      ? (constraints.maxWidth - 16) / 2
                                      : constraints.maxWidth;

                                  return Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      // Shape card
                                      _buildCard(
                                        title: 'Diamond Shape',
                                        icon: FontAwesomeIcons.gem,
                                        content: _buildShapeSection(),
                                        width: cardWidth,
                                        iconColor: Colors.purple,
                                        headerColor:
                                            Colors.purple.withOpacity(0.1),
                                      ),

                                      // Carat range card
                                      _buildCard(
                                        title: 'Carat Range',
                                        icon: Icons.scale,
                                        content: _buildRangeSection(
                                          fromController: _caratFromController,
                                          toController: _caratToController,
                                          label: 'Carat Weight',
                                          icon: Icons.scale,
                                          fromHint: '0.5',
                                          toHint: '5.0',
                                        ),
                                        width: cardWidth,
                                        iconColor: Colors.amber.shade800,
                                        headerColor:
                                            Colors.amber.withOpacity(0.1),
                                      ),

                                      // Price range card
                                      _buildCard(
                                        title: 'Price Range',
                                        icon: Icons.attach_money,
                                        content: _buildRangeSection(
                                          fromController: _priceFromController,
                                          toController: _priceToController,
                                          label: 'Price (USD)',
                                          icon: Icons.attach_money,
                                          fromHint: '1000',
                                          toHint: '50000',
                                        ),
                                        width: cardWidth,
                                        iconColor: Colors.green,
                                        headerColor:
                                            Colors.green.withOpacity(0.1),
                                      ),

                                      // Color card
                                      _buildCard(
                                        title: 'Color',
                                        icon: Icons.color_lens_outlined,
                                        content: _buildColorSection(),
                                        width: cardWidth,
                                        iconColor: Colors.blue,
                                        headerColor:
                                            Colors.blue.withOpacity(0.1),
                                      ),

                                      // Clarity card
                                      _buildCard(
                                        title: 'Clarity',
                                        icon: Icons.visibility_outlined,
                                        content: _buildClaritySection(),
                                        width: cardWidth,
                                        iconColor: Colors.teal,
                                        headerColor:
                                            Colors.teal.withOpacity(0.1),
                                      ),

                                      // Cut card
                                      _buildCard(
                                        title: 'Cut',
                                        icon: Icons.diamond_outlined,
                                        content: _buildCutSection(),
                                        width: cardWidth,
                                        iconColor: Colors.red,
                                        headerColor:
                                            Colors.red.withOpacity(0.1),
                                      ),

                                      // Polish & Symmetry card
                                      _buildCard(
                                        title: 'Polish & Symmetry',
                                        icon: Icons.auto_fix_high_outlined,
                                        content: Column(
                                          children: [
                                            _buildPolishSection(),
                                            const SizedBox(height: 24),
                                            _buildSymmetrySection(),
                                          ],
                                        ),
                                        width: cardWidth,
                                        iconColor: Colors.orange,
                                        headerColor:
                                            Colors.orange.withOpacity(0.1),
                                      ),

                                      // Lab card
                                      _buildCard(
                                        title: 'Certificate',
                                        icon: FontAwesomeIcons.certificate,
                                        content: _buildLabSection(),
                                        width: cardWidth,
                                        iconColor: Colors.indigo,
                                        headerColor:
                                            Colors.indigo.withOpacity(0.1),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              // Summary card
                              if (_isFormValid)
                                _buildCard(
                                  title: 'Search Summary',
                                  icon: FontAwesomeIcons.clipboardCheck,
                                  content: _buildSummarySection(),
                                  width: double.infinity,
                                  iconColor: theme.colorScheme.primary,
                                  headerColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer action bar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Filter stats
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_list,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$filtersApplied filters applied',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (lastUpdated != null) ...[
                                const SizedBox(width: 12),
                                Text(
                                  'Last updated: ${lastUpdated.day}/${lastUpdated.month}/${lastUpdated.year}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Action buttons
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: widget.onCancel ??
                                    () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              FilledButton.icon(
                                onPressed:
                                    _isFormValid && !_isSaving ? _save : null,
                                icon: _isSaving
                                    ? Container(
                                        width: 16,
                                        height: 16,
                                        padding: const EdgeInsets.all(2),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                    isEdit ? 'Update Search' : 'Save Search'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build a summary of the current search
  Widget _buildSummarySection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search name and description
              Text(
                _nameController.text.isEmpty
                    ? 'Untitled Search'
                    : _nameController.text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_descriptionController.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _descriptionController.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
              const Divider(height: 24),

              // Active filters
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedShape != null)
                    _buildSummaryChip('Shape: $_selectedShape', Colors.purple),
                  if (_caratFromController.text.isNotEmpty &&
                      _caratToController.text.isNotEmpty)
                    _buildSummaryChip(
                        'Carat: ${_caratFromController.text} - ${_caratToController.text}',
                        Colors.amber.shade800),
                  if (_priceFromController.text.isNotEmpty &&
                      _priceToController.text.isNotEmpty)
                    _buildSummaryChip(
                        'Price: \$${_priceFromController.text} - \$${_priceToController.text}',
                        Colors.green),
                  if (_selectedColors.isNotEmpty)
                    _buildSummaryChip(
                        'Color: ${_selectedColors.join(', ')}', Colors.blue),
                  if (_selectedClarity.isNotEmpty)
                    _buildSummaryChip(
                        'Clarity: ${_selectedClarity.join(', ')}', Colors.teal),
                  if (_selectedCut.isNotEmpty)
                    _buildSummaryChip(
                        'Cut: ${_selectedCut.join(', ')}', Colors.red),
                  if (_selectedPolish.isNotEmpty)
                    _buildSummaryChip(
                        'Polish: ${_selectedPolish.join(', ')}', Colors.orange),
                  if (_selectedSymmetry.isNotEmpty)
                    _buildSummaryChip(
                        'Symmetry: ${_selectedSymmetry.join(', ')}',
                        Colors.orange.shade700),
                  if (_selectedLab.isNotEmpty)
                    _buildSummaryChip(
                        'Lab: ${_selectedLab.join(', ')}', Colors.indigo),
                ],
              ),

              if (_isDefault) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Default Search',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Build a summary chip
  Widget _buildSummaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
