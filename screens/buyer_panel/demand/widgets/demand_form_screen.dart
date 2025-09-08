// lib/screens/buyer_panel/demand/widgets/demand_form_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DemandFormScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const DemandFormScreen({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<DemandFormScreen> createState() => _DemandFormScreenState();
}

class _DemandFormScreenState extends State<DemandFormScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  final TextEditingController _caratFromController = TextEditingController();
  final TextEditingController _caratToController = TextEditingController();
  final TextEditingController _colorFromController = TextEditingController();
  final TextEditingController _colorToController = TextEditingController();
  final TextEditingController _clarityFromController = TextEditingController();
  final TextEditingController _clarityToController = TextEditingController();
  final TextEditingController _cutController = TextEditingController();
  final TextEditingController _polishController = TextEditingController();
  final TextEditingController _symmetryController = TextEditingController();
  final TextEditingController _fluorescenceController = TextEditingController();
  final TextEditingController _labController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _timeframeController = TextEditingController();

  // Form state
  String? _selectedShape;
  bool _isFormValid = false;
  bool _requireLaserInscription = false;
  bool _requireDiamondPlot = false;
  bool _requireProportionsDiagram = false;
  bool _giaOnly = false;
  bool _anyLab = true;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _formAnimation;

  // Map of shape names to their respective icons and descriptions
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

  // Scroll controller for the form
  final ScrollController _scrollController = ScrollController();

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

    // Add listeners to form fields to validate
    _caratFromController.addListener(_validateForm);
    _caratToController.addListener(_validateForm);
    _colorFromController.addListener(_validateForm);
    _colorToController.addListener(_validateForm);
    _clarityFromController.addListener(_validateForm);
    _clarityToController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();

    // Dispose all controllers
    _caratFromController.dispose();
    _caratToController.dispose();
    _colorFromController.dispose();
    _colorToController.dispose();
    _clarityFromController.dispose();
    _clarityToController.dispose();
    _cutController.dispose();
    _polishController.dispose();
    _symmetryController.dispose();
    _fluorescenceController.dispose();
    _labController.dispose();
    _notesController.dispose();
    _budgetController.dispose();
    _timeframeController.dispose();

    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // Basic validation - check if essential fields are filled
      _isFormValid = _selectedShape != null &&
          _caratFromController.text.isNotEmpty &&
          _caratToController.text.isNotEmpty &&
          _colorFromController.text.isNotEmpty &&
          _colorToController.text.isNotEmpty &&
          _clarityFromController.text.isNotEmpty &&
          _clarityToController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return FadeTransition(
      opacity: _formAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_formAnimation),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main form content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          // Basic characteristics card
                          _buildCard(
                            title: 'Basic Diamond Characteristics',
                            icon: FontAwesomeIcons.gem,
                            width: isSmallScreen
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2,
                            content:
                                _buildBasicInfoSection(theme, isSmallScreen),
                          ),

                          // Quality preferences card
                          _buildCard(
                            title: 'Diamond Quality Preferences',
                            icon: FontAwesomeIcons.award,
                            width: isSmallScreen
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2,
                            content: _buildQualitySection(theme, isSmallScreen),
                          ),

                          // Certification requirements card
                          _buildCard(
                            title: 'Certification Requirements',
                            icon: FontAwesomeIcons.certificate,
                            width: isSmallScreen
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2,
                            content: _buildCertificationSection(
                                theme, isSmallScreen),
                          ),

                          // Additional details card
                          _buildCard(
                            title: 'Additional Details',
                            icon: FontAwesomeIcons.fileLines,
                            width: isSmallScreen
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2,
                            content: _buildDetailsSection(theme, isSmallScreen),
                          ),

                          // Summary card
                          // _buildCard(
                          //   title: 'Demand Summary',
                          //   icon: FontAwesomeIcons.clipboardCheck,
                          //   width: constraints.maxWidth,
                          //   content:
                          //       _buildSummarySection(theme, isSmallScreen),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _isFormValid ? widget.onSubmit : null,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit Demand'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required double width,
    required Widget content,
  }) {
    return Container(
      width: width,
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
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
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

  Widget _buildBasicInfoSection(ThemeData theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shape selection
        Text(
          'Shape',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
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
                    _validateForm();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 90,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? details['color'] as Color : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.2),
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
                            ? theme.colorScheme.primary
                            : Colors.grey.shade600,
                        size: 30,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        shape,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
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
        ),
        const SizedBox(height: 24),

        // Carat Range
        Text(
          'Carat Range',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _caratFromController,
                decoration: InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _caratToController,
                decoration: InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.scale),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Color Range
        Text(
          'Color Range',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.color_lens_outlined),
                ),
                items: ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M']
                    .map((color) => DropdownMenuItem(
                          value: color,
                          child: Text(color),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _colorFromController.text = value ?? '';
                    _validateForm();
                  });
                },
                hint: const Text('From'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.color_lens_outlined),
                ),
                items: ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M']
                    .map((color) => DropdownMenuItem(
                          value: color,
                          child: Text(color),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _colorToController.text = value ?? '';
                    _validateForm();
                  });
                },
                hint: const Text('To'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Clarity Range
        Text(
          'Clarity Range',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.visibility_outlined),
                ),
                items: [
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
                ]
                    .map((clarity) => DropdownMenuItem(
                          value: clarity,
                          child: Text(clarity),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _clarityFromController.text = value ?? '';
                    _validateForm();
                  });
                },
                hint: const Text('From'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: const Icon(Icons.visibility_outlined),
                ),
                items: [
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
                ]
                    .map((clarity) => DropdownMenuItem(
                          value: clarity,
                          child: Text(clarity),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _clarityToController.text = value ?? '';
                    _validateForm();
                  });
                },
                hint: const Text('To'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQualitySection(ThemeData theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cut
        Text(
          'Cut',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.diamond_outlined),
          ),
          items: ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor']
              .map((cut) => DropdownMenuItem(
                    value: cut,
                    child: Text(cut),
                  ))
              .toList(),
          onChanged: (value) {
            _cutController.text = value ?? '';
          },
          hint: const Text('Select cut'),
        ),
        const SizedBox(height: 24),

        // Polish
        Text(
          'Polish',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.auto_fix_high_outlined),
          ),
          items: ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor']
              .map((polish) => DropdownMenuItem(
                    value: polish,
                    child: Text(polish),
                  ))
              .toList(),
          onChanged: (value) {
            _polishController.text = value ?? '';
          },
          hint: const Text('Select polish'),
        ),
        const SizedBox(height: 24),

        // Symmetry
        Text(
          'Symmetry',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.balance_outlined),
          ),
          items: ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor']
              .map((symmetry) => DropdownMenuItem(
                    value: symmetry,
                    child: Text(symmetry),
                  ))
              .toList(),
          onChanged: (value) {
            _symmetryController.text = value ?? '';
          },
          hint: const Text('Select symmetry'),
        ),
        const SizedBox(height: 24),

        // Fluorescence
        Text(
          'Fluorescence',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.lightbulb_outline),
          ),
          items: ['None', 'Faint', 'Medium', 'Strong', 'Very Strong']
              .map((fluorescence) => DropdownMenuItem(
                    value: fluorescence,
                    child: Text(fluorescence),
                  ))
              .toList(),
          onChanged: (value) {
            _fluorescenceController.text = value ?? '';
          },
          hint: const Text('Select fluorescence'),
        ),
      ],
    );
  }

  Widget _buildCertificationSection(ThemeData theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lab
        Text(
          'Certificate Lab',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.science_outlined),
          ),
          items: ['GIA', 'IGI', 'HRD', 'AGS', 'GCAL']
              .map((lab) => DropdownMenuItem(
                    value: lab,
                    child: Text(lab),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _labController.text = value ?? '';
              _giaOnly = value == 'GIA';
              _anyLab = value == null || value.isEmpty;
            });
          },
          hint: const Text('Select lab'),
        ),
        const SizedBox(height: 24),

        // Lab preferences
        Text(
          'Lab Preferences',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: const Text('GIA Certified Only'),
                subtitle: const Text('Gemological Institute of America'),
                value: _giaOnly,
                onChanged: (value) {
                  setState(() {
                    _giaOnly = value ?? false;
                    if (_giaOnly) {
                      _anyLab = false;
                      _labController.text = 'GIA';
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Accept Any Reputable Lab'),
                subtitle: const Text('GIA, IGI, HRD, AGS, etc.'),
                value: _anyLab,
                onChanged: (value) {
                  setState(() {
                    _anyLab = value ?? false;
                    if (_anyLab) {
                      _giaOnly = false;
                      _labController.text = '';
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Certificate features
        // Text(
        //   'Certificate Features',
        //   style: theme.textTheme.titleSmall?.copyWith(
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        // const SizedBox(height: 8),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade50,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.grey.shade300),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       CheckboxListTile(
        //         title: const Text('Require Laser Inscription'),
        //         subtitle: const Text('Certificate number inscribed on girdle'),
        //         value: _requireLaserInscription,
        //         onChanged: (value) {
        //           setState(() {
        //             _requireLaserInscription = value ?? false;
        //           });
        //         },
        //         controlAffinity: ListTileControlAffinity.leading,
        //         contentPadding: EdgeInsets.zero,
        //       ),
        //       const Divider(),
        //       CheckboxListTile(
        //         title: const Text('Require Diamond Plot'),
        //         subtitle: const Text('Detailed inclusion mapping'),
        //         value: _requireDiamondPlot,
        //         onChanged: (value) {
        //           setState(() {
        //             _requireDiamondPlot = value ?? false;
        //           });
        //         },
        //         controlAffinity: ListTileControlAffinity.leading,
        //         contentPadding: EdgeInsets.zero,
        //       ),
        //       const Divider(),
        //       CheckboxListTile(
        //         title: const Text('Require Proportions Diagram'),
        //         subtitle: const Text('Detailed measurements and angles'),
        //         value: _requireProportionsDiagram,
        //         onChanged: (value) {
        //           setState(() {
        //             _requireProportionsDiagram = value ?? false;
        //           });
        //         },
        //         controlAffinity: ListTileControlAffinity.leading,
        //         contentPadding: EdgeInsets.zero,
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Budget
        Text(
          'Budget Range (USD)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          decoration: InputDecoration(
            hintText: 'e.g., \$5,000 - \$10,000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.attach_money),
          ),
        ),
        const SizedBox(height: 24),

        // Timeframe
        Text(
          'Timeframe',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          items: [
            'Urgent (1-2 weeks)',
            'Soon (2-4 weeks)',
            'Flexible (1-3 months)',
            'No rush (3+ months)'
          ]
              .map((timeframe) => DropdownMenuItem(
                    value: timeframe,
                    child: Text(timeframe),
                  ))
              .toList(),
          onChanged: (value) {
            _timeframeController.text = value ?? '';
          },
          hint: const Text('Select timeframe'),
        ),
        const SizedBox(height: 24),

        // Notes
        Text(
          'Additional Notes',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Any specific requirements or preferences...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSummarySection(ThemeData theme, bool isSmallScreen) {
    // Only show summary if we have at least the basic info
    if (!_isFormValid) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete the required fields to see your demand summary',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visual summary with icons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Diamond Request',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (_selectedShape != null)
                    _buildSummaryCard(
                      icon: shapeDetails[_selectedShape]!['icon'] as IconData,
                      label: 'Shape',
                      value: _selectedShape!,
                      theme: theme,
                    ),
                  if (_caratFromController.text.isNotEmpty &&
                      _caratToController.text.isNotEmpty)
                    _buildSummaryCard(
                      icon: Icons.scale,
                      label: 'Carat',
                      value:
                          '${_caratFromController.text} - ${_caratToController.text}',
                      theme: theme,
                    ),
                  if (_colorFromController.text.isNotEmpty &&
                      _colorToController.text.isNotEmpty)
                    _buildSummaryCard(
                      icon: Icons.color_lens_outlined,
                      label: 'Color',
                      value:
                          '${_colorFromController.text} - ${_colorToController.text}',
                      theme: theme,
                    ),
                  if (_clarityFromController.text.isNotEmpty &&
                      _clarityToController.text.isNotEmpty)
                    _buildSummaryCard(
                      icon: Icons.visibility_outlined,
                      label: 'Clarity',
                      value:
                          '${_clarityFromController.text} - ${_clarityToController.text}',
                      theme: theme,
                    ),
                  if (_cutController.text.isNotEmpty)
                    _buildSummaryCard(
                      icon: Icons.diamond_outlined,
                      label: 'Cut',
                      value: _cutController.text,
                      theme: theme,
                    ),
                  if (_labController.text.isNotEmpty)
                    _buildSummaryCard(
                      icon: Icons.science_outlined,
                      label: 'Lab',
                      value: _labController.text,
                      theme: theme,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Detailed summary table
        Text(
          'Detailed Specifications',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          border: TableBorder.all(
            color: Colors.grey.shade200,
            width: 1,
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            if (_selectedShape != null)
              _buildTableRow('Shape', _selectedShape!, theme),
            if (_caratFromController.text.isNotEmpty &&
                _caratToController.text.isNotEmpty)
              _buildTableRow(
                  'Carat',
                  '${_caratFromController.text} - ${_caratToController.text}',
                  theme),
            if (_colorFromController.text.isNotEmpty &&
                _colorToController.text.isNotEmpty)
              _buildTableRow(
                  'Color',
                  '${_colorFromController.text} - ${_colorToController.text}',
                  theme),
            if (_clarityFromController.text.isNotEmpty &&
                _clarityToController.text.isNotEmpty)
              _buildTableRow(
                  'Clarity',
                  '${_clarityFromController.text} - ${_clarityToController.text}',
                  theme),
            if (_cutController.text.isNotEmpty)
              _buildTableRow('Cut', _cutController.text, theme),
            if (_polishController.text.isNotEmpty)
              _buildTableRow('Polish', _polishController.text, theme),
            if (_symmetryController.text.isNotEmpty)
              _buildTableRow('Symmetry', _symmetryController.text, theme),
            if (_fluorescenceController.text.isNotEmpty)
              _buildTableRow(
                  'Fluorescence', _fluorescenceController.text, theme),
            if (_labController.text.isNotEmpty)
              _buildTableRow('Lab', _labController.text, theme),
            if (_budgetController.text.isNotEmpty)
              _buildTableRow('Budget', _budgetController.text, theme),
            if (_timeframeController.text.isNotEmpty)
              _buildTableRow('Timeframe', _timeframeController.text, theme),
            if (_requireLaserInscription ||
                _requireDiamondPlot ||
                _requireProportionsDiagram)
              _buildTableRow(
                  'Special Requirements',
                  [
                    if (_requireLaserInscription) 'Laser Inscription',
                    if (_requireDiamondPlot) 'Diamond Plot',
                    if (_requireProportionsDiagram) 'Proportions Diagram',
                  ].join(', '),
                  theme),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, ThemeData theme) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(value),
        ),
      ],
    );
  }
}
