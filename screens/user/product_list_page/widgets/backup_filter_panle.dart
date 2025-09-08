import 'package:flutter/material.dart';
import 'package:jewellery_diamond/constant/app_constant.dart';

class BackupFilterPanel extends StatefulWidget {
  final List<String> selectedShapes;
  final double? minPrice;
  final double? maxPrice;
  final double? minCarat;
  final double? maxCarat;
  final String selectedCut;
  final String selectedColor;
  final String selectedClarity;
  final String sortOption;
  final Function(
    List<String> selectedShapes,
    double? minPrice,
    double? maxPrice,
    double? minCarat,
    double? maxCarat,
    String selectedCut,
    String selectedColor,
    String selectedClarity,
    String sortOption,
  ) onFilterChanged;

  const BackupFilterPanel({
    super.key,
    required this.selectedShapes,
    required this.minPrice,
    required this.maxPrice,
    required this.minCarat,
    required this.maxCarat,
    required this.selectedCut,
    required this.selectedColor,
    required this.selectedClarity,
    required this.sortOption,
    required this.onFilterChanged,
  });

  @override
  State<BackupFilterPanel> createState() => _BackupFilterPanelState();
}

class _BackupFilterPanelState extends State<BackupFilterPanel> {
  late List<String> _tempSelectedShapes;
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _minCaratController;
  late TextEditingController _maxCaratController;
  late String _tempCut;
  late String _tempColor;
  late String _tempClarity;
  late String _tempSort;
  double smalltextsize = 14;
  double middtextsize = 16;

  @override
  void initState() {
    super.initState();
    _tempSelectedShapes = List.from(widget.selectedShapes);
    _minPriceController =
        TextEditingController(text: widget.minPrice?.toString() ?? '');
    _maxPriceController =
        TextEditingController(text: widget.maxPrice?.toString() ?? '');
    _minCaratController =
        TextEditingController(text: widget.minCarat?.toString() ?? '');
    _maxCaratController =
        TextEditingController(text: widget.maxCarat?.toString() ?? '');
    _tempCut = widget.selectedCut;
    _tempColor = widget.selectedColor;
    _tempClarity = widget.selectedClarity;
    _tempSort = widget.sortOption;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minCaratController.dispose();
    _maxCaratController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final double? minPrice = _minPriceController.text.isNotEmpty
        ? double.tryParse(_minPriceController.text)
        : null;
    final double? maxPrice = _maxPriceController.text.isNotEmpty
        ? double.tryParse(_maxPriceController.text)
        : null;
    final double? minCarat = _minCaratController.text.isNotEmpty
        ? double.tryParse(_minCaratController.text)
        : null;
    final double? maxCarat = _maxCaratController.text.isNotEmpty
        ? double.tryParse(_maxCaratController.text)
        : null;

    widget.onFilterChanged(
      _tempSelectedShapes,
      minPrice,
      maxPrice,
      minCarat,
      maxCarat,
      _tempCut,
      _tempColor,
      _tempClarity,
      _tempSort,
    );
  }

  // Helper for section titles.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w200, fontSize: 15.5),
    );
  }

  // Title row with "Filters" title and "Clear All" button.
  Widget _buildTitleRow() {
    return Row(
      children: [
        Text(
          'Filters',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const Spacer(),
        TextButton(
          child: const Text('Clear All'),
          onPressed: () {
            setState(() {
              _tempSelectedShapes.clear();
              _minPriceController.clear();
              _maxPriceController.clear();
              _minCaratController.clear();
              _maxCaratController.clear();
              _tempCut = 'All';
              _tempColor = 'All';
              _tempClarity = 'All';
              _tempSort = '';
            });
            _applyFilters();
          },
        ),
      ],
    );
  }

  // Shape filter section using FilterChip widgets.
  Widget _buildShapeFilter() {
    final shapes = ['Round', 'Princess', 'Oval', 'Emerald'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: shapes.map((shape) {
        return FilterChip(
          label: Text(
            shape,
            style: TextStyle(fontSize: 13),
          ),
          labelStyle: _tempSelectedShapes.contains(shape)
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white)
              : Theme.of(context).textTheme.bodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          selected: _tempSelectedShapes.contains(shape),
          showCheckmark: false,
          selectedColor: Theme.of(context).primaryColor,
          // checkmarkColor: Colors.white,
          visualDensity: VisualDensity.compact,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _tempSelectedShapes.add(shape);
              } else {
                _tempSelectedShapes.remove(shape);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // Price filter section with min and max price text fields.
  Widget _buildPriceFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min',
              labelStyle: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _maxPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max',
              labelStyle: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }

  // Carat filter section with min and max carat text fields.
  Widget _buildCaratFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minCaratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Min',
              labelStyle: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _maxCaratController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Max',
              labelStyle: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown for selecting the cut.
  Widget _buildCutDropdown() {
    return DropdownButton<String>(
      value: _tempCut,
      isExpanded: true,
      enableFeedback: false,
      focusColor: Colors.transparent,
      items: ['All', 'Excellent', 'Very Good', 'Good']
          .map((cut) => DropdownMenuItem(
              child: Text(
                cut,
                style: TextStyle(
                    fontSize: smalltextsize,
                    color: Theme.of(context).colorScheme.outline),
              ),
              value: cut))
          .toList(),
      onChanged: (value) {
        setState(() {
          _tempCut = value ?? 'All';
        });
      },
    );
  }

  // Dropdown for selecting the color.
  Widget _buildColorDropdown() {
    return DropdownButton<String>(
      value: _tempColor,
      isExpanded: true,
      items: ['All', 'D', 'E', 'F', 'G']
          .map((color) => DropdownMenuItem(
              child: Text(
                color,
                style: TextStyle(
                    fontSize: smalltextsize,
                    color: Theme.of(context).colorScheme.outline),
              ),
              value: color))
          .toList(),
      enableFeedback: false,
      focusColor: Colors.transparent,
      onChanged: (value) {
        setState(() {
          _tempColor = value ?? 'All';
        });
      },
    );
  }

  // Dropdown for selecting the clarity.
  Widget _buildClarityDropdown() {
    return DropdownButton<String>(
      value: _tempClarity,
      isExpanded: true,
      enableFeedback: false,
      focusColor: Colors.transparent,
      items: ['All', 'FL', 'IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2']
          .map((clarity) => DropdownMenuItem(
              child: Text(
                clarity,
                style: TextStyle(
                    fontSize: smalltextsize,
                    color: Theme.of(context).colorScheme.outline),
              ),
              value: clarity))
          .toList(),
      onChanged: (value) {
        setState(() {
          _tempClarity = value ?? 'All';
        });
      },
    );
  }

  // Dropdown for selecting the sort option.
  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _tempSort,
      isExpanded: true,
      enableFeedback: false,
      focusColor: Colors.transparent,
      items: [
        DropdownMenuItem(
            value: '',
            child: Text(
              'Default',
              style: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            )),
        DropdownMenuItem(
            value: 'priceLowHigh',
            child: Text(
              'Price: Low to High',
              style: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            )),
        DropdownMenuItem(
            value: 'priceHighLow',
            child: Text(
              'Price: High to Low',
              style: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            )),
        DropdownMenuItem(
            value: 'caratLowHigh',
            child: Text(
              'Carat: Low to High',
              style: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            )),
        DropdownMenuItem(
            value: 'caratHighLow',
            child: Text(
              'Carat: High to Low',
              style: TextStyle(
                  fontSize: smalltextsize,
                  color: Theme.of(context).colorScheme.outline),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _tempSort = value ?? '';
        });
      },
    );
  }

  // Button to apply filters.
  Widget _buildApplyFiltersButton() {
    return FilledButton(
      onPressed: () {
        _applyFilters();
        // For modal bottom sheet, pop after applying.
        if (MediaQuery.of(context).size.width < 800) {
          Navigator.pop(context);
        }
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      child: const Text('Apply Filters'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Theme(
          data: CustomAppTheme.lightTheme.copyWith(
            primaryColor: Theme.of(context).primaryColor,
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade400,
                  ),
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade400,
                  ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleRow(),
              const Divider(),
              _buildSectionTitle('Shape'),
              const SizedBox(height: 5),
              _buildShapeFilter(),
              const SizedBox(height: 16),
              _buildSectionTitle('Price'),
              _buildPriceFilter(),
              const SizedBox(height: 16),
              _buildSectionTitle('Carat'),
              _buildCaratFilter(),
              const SizedBox(height: 16),
              _buildSectionTitle('Cut'),
              _buildCutDropdown(),
              const SizedBox(height: 16),
              _buildSectionTitle('Color'),
              _buildColorDropdown(),
              const SizedBox(height: 16),
              _buildSectionTitle('Clarity'),
              _buildClarityDropdown(),
              const SizedBox(height: 16),
              _buildSectionTitle('Sort By'),
              _buildSortDropdown(),
              const SizedBox(height: 24),
              _buildApplyFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }
}
