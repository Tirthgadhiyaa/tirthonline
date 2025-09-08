// lib/screens/admin/addproduct/add_product.dart
import 'dart:html' as html;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_event.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_state.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/widgets/drag_drop_upload.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constant/admin_routes.dart';

class ProductFormScreen extends StatefulWidget {
  static const String routeName = '/productform';
  final DiamondProduct? editproduct;

  const ProductFormScreen({Key? key, this.editproduct}) : super(key: key);
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final GlobalKey<UploadMultimageState> _uploadKey =
      GlobalKey<UploadMultimageState>();
  final GlobalKey<UploadSectionState> _uploadKeyvideo =
      GlobalKey<UploadSectionState>();
  final GlobalKey<UploadSectionState> _uploadKeycerti =
      GlobalKey<UploadSectionState>();

  bool jewelley = false;
  bool isUploading = false;
  final List<String> shapes = [
    "Round",
    "Princess",
    "Cushion",
    "Oval",
    "Emerald",
    "Pear",
    "Marquise",
    "Radiant"
  ];

  bool isHovered = false;
  final TextEditingController stockNumberController = TextEditingController();
  final TextEditingController caratController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController certificateLabController =
      TextEditingController();
  final TextEditingController rapaController = TextEditingController();
  final TextEditingController certificateNumberController =
      TextEditingController();
  final TextEditingController fancyColorController = TextEditingController();
  final TextEditingController fancyColorIntensityController =
      TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController crownHeightController = TextEditingController();
  final TextEditingController crownAngleController = TextEditingController();
  final TextEditingController pavilionAngleController = TextEditingController();
  final TextEditingController depthController = TextEditingController();
  final TextEditingController pavilionDepthController = TextEditingController();
  final TextEditingController girdlePercentageController =
      TextEditingController();
  final TextEditingController tablePercentageController =
      TextEditingController();
  final TextEditingController ratioController = TextEditingController();
  final TextEditingController eyeCleanController = TextEditingController();
  final TextEditingController shadeController = TextEditingController();
  final TextEditingController transparencyController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? color,
      cut,
      clarity,
      polish,
      symmetry,
      fluorescence,
      girdle,
      culet,
      treatment,
      status;
  Map<String, bool> selectedShapes = {};
  List<html.File> selectedFiles = [];
  List<Uint8List> selectedImages = [];
  List<String>? imagefileNames = [];
  List<Uint8List> selectedCertificates = [];
  List<String>? certificateNames = [];
  List<Uint8List> selected3dModel = [];
  List<String>? videofileNames = [];
  List<String>? deleteImages = [];
  List<String>? deletedCertificates = [];
  List<String>? deletedVideos = [];

  html.File? selectedFile;
  Uint8List? selectedFileBytes;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values (for edit) or empty values (for create)
    stockNumberController.text = widget.editproduct?.stockNumber ?? '';
    caratController.text = widget.editproduct?.carat?.toString() ?? '';
    priceController.text = widget.editproduct?.price?.toString() ?? '';
    discountController.text = widget.editproduct?.discount?.toString() ?? '';
    locationController.text = widget.editproduct?.location ?? '';
    certificateLabController.text = widget.editproduct?.certificateLab ?? '';
    rapaController.text = widget.editproduct?.rapa ?? '';
    certificateNumberController.text =
        widget.editproduct?.certificateNumber ?? '';
    fancyColorController.text = widget.editproduct?.fancyColor ?? '';
    fancyColorIntensityController.text =
        widget.editproduct?.fancyColorIntensity ?? '';
    lengthController.text = widget.editproduct?.length?.toString() ?? '';
    widthController.text = widget.editproduct?.width?.toString() ?? '';
    heightController.text = widget.editproduct?.height?.toString() ?? '';
    crownHeightController.text =
        widget.editproduct?.crownHeight?.toString() ?? '';
    crownAngleController.text =
        widget.editproduct?.crownAngle?.toString() ?? '';
    pavilionAngleController.text =
        widget.editproduct?.pavilionAngle?.toString() ?? '';
    depthController.text = widget.editproduct?.depth?.toString() ?? '';
    pavilionDepthController.text =
        widget.editproduct?.pavilionDepth?.toString() ?? '';
    girdlePercentageController.text =
        widget.editproduct?.girdlePercentage?.toString() ?? '';
    tablePercentageController.text =
        widget.editproduct?.tablePercentage?.toString() ?? '';
    ratioController.text = widget.editproduct?.ratio?.toString() ?? '';
    eyeCleanController.text = widget.editproduct?.eyeClean ?? '';
    shadeController.text = widget.editproduct?.shade ?? '';
    transparencyController.text = widget.editproduct?.transparency ?? '';
    descriptionController.text = widget.editproduct?.description ?? '';

    if (widget.editproduct?.certificate_url != null) {
      certificateNames = widget.editproduct?.certificate_url;
    }
    if (widget.editproduct?.video_url != null) {
      videofileNames = widget.editproduct?.video_url;
    }
    if (widget.editproduct?.images != null) {
      imagefileNames = widget.editproduct?.images;
    }

    // Initialize dropdown values
    color = widget.editproduct?.color;
    cut = widget.editproduct?.cut;
    clarity = widget.editproduct?.clarity;
    polish = widget.editproduct?.polish;
    symmetry = widget.editproduct?.symmetry;
    fluorescence = widget.editproduct?.fluorescence??"None";
    girdle = widget.editproduct?.girdle;
    culet = widget.editproduct?.culet??"None";
    treatment = widget.editproduct?.treatment??"None";
    status = widget.editproduct?.status ?? "Active";

    // Initialize selected shapes
    for (var shape in shapes) {
      selectedShapes[shape] =
          widget.editproduct?.shape?.contains(shape) ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and title
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.editproduct != null
                              ? 'Edit Product'
                              : 'Add New Product',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.editproduct != null
                              ? 'Update diamond product details'
                              : 'Create a new diamond product listing',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Status indicator for edit mode
                    if (widget.editproduct != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == "Active"
                              ? Colors.green.shade50
                              : status == "Hold"
                                  ? Colors.orange.shade50
                                  : status == "Sold"
                                      ? Colors.blue.shade50
                                      : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: status == "Active"
                                ? Colors.green
                                : status == "Hold"
                                    ? Colors.orange
                                    : status == "Sold"
                                        ? Colors.blue
                                        : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status ?? "Active",
                          style: TextStyle(
                            color: status == "Active"
                                ? Colors.green
                                : status == "Hold"
                                    ? Colors.orange
                                    : status == "Sold"
                                        ? Colors.blue
                                        : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                // Custom horizontal stepper
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        _buildStepIndicator(0, "Basic Info", _currentStep >= 0),
                        _buildStepConnector(_currentStep > 0),
                        _buildStepIndicator(
                            1, "Diamond Specs", _currentStep >= 1),
                        _buildStepConnector(_currentStep > 1),
                        _buildStepIndicator(
                            2, "Extra Specs", _currentStep >= 2),
                        _buildStepConnector(_currentStep > 2),
                        _buildStepIndicator(3, "Media", _currentStep >= 3),
                      ],
                    ),
                  ),
                ),

                // Step content with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                    ),
                  )
                else
                  const SizedBox(width: 100),
                BlocListener<DiamondBloc, DiamondState>(
                  listener: (context, state) {
                    if (state is DiamondLoading) {
                      setState(() {
                        isUploading = true;
                      });
                    } else {
                      setState(() {
                        isUploading = false;
                      });

                      if (state is DiamondSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: Colors.white,
                              onPressed: () {},
                            ),
                          ),
                        );
                        // Reset all fields after successful submission
                        setState(() {
                          stockNumberController.clear();
                          caratController.clear();
                          priceController.clear();
                          discountController.clear();
                          locationController.clear();
                          certificateLabController.clear();
                          certificateNumberController.clear();
                          rapaController.clear();
                          lengthController.clear();
                          widthController.clear();
                          heightController.clear();
                          crownHeightController.clear();
                          crownAngleController.clear();
                          pavilionAngleController.clear();
                          depthController.clear();
                          pavilionDepthController.clear();
                          girdlePercentageController.clear();
                          tablePercentageController.clear();
                          ratioController.clear();
                          eyeCleanController.clear();
                          shadeController.clear();
                          transparencyController.clear();
                          descriptionController.clear();
                          cut = null;
                          clarity = null;
                          color = null;
                          polish = null;
                          symmetry = null;
                          fluorescence = null;
                          girdle = null;
                          culet = null;
                          treatment = null;
                          fancyColorController.clear();
                          fancyColorIntensityController.clear();
                          selectedShapes.updateAll((key, value) => false);
                          selectedImages = [];
                          imagefileNames = [];
                          selectedCertificates = [];
                          certificateNames = [];
                          selected3dModel = [];
                          videofileNames = [];
                          deleteImages = [];
                          deletedCertificates = [];
                          deletedVideos = [];
                          _uploadKey.currentState?.clearAll();
                          _uploadKeyvideo.currentState?.clearAll();
                          _uploadKeycerti.currentState?.clearAll();
                          status = "Active";
                          _currentStep = 0;
                        });
                        if (widget.editproduct != null) {
                          GoRouter.of(context).go(AppRoutes.adminListing);
                        }
                      } else if (state is DiamondFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 180,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () {
                              if (_currentStep < 3) {
                                setState(() {
                                  _currentStep++;
                                });
                              } else {
                                final shape = selectedShapes.entries
                                    .where((entry) => entry.value)
                                    .map((entry) => entry.key)
                                    .toList();
                                final diamondProduct = DiamondProduct(
                                  stockNumber:
                                      stockNumberController.text.trim(),
                                  carat: caratController.text.isNotEmpty
                                      ? double.tryParse(caratController.text)
                                      : null,
                                  price: priceController.text.isNotEmpty
                                      ? double.tryParse(priceController.text)
                                      : null,
                                  discount: discountController.text.isNotEmpty
                                      ? double.tryParse(discountController.text)
                                      : null,
                                  location:
                                      locationController.text.trim().isNotEmpty
                                          ? locationController.text.trim()
                                          : null,
                                  certificateLab: certificateLabController.text
                                          .trim()
                                          .isNotEmpty
                                      ? certificateLabController.text.trim()
                                      : null,
                                  certificateNumber: certificateNumberController
                                          .text
                                          .trim()
                                          .isNotEmpty
                                      ? certificateNumberController.text.trim()
                                      : null,
                                  rapa: rapaController.text.trim().isNotEmpty
                                      ? rapaController.text.trim()
                                      : null,
                                  cut: cut,
                                  clarity: clarity,
                                  color: color,
                                  status: status ?? "Active",
                                  shape: shape.isNotEmpty ? shape : null,
                                  fancyColor: fancyColorController.text
                                          .trim()
                                          .isNotEmpty
                                      ? fancyColorController.text.trim()
                                      : null,
                                  fancyColorIntensity:
                                      fancyColorIntensityController
                                              .text
                                              .trim()
                                              .isNotEmpty
                                          ? fancyColorIntensityController.text
                                              .trim()
                                          : null,
                                  polish: polish,
                                  symmetry: symmetry,
                                  fluorescence: fluorescence,
                                  girdle: girdle,
                                  culet: culet,
                                  treatment: treatment,
                                  length: lengthController.text.isNotEmpty
                                      ? double.tryParse(lengthController.text)
                                      : null,
                                  width: widthController.text.isNotEmpty
                                      ? double.tryParse(widthController.text)
                                      : null,
                                  height: heightController.text.isNotEmpty
                                      ? double.tryParse(heightController.text)
                                      : null,
                                  crownHeight:
                                      crownHeightController.text.isNotEmpty
                                          ? double.tryParse(
                                              crownHeightController.text)
                                          : null,
                                  crownAngle:
                                      crownAngleController.text.isNotEmpty
                                          ? double.tryParse(
                                              crownAngleController.text)
                                          : null,
                                  pavilionAngle:
                                      pavilionAngleController.text.isNotEmpty
                                          ? double.tryParse(
                                              pavilionAngleController.text)
                                          : null,
                                  depth: depthController.text.isNotEmpty
                                      ? double.tryParse(depthController.text)
                                      : null,
                                  pavilionDepth:
                                      pavilionDepthController.text.isNotEmpty
                                          ? double.tryParse(
                                              pavilionDepthController.text)
                                          : null,
                                  girdlePercentage:
                                      girdlePercentageController.text.isNotEmpty
                                          ? double.tryParse(
                                              girdlePercentageController.text)
                                          : null,
                                  tablePercentage:
                                      tablePercentageController.text.isNotEmpty
                                          ? double.tryParse(
                                              tablePercentageController.text)
                                          : null,
                                  ratio: ratioController.text.isNotEmpty
                                      ? double.tryParse(ratioController.text)
                                      : null,
                                  eyeClean:
                                      eyeCleanController.text.trim().isNotEmpty
                                          ? eyeCleanController.text.trim()
                                          : null,
                                  shade: shadeController.text.trim().isNotEmpty
                                      ? shadeController.text.trim()
                                      : null,
                                  transparency: transparencyController.text
                                          .trim()
                                          .isNotEmpty
                                      ? transparencyController.text.trim()
                                      : null,
                                  description: descriptionController.text
                                          .trim()
                                          .isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                                  deletedImages:
                                      deleteImages?.isNotEmpty == true
                                          ? deleteImages
                                          : null,
                                  deletedCertificates:
                                      deletedCertificates?.isNotEmpty == true
                                          ? deletedCertificates
                                          : null,
                                  deletedVideos:
                                      deletedVideos?.isNotEmpty == true
                                          ? deletedVideos
                                          : null,
                                );
                                if (!isUploading) {
                                  if (widget.editproduct != null) {
                                    context
                                        .read<DiamondBloc>()
                                        .add(EditDiamondProduct(
                                          productId: widget.editproduct!.id!,
                                          updatedDiamondProduct: diamondProduct,
                                          updatedImages: selectedImages,
                                          updatedImageNames: imagefileNames,
                                          updatedCertificate:
                                              selectedCertificates,
                                          updatedCertificateNames:
                                              certificateNames,
                                          updatedModelVideo: selected3dModel,
                                          updatedVideoNames: videofileNames,
                                        ));
                                  } else {
                                    context
                                        .read<DiamondBloc>()
                                        .add(AddDiamondProduct(
                                          diamondProduct: diamondProduct,
                                          images: selectedImages,
                                          imageNames: imagefileNames,
                                          certificate: selectedCertificates,
                                          certificateNames: certificateNames,
                                          modelVideo: selected3dModel,
                                          videoNames: videofileNames,
                                        ));
                                  }
                                }
                              }
                            },
                      icon: isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(_currentStep == 3
                              ? Icons.check
                              : Icons.arrow_forward),
                      label: Text(
                        _currentStep == 3
                            ? (widget.editproduct != null ? 'Update' : 'Submit')
                            : 'Next',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final isCurrentStep = _currentStep == step;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (step <= _currentStep || step == _currentStep + 1) {
            setState(() {
              _currentStep = step;
            });
          }
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCurrentStep
                    ? colorScheme.primary
                    : (isActive
                        ? colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.shade100),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentStep
                      ? colorScheme.primary
                      : (isActive ? colorScheme.primary : Colors.grey.shade300),
                  width: 2,
                ),
                boxShadow: isCurrentStep
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: isActive
                    ? Icon(
                        Icons.check,
                        color:
                            isCurrentStep ? Colors.white : colorScheme.primary,
                        size: 24,
                      )
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          color: isCurrentStep
                              ? Colors.white
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isCurrentStep
                    ? colorScheme.primary
                    : (isActive ? colorScheme.primary : Colors.grey.shade600),
                fontWeight: isCurrentStep ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.5),
                ],
              )
            : null,
        color: isActive ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.gem,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Enter the fundamental details of the diamond',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
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
                            controller: stockNumberController,
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
                            controller: caratController,
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
                            controller: priceController,
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
                            controller: discountController,
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
                            controller: locationController,
                            prefixIcon: Icons.location_on,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      case 1:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.certificate,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Diamond Specifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Enter the key specifications and certifications',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
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
                            "Certificate Lab",
                            controller: certificateLabController,
                            prefixIcon: Icons.verified,
                            hintText: "GIA, IGI, etc.",
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Certificate Number",
                            controller: certificateNumberController,
                            prefixIcon: Icons.numbers,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Rapa",
                            controller: rapaController,
                            prefixIcon: Icons.assessment,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Cut",
                            items: [
                              "Poor",
                              "Fair",
                              "Good",
                              "Very Good",
                              "Excellent",
                              "Ideal",
                              "Super Ideal"
                            ],
                            value: cut,
                            prefixIcon: FontAwesomeIcons.cut,
                            onChanged: (val) => setState(() => cut = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Clarity",
                            items: [
                              "FL",
                              "IF",
                              "VVS1",
                              "VVS2",
                              "VS1",
                              "VS2",
                              "SI1",
                              "SI2",
                              "I1",
                              "I2",
                              "I3"
                            ],
                            value: clarity,
                            prefixIcon: Icons.visibility,
                            onChanged: (val) => setState(() => clarity = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Color",
                            items: [
                              "D",
                              "E",
                              "F",
                              "G",
                              "H",
                              "I",
                              "J",
                              "K",
                              "L",
                              "M",
                              "N-Z"
                            ],
                            value: color,
                            prefixIcon: Icons.color_lens,
                            onChanged: (val) => setState(() => color = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Status",
                            items: ["Active", "Hold", "Sold", "InActive","held"],
                            value: status,
                            prefixIcon: Icons.info_outline,
                            onChanged: (val) => setState(() => status = val),
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: buildShape(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      case 2:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.rulerCombined,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Extra Specifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Enter detailed measurements and additional properties',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
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
                            "Fancy Color",
                            controller: fancyColorController,
                            prefixIcon: Icons.palette,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Fancy Color Intensity",
                            controller: fancyColorIntensityController,
                            prefixIcon: Icons.brightness_medium,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Polish",
                            items: [
                              "Poor",
                              "Fair",
                              "Good",
                              "Very Good",
                              "Excellent"
                            ],
                            value: polish,
                            prefixIcon: Icons.auto_awesome,
                            onChanged: (val) => setState(() => polish = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Symmetry",
                            items: [
                              "Poor",
                              "Fair",
                              "Good",
                              "Very Good",
                              "Excellent"
                            ],
                            value: symmetry,
                            prefixIcon: Icons.balance,
                            onChanged: (val) => setState(() => symmetry = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Fluorescence",
                            items: [
                              "None",
                              "Faint",
                              "Medium",
                              "Strong",
                              "Very Strong"
                            ],
                            value: fluorescence,
                            prefixIcon: Icons.lightbulb_outline,
                            onChanged: (val) =>
                                setState(() => fluorescence = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Girdle",
                            items: [
                              "Medium (Faceted)",
                              "Extremely Thin",
                              "Very Thin",
                              "Thin",
                              "Medium",
                              "Slightly Thick",
                              "Thick",
                              "Very Thick",
                              "Extremely Thick"
                            ],
                            value: girdle,
                            prefixIcon: Icons.border_outer,
                            onChanged: (val) => setState(() => girdle = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Culet",
                            items: [
                              "None",
                              "Very Small",
                              "Small",
                              "Medium",
                              "Slightly Large",
                              "Large",
                              "Very Large",
                              "Extremely Large",
                              "Pointed"
                            ],
                            value: culet,
                            prefixIcon: Icons.arrow_drop_down_circle,
                            onChanged: (val) => setState(() => culet = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildDropdown(
                            "Treatment",
                            items: [
                              "None",
                              "Laser Drilled",
                              "Fracture Filled",
                              "HPHT",
                              "Irradiated",
                              "Coated",
                              "Annealed",
                              "Surface Enhanced"
                            ],
                            value: treatment,
                            prefixIcon: Icons.science,
                            onChanged: (val) => setState(() => treatment = val),
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Length",
                            isNumber: true,
                            controller: lengthController,
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
                            controller: widthController,
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
                            controller: heightController,
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
                            controller: crownHeightController,
                            prefixIcon: FontAwesomeIcons.crown,
                            suffixText: "mm",
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Crown Angle",
                            isNumber: true,
                            controller: crownAngleController,
                            prefixIcon: Icons.architecture,
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
                            controller: pavilionAngleController,
                            prefixIcon: Icons.show_chart,
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
                            controller: depthController,
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
                            controller: pavilionDepthController,
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
                            controller: girdlePercentageController,
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
                            controller: tablePercentageController,
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
                            controller: ratioController,
                            prefixIcon: Icons.aspect_ratio,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Eye Clean",
                            controller: eyeCleanController,
                            prefixIcon: Icons.remove_red_eye,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Shade",
                            controller: shadeController,
                            prefixIcon: Icons.gradient,
                          ),
                        ),
                        SizedBox(
                          width: isWideScreen
                              ? (constraints.maxWidth - 48) / 2
                              : constraints.maxWidth,
                          child: buildTextField(
                            "Transparency",
                            controller: transparencyController,
                            prefixIcon: Icons.opacity,
                          ),
                        ),
                        SizedBox(
                          width: constraints.maxWidth,
                          child: buildTextField(
                            "Description",
                            controller: descriptionController,
                            maxLines: 3,
                            prefixIcon: Icons.description,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      case 3:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.images,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Media Upload',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Upload images, videos, and certificates for the diamond',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),
                buildProductMedia(),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget buildShape() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.shapes,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              const Text(
                "Diamond Shape",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          custSpace15Y,
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: shapes.map((shape) {
              return FilterChip(
                label: Text(shape),
                selected: selectedShapes[shape] ?? false,
                onSelected: (bool value) {
                  setState(() {
                    selectedShapes[shape] = value;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                backgroundColor: Colors.white,
                selectedColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                checkmarkColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: selectedShapes[shape] ?? false
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                  fontWeight: selectedShapes[shape] ?? false
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 0,
                pressElevation: 2,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title.contains("Images")
                      ? Icons.image
                      : title.contains("3D")
                          ? Icons.view_in_ar
                          : Icons.description,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label, {
    int maxLines = 1,
    bool isNumber = false,
    required TextEditingController controller,
    IconData? prefixIcon,
    String? hintText,
    String? suffixText,
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

  Widget buildProductMedia() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 900;

        return Column(
          children: [
            // Media upload section header
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.fileUpload,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Media Files",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Upload high-quality images, videos, and certification documents",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Responsive grid layout for upload sections
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images - takes 50% width on wide screens
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: UploadMultimage(
                        key: _uploadKey,
                        title: "Product Images",
                        subtitle: "Drag and drop images here or",
                        icon: Icons.image,
                        initialUrls: imagefileNames,
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
                            selectedImages = imageBytesList;
                            imagefileNames = fileNames;
                          });
                        },
                        onExistingRemoved: (removedUrls) {
                          setState(() {
                            deleteImages = removedUrls;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right column for 3D models and certificates - takes 50% width
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // 3D Renderings & Videos
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: UploadSection(
                            key: _uploadKeyvideo,
                            title: "3D Renderings & Videos",
                            subtitle: "Upload 3D model files or videos",
                            icon: Icons.view_in_ar,
                            initialFiles: videofileNames,
                            allowedExtensions: const [
                              'glb',
                              'gltf',
                              'obj',
                              'fbx',
                              'mp4',
                              'mov',
                              'avi'
                            ],
                            onFilesSelected: (files) async {
                              List<Uint8List> modelBytesList =
                                  await Future.wait(
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
                                selected3dModel = modelBytesList;
                                videofileNames = fileNames;
                              });
                            },
                            onExistingRemoved: (removedUrls) {
                              setState(() {
                                deletedVideos = removedUrls;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Certificates
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: UploadSection(
                            key: _uploadKeycerti,
                            title: "Certificates",
                            subtitle: "Upload certification documents",
                            icon: Icons.description,
                            initialFiles: certificateNames,
                            allowedExtensions: const [
                              'pdf',
                              'doc',
                              'docx',
                              'jpg',
                              'jpeg',
                              'png'
                            ],
                            onFilesSelected: (files) async {
                              List<Uint8List> certificatesBytesList =
                                  await Future.wait(
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
                                selectedCertificates = certificatesBytesList;
                                certificateNames = fileNames;
                              });
                            },
                            onExistingRemoved: (removedUrls) {
                              setState(() {
                                deletedCertificates = removedUrls;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              // Stacked layout for mobile/tablet
              Column(
                children: [
                  // Product Images
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UploadMultimage(
                      key: _uploadKey,
                      title: "Product Images",
                      subtitle: "Drag and drop images here or",
                      icon: Icons.image,
                      initialUrls: imagefileNames,
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
                          selectedImages = imageBytesList;
                          imagefileNames = fileNames;
                        });
                      },
                      onExistingRemoved: (removedUrls) {
                        setState(() {
                          deleteImages = removedUrls;
                        });
                      },
                    ),
                  ),

                  // 3D Renderings & Videos
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UploadSection(
                      key: _uploadKeyvideo,
                      title: "3D Renderings & Videos",
                      subtitle: "Upload 3D model files or videos",
                      icon: Icons.view_in_ar,
                      initialFiles: videofileNames,
                      allowedExtensions: const [
                        'glb',
                        'gltf',
                        'obj',
                        'fbx',
                        'mp4',
                        'mov',
                        'avi'
                      ],
                      onFilesSelected: (files) async {
                        List<Uint8List> modelBytesList = await Future.wait(
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
                          selected3dModel = modelBytesList;
                          videofileNames = fileNames;
                        });
                      },
                      onExistingRemoved: (removedUrls) {
                        setState(() {
                          deletedVideos = removedUrls;
                        });
                      },
                    ),
                  ),

                  // Certificates
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UploadSection(
                      key: _uploadKeycerti,
                      title: "Certificates",
                      subtitle: "Upload certification documents",
                      icon: Icons.description,
                      initialFiles: certificateNames,
                      allowedExtensions: const [
                        'pdf',
                        'doc',
                        'docx',
                        'jpg',
                        'jpeg',
                        'png'
                      ],
                      onFilesSelected: (files) async {
                        List<Uint8List> certificatesBytesList =
                            await Future.wait(
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
                          selectedCertificates = certificatesBytesList;
                          certificateNames = fileNames;
                        });
                      },
                      onExistingRemoved: (removedUrls) {
                        setState(() {
                          deletedCertificates = removedUrls;
                        });
                      },
                    ),
                  ),
                ],
              ),

            // Warning message for edit mode
            if (widget.editproduct != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Any removed media will be permanently deleted when you save changes.",
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Upload tips
            Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upload Tips",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTipItem(
                          icon: Icons.image,
                          title: "Images",
                          description:
                              "Upload high-resolution images from multiple angles",
                        ),
                      ),
                      Expanded(
                        child: _buildTipItem(
                          icon: Icons.view_in_ar,
                          title: "3D Models",
                          description:
                              "Include 3D models for better visualization",
                        ),
                      ),
                      Expanded(
                        child: _buildTipItem(
                          icon: Icons.description,
                          title: "Certificates",
                          description:
                              "Add certification documents to verify authenticity",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
