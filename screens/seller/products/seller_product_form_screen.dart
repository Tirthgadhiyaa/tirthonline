import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_event.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:jewellery_diamond/widgets/drag_drop_upload.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:html' as html;
import 'dart:typed_data';

class SellerProductFormScreen extends StatefulWidget {
  final DiamondProduct? product;

  const SellerProductFormScreen({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<UploadMultimageState> _uploadKey =
      GlobalKey<UploadMultimageState>();
  final GlobalKey<UploadSectionState> _uploadKeyVideo =
      GlobalKey<UploadSectionState>();
  final GlobalKey<UploadSectionState> _uploadKeyCerti =
      GlobalKey<UploadSectionState>();

  final TextEditingController _stockNumberController = TextEditingController();
  final TextEditingController _caratController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _certificateLabController =
      TextEditingController();
  final TextEditingController _certificateNumberController =
      TextEditingController();
  final TextEditingController _rapaController = TextEditingController();
  final TextEditingController _fancyColorController = TextEditingController();
  final TextEditingController _fancyColorIntensityController =
      TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _crownHeightController = TextEditingController();
  final TextEditingController _crownAngleController = TextEditingController();
  final TextEditingController _pavilionAngleController =
      TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _pavilionDepthController =
      TextEditingController();
  final TextEditingController _girdlePercentageController =
      TextEditingController();
  final TextEditingController _tablePercentageController =
      TextEditingController();
  final TextEditingController _ratioController = TextEditingController();
  final TextEditingController _eyeCleanController = TextEditingController();
  final TextEditingController _shadeController = TextEditingController();
  final TextEditingController _transparencyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _color;
  String? _cut;
  String? _clarity;
  String? _polish;
  String? _symmetry;
  String? _fluorescence;
  String? _girdle;
  String? _culet;
  String? _treatment;
  String? _status;
  Map<String, bool> _selectedShapes = {};
  List<String> _shapes = [
    "Round",
    "Princess",
    "Cushion",
    "Oval",
    "Emerald",
    "Pear",
    "Marquise",
    "Radiant",
    "Heart",
    "Asscher"
  ];

  List<Uint8List> _selectedImages = [];
  List<String> _imageNames = [];
  List<Uint8List> _selectedVideos = [];
  List<String> _videoNames = [];
  List<Uint8List> _selectedCertificates = [];
  List<String> _certificateNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      print("object");
      _initializeFormWithProduct(widget.product!);
    }
  }

  void _initializeFormWithProduct(DiamondProduct product) {
    _stockNumberController.text = product.stockNumber;
    _caratController.text = product.carat?.toString() ?? '';
    _priceController.text = product.price?.toString() ?? '';
    _discountController.text = product.discount?.toString() ?? '';
    _locationController.text = product.location ?? '';
    _certificateLabController.text = product.certificateLab ?? '';
    _certificateNumberController.text = product.certificateNumber ?? '';
    _rapaController.text = product.rapa ?? '';
    _fancyColorController.text = product.fancyColor ?? '';
    _fancyColorIntensityController.text = product.fancyColorIntensity ?? '';
    _lengthController.text = product.length?.toString() ?? '';
    _widthController.text = product.width?.toString() ?? '';
    _heightController.text = product.height?.toString() ?? '';
    _crownHeightController.text = product.crownHeight?.toString() ?? '';
    _crownAngleController.text = product.crownAngle?.toString() ?? '';
    _pavilionAngleController.text = product.pavilionAngle?.toString() ?? '';
    _depthController.text = product.depth?.toString() ?? '';
    _pavilionDepthController.text = product.pavilionDepth?.toString() ?? '';
    _girdlePercentageController.text =
        product.girdlePercentage?.toString() ?? '';
    _tablePercentageController.text = product.tablePercentage?.toString() ?? '';
    _ratioController.text = product.ratio?.toString() ?? '';
    _eyeCleanController.text = product.eyeClean ?? '';
    _shadeController.text = product.shade ?? '';
    _transparencyController.text = product.transparency ?? '';
    _descriptionController.text = product.description ?? '';

    _color = product.color;
    _cut = product.cut;
    _clarity = product.clarity;
    _polish = product.polish;
    _symmetry = product.symmetry;
    _fluorescence = product.fluorescence;
    _girdle = product.girdle;
    _culet = product.culet;
    _treatment = product.treatment;
    _status = product.status ?? 'Active';

    // Initialize selected shapes
    for (var shape in _shapes) {
      _selectedShapes[shape] = product.shape?.contains(shape) ?? false;
    }
  }

  @override
  void dispose() {
    _stockNumberController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _locationController.dispose();
    _certificateLabController.dispose();
    _certificateNumberController.dispose();
    _rapaController.dispose();
    _fancyColorController.dispose();
    _fancyColorIntensityController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _crownHeightController.dispose();
    _crownAngleController.dispose();
    _pavilionAngleController.dispose();
    _depthController.dispose();
    _pavilionDepthController.dispose();
    _girdlePercentageController.dispose();
    _tablePercentageController.dispose();
    _ratioController.dispose();
    _eyeCleanController.dispose();
    _shadeController.dispose();
    _transparencyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final shape = _selectedShapes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final productData = {
        'stock_number': _stockNumberController.text.trim(),
        'carat': _caratController.text.isNotEmpty
            ? double.tryParse(_caratController.text)
            : null,
        'price': _priceController.text.isNotEmpty
            ? double.tryParse(_priceController.text)
            : null,
        'discount': _discountController.text.isNotEmpty
            ? double.tryParse(_discountController.text)
            : null,
        'location': _locationController.text.trim(),
        'certificate_lab': _certificateLabController.text.trim(),
        'certificate_number': _certificateNumberController.text.trim(),
        'rapa': _rapaController.text.trim(),
        'fancy_color': _fancyColorController.text.trim(),
        'fancy_color_intensity': _fancyColorIntensityController.text.trim(),
        'length': _lengthController.text.isNotEmpty
            ? double.tryParse(_lengthController.text)
            : null,
        'width': _widthController.text.isNotEmpty
            ? double.tryParse(_widthController.text)
            : null,
        'height': _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
        'crown_height': _crownHeightController.text.isNotEmpty
            ? double.tryParse(_crownHeightController.text)
            : null,
        'crown_angle': _crownAngleController.text.isNotEmpty
            ? double.tryParse(_crownAngleController.text)
            : null,
        'pavilion_angle': _pavilionAngleController.text.isNotEmpty
            ? double.tryParse(_pavilionAngleController.text)
            : null,
        'depth': _depthController.text.isNotEmpty
            ? double.tryParse(_depthController.text)
            : null,
        'pavilion_depth': _pavilionDepthController.text.isNotEmpty
            ? double.tryParse(_pavilionDepthController.text)
            : null,
        'girdle_percentage': _girdlePercentageController.text.isNotEmpty
            ? double.tryParse(_girdlePercentageController.text)
            : null,
        'table_percentage': _tablePercentageController.text.isNotEmpty
            ? double.tryParse(_tablePercentageController.text)
            : null,
        'ratio': _ratioController.text.isNotEmpty
            ? double.tryParse(_ratioController.text)
            : null,
        'eye_clean': _eyeCleanController.text.trim(),
        'shade': _shadeController.text.trim(),
        'transparency': _transparencyController.text.trim(),
        'description': _descriptionController.text.trim(),
        'color': _color,
        'cut': _cut,
        'clarity': _clarity,
        'polish': _polish,
        'symmetry': _symmetry,
        'fluorescence': _fluorescence,
        'girdle': _girdle,
        'culet': _culet,
        'treatment': _treatment,
        'status': _status,
        'shape': shape,
      };

      if (widget.product != null) {
        // Update existing product
        context.read<SellerProductBloc>().add(
              EditSellerProduct(
                productId: widget.product!.id!,
                updatedData: productData,
              ),
            );
      } else {
        // Create new product
        context.read<SellerProductBloc>().add(
              CreateSellerProduct(
                productData: productData,
                images: _selectedImages,
                videos: _selectedVideos,
                certificates: _selectedCertificates,
              ),
            );
      }
    }
  }

  Widget buildTextField(
    String label, {
    required TextEditingController controller,
    bool isNumber = false,
    IconData? prefixIcon,
    String? suffixText,
    int maxLines = 1,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
            : [],
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 20)
              : null,
          suffixText: suffixText,
          suffixStyle: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label, {
    List<String>? items,
    String? value,
    ValueChanged<String?>? onChanged,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade600, size: 20)
              : null,
        ),
        items: (items ?? []).map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged ?? (value) {},
        icon:
            Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
        dropdownColor: Colors.white,
        isExpanded: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product != null ? 'Edit Product' : 'Add New Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Stock Number",
                          controller: _stockNumberController,
                          prefixIcon: Icons.inventory,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Carat",
                          isNumber: true,
                          controller: _caratController,
                          prefixIcon: FontAwesomeIcons.weightHanging,
                          suffixText: "ct",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Price",
                          isNumber: true,
                          controller: _priceController,
                          prefixIcon: Icons.attach_money,
                          suffixText: "USD",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Discount",
                          isNumber: true,
                          controller: _discountController,
                          prefixIcon: Icons.discount,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Location",
                          controller: _locationController,
                          prefixIcon: Icons.location_on,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Certificate Lab",
                          controller: _certificateLabController,
                          prefixIcon: Icons.verified,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Certificate Number",
                          controller: _certificateNumberController,
                          prefixIcon: Icons.numbers,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "RAPA",
                          controller: _rapaController,
                          prefixIcon: Icons.percent,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Fancy Color",
                          controller: _fancyColorController,
                          prefixIcon: Icons.color_lens,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Fancy Color Intensity",
                          controller: _fancyColorIntensityController,
                          prefixIcon: Icons.opacity,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Diamond Specifications Section
              const Text(
                'Diamond Specifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Color",
                          items: [
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
                          ],
                          value: _color,
                          prefixIcon: Icons.color_lens,
                          onChanged: (val) => setState(() => _color = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Cut",
                          items: [
                            'Excellent',
                            'Very Good',
                            'Good',
                            'Fair',
                            'Poor'
                          ],
                          value: _cut,
                          prefixIcon: Icons.cut,
                          onChanged: (val) => setState(() => _cut = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Clarity",
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
                          ],
                          value: _clarity,
                          prefixIcon: Icons.visibility,
                          onChanged: (val) => setState(() => _clarity = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Polish",
                          items: [
                            'Excellent',
                            'Very Good',
                            'Good',
                            'Fair',
                            'Poor'
                          ],
                          value: _polish,
                          prefixIcon: Icons.auto_awesome,
                          onChanged: (val) => setState(() => _polish = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Symmetry",
                          items: [
                            'Excellent',
                            'Very Good',
                            'Good',
                            'Fair',
                            'Poor'
                          ],
                          value: _symmetry,
                          prefixIcon: Icons.balance,
                          onChanged: (val) => setState(() => _symmetry = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Fluorescence",
                          items: [
                            'None',
                            'Faint',
                            'Medium',
                            'Strong',
                            'Very Strong'
                          ],
                          value: _fluorescence,
                          prefixIcon: Icons.lightbulb,
                          onChanged: (val) =>
                              setState(() => _fluorescence = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Girdle",
                          items: [
                            'Extremely Thin',
                            'Very Thin',
                            'Thin',
                            'Medium',
                            'Slightly Thick',
                            'Thick',
                            'Very Thick',
                            'Extremely Thick'
                          ],
                          value: _girdle,
                          prefixIcon: Icons.border_style,
                          onChanged: (val) => setState(() => _girdle = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Culet",
                          items: [
                            'None',
                            'Very Small',
                            'Small',
                            'Medium',
                            'Slightly Large',
                            'Large',
                            'Very Large'
                          ],
                          value: _culet,
                          prefixIcon: Icons.circle,
                          onChanged: (val) => setState(() => _culet = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Treatment",
                          items: [
                            'None',
                            'Laser Drilling',
                            'Fracture Filling',
                            'HPHT',
                            'Irradiation'
                          ],
                          value: _treatment,
                          prefixIcon: Icons.science,
                          onChanged: (val) => setState(() => _treatment = val),
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildDropdown(
                          "Status",
                          items: ['Active', 'Hold', 'Sold', 'Inactive'],
                          value: _status,
                          prefixIcon: Icons.info,
                          onChanged: (val) => setState(() => _status = val),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Measurements Section
              const Text(
                'Measurements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Length",
                          isNumber: true,
                          controller: _lengthController,
                          prefixIcon: Icons.straighten,
                          suffixText: "mm",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Width",
                          isNumber: true,
                          controller: _widthController,
                          prefixIcon: Icons.swap_horiz,
                          suffixText: "mm",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Height",
                          isNumber: true,
                          controller: _heightController,
                          prefixIcon: Icons.height,
                          suffixText: "mm",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Crown Height",
                          isNumber: true,
                          controller: _crownHeightController,
                          prefixIcon: Icons.vertical_align_top,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Crown Angle",
                          isNumber: true,
                          controller: _crownAngleController,
                          prefixIcon: Icons.arrow_right,
                          suffixText: "°",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Pavilion Angle",
                          isNumber: true,
                          controller: _pavilionAngleController,
                          prefixIcon: Icons.arrow_left,
                          suffixText: "°",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Depth %",
                          isNumber: true,
                          controller: _depthController,
                          prefixIcon: Icons.vertical_align_center,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Pavilion Depth",
                          isNumber: true,
                          controller: _pavilionDepthController,
                          prefixIcon: Icons.arrow_downward,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Girdle %",
                          isNumber: true,
                          controller: _girdlePercentageController,
                          prefixIcon: Icons.border_style,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Table %",
                          isNumber: true,
                          controller: _tablePercentageController,
                          prefixIcon: Icons.table_chart,
                          suffixText: "%",
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Ratio",
                          isNumber: true,
                          controller: _ratioController,
                          prefixIcon: Icons.aspect_ratio,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Additional Information Section
              const Text(
                'Additional Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Eye Clean",
                          controller: _eyeCleanController,
                          prefixIcon: Icons.remove_red_eye,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Shade",
                          controller: _shadeController,
                          prefixIcon: Icons.gradient,
                        ),
                      ),
                      SizedBox(
                        width: isWideScreen
                            ? (constraints.maxWidth - 48) / 2
                            : constraints.maxWidth,
                        child: buildTextField(
                          "Transparency",
                          controller: _transparencyController,
                          prefixIcon: Icons.opacity,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: buildTextField(
                          "Description",
                          controller: _descriptionController,
                          maxLines: 3,
                          prefixIcon: Icons.description,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Media Upload Section
              const Text(
                'Media Upload',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              UploadSection(
                key: _uploadKey,
                title: 'Images',
                subtitle: 'Upload product images',
                icon: Icons.image,
                allowedExtensions: const ['jpg', 'jpeg', 'png'],
                onFilesSelected: (files) async {
                  List<Uint8List> imageBytesList = await Future.wait(
                    files.map((file) async {
                      final reader = html.FileReader();
                      reader.readAsArrayBuffer(file);
                      await reader.onLoad.first;
                      return reader.result as Uint8List;
                    }),
                  );
                  List<String> fileNames =
                      files.map((file) => file.name).toList();
                  setState(() {
                    _selectedImages = imageBytesList;
                    _imageNames = fileNames;
                  });
                },
              ),
              const SizedBox(height: 24),
              UploadSection(
                key: _uploadKeyVideo,
                title: '3D Model',
                subtitle: 'Upload 3D model files',
                icon: Icons.video_library,
                allowedExtensions: const ['glb', 'gltf', 'obj'],
                onFilesSelected: (files) async {
                  List<Uint8List> videoBytesList = await Future.wait(
                    files.map((file) async {
                      final reader = html.FileReader();
                      reader.readAsArrayBuffer(file);
                      await reader.onLoad.first;
                      return reader.result as Uint8List;
                    }),
                  );
                  List<String> fileNames =
                      files.map((file) => file.name).toList();
                  setState(() {
                    _selectedVideos = videoBytesList;
                    _videoNames = fileNames;
                  });
                },
              ),
              const SizedBox(height: 24),
              UploadSection(
                key: _uploadKeyCerti,
                title: 'Certificates',
                subtitle: 'Upload certification documents',
                icon: Icons.description,
                allowedExtensions: const [
                  'pdf',
                  'doc',
                  'docx',
                  'jpg',
                  'jpeg',
                  'png'
                ],
                onFilesSelected: (files) async {
                  List<Uint8List> certBytesList = await Future.wait(
                    files.map((file) async {
                      final reader = html.FileReader();
                      reader.readAsArrayBuffer(file);
                      await reader.onLoad.first;
                      return reader.result as Uint8List;
                    }),
                  );
                  List<String> fileNames =
                      files.map((file) => file.name).toList();
                  setState(() {
                    _selectedCertificates = certBytesList;
                    _certificateNames = fileNames;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  CustButton(
                    onPressed: _submitForm,
                    child: Text(
                      widget.product != null
                          ? 'Update Product'
                          : 'Create Product',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
