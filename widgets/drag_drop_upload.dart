import 'dart:html' as html;
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';

class UploadSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function(List<html.File>)? onFilesSelected;
  final Function(List<String>)? onExistingRemoved;
  final List<String>? allowedExtensions;
  final List<String>? initialFiles;

  const UploadSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onFilesSelected,
    this.allowedExtensions,
    this.initialFiles,
    this.onExistingRemoved,
    Key? key,
  }) : super(key: key);

  @override
  UploadSectionState createState() => UploadSectionState();
}

class UploadSectionState extends State<UploadSection> {
  late DropzoneViewController dropController;
  bool isDragging = false;
  bool isUploading = false;
  List<String> uploadedFiles = [];
  List<String> existingFiles = [];
  List<String> removedExistingFiles = [];

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: widget.allowedExtensions != null ? FileType.custom : FileType.image,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null && widget.onFilesSelected != null) {
      setState(() {
        isUploading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      List<html.File> files = result.files.map((file) {
        return html.File([file.bytes!], file.name, {'type': file.extension});
      }).toList();
      widget.onFilesSelected!(files);

      setState(() {
        isUploading = false;
        uploadedFiles = files.map((file) => file.name).toList();
      });
    }
  }

  void clearAll() {
    setState(() {
      uploadedFiles.clear();
      removedExistingFiles.addAll(existingFiles);
      existingFiles.clear();
      widget.onFilesSelected?.call([]);
      widget.onExistingRemoved?.call(removedExistingFiles);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      existingFiles = List.from(widget.initialFiles!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> allFiles = [...existingFiles, ...uploadedFiles];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          custSpace10Y,
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDragging
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          width: isDragging ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isDragging
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Center(
                        child: isUploading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  custSpace8Y,
                                  const Text("Uploading...",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13)),
                                ],
                              )
                            : allFiles.isNotEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 32),
                                      const Text("Upload Complete",
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 13)),
                                      Text(
                                          allFiles
                                              .map((url) => Uri.parse(url)
                                                  .pathSegments
                                                  .last)
                                              .join(", "),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(widget.icon,
                                          color: Colors.grey, size: 32),
                                      Text(widget.subtitle,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13)),
                                    ],
                                  ),
                      ),
                    ),
                    Positioned.fill(
                      child: DropzoneView(
                        onCreated: (controller) => dropController = controller,
                        onDrop: (file) async {
                          setState(() {
                            isDragging = false;
                            isUploading = true;
                          });

                          await Future.delayed(const Duration(seconds: 2));

                          setState(() {
                            isUploading = false;
                            uploadedFiles = [file.name];
                          });

                          widget.onFilesSelected?.call([file]);
                        },
                        onHover: () {
                          setState(() {
                            isDragging = true;
                          });
                        },
                        onLeave: () {
                          setState(() {
                            isDragging = false;
                          });
                        },
                      ),
                    ),
                    if (allFiles.isNotEmpty)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              removedExistingFiles.addAll(existingFiles);
                              existingFiles.clear();
                              uploadedFiles.clear();
                            });
                            widget.onFilesSelected?.call([]);
                            widget.onExistingRemoved
                                ?.call(removedExistingFiles);
                          },
                        ),
                      ),
                    if (allFiles.isEmpty)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: TextButton(
                          onPressed: () {
                            _pickFiles();
                          },
                          style: ButtonStyle(
                            overlayColor: MaterialStateProperty.all(
                                Colors.transparent), // Disables hover effect
                          ),
                          child: const Text("Browse Files",
                              style: TextStyle(
                                color: Colors.blue,
                              )),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UploadMultimage extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function(List<html.File>)? onFilesSelected;
  final Function(List<String>)? onExistingRemoved;
  final List<String>? allowedExtensions;
  final List<String>? initialUrls;

  const UploadMultimage({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onFilesSelected,
    this.allowedExtensions,
    this.initialUrls,
    this.onExistingRemoved,
    Key? key,
  }) : super(key: key);

  @override
  UploadMultimageState createState() => UploadMultimageState();
}

class UploadMultimageState extends State<UploadMultimage> {
  late DropzoneViewController dropController;
  bool isDragging = false;
  List<html.File> uploadedFiles = [];
  List<String> uploadedUrls = [];
  List<String> existingUrls = [];
  List<String> removedExistingUrls = [];
  final String errorImageUrl =
      "https://laxmi-diamond.s3.ap-south-1.amazonaws.com/products/images/download+(2).png";

  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: widget.allowedExtensions != null ? FileType.custom : FileType.image,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );

    if (result != null) {
      List<html.File> newFiles = result.files
          .where((file) => file.bytes != null)
          .map((file) => html.File([file.bytes!], file.name))
          .toList();

      setState(() {
        for (var file in newFiles) {
          bool fileExists = uploadedFiles.any((f) => f.name == file.name);

          if (!fileExists) {
            uploadedFiles.add(file);
            uploadedUrls.add(html.Url.createObjectUrl(file));
          } else {
            print("File '${file.name}' is already added.");
          }
        }
      });

      widget.onFilesSelected?.call(uploadedFiles);
      print(
          "Selected files: ${uploadedFiles.map((file) => file.name).toList()}");
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        String removedUrl = existingUrls.removeAt(index);
        removedExistingUrls.add(removedUrl);
        widget.onExistingRemoved?.call(removedExistingUrls);
      } else {
        html.Url.revokeObjectUrl(uploadedUrls[index]); // Free memory
        uploadedFiles.removeAt(index);
        uploadedUrls.removeAt(index);
      }
    });
  }

  void clearAll() {
    setState(() {
      for (var url in uploadedUrls) {
        html.Url.revokeObjectUrl(url);
      }
      uploadedFiles.clear();
      uploadedUrls.clear();

      removedExistingUrls.addAll(existingUrls);
      existingUrls.clear();

      widget.onFilesSelected?.call([]);
      widget.onExistingRemoved?.call(removedExistingUrls);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.initialUrls != null) {
      existingUrls = List.from(widget.initialUrls!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> allUrls = [...existingUrls, ...uploadedUrls];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDragging
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          width: isDragging ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isDragging
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.icon, color: Colors.grey, size: 32),
                            Text(widget.subtitle,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DropzoneView(
                        onCreated: (controller) => dropController = controller,
                        onDropMultiple: (dynamic files) async {
                          List<html.File> fileList =
                              List<html.File>.from(files);

                          setState(() {
                            isDragging = false;
                            uploadedFiles.addAll(fileList);
                            uploadedUrls.addAll(fileList
                                .map((file) => html.Url.createObjectUrl(file))
                                .toList());
                          });

                          widget.onFilesSelected?.call(fileList);
                          print(
                              "Selected files: ${fileList.map((file) => file.name).toList()}");
                        },
                        onHover: () => setState(() => isDragging = true),
                        onLeave: () => setState(() => isDragging = false),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: TextButton(
                        onPressed: () {
                          _pickFiles();
                        },
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                              Colors.transparent), // Disables hover effect
                        ),
                        child: const Text("Browse Files",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          if (allUrls.isNotEmpty)
            SizedBox(
              height: 150,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse, // Enables mouse dragging
                  },
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: allUrls.length,
                  itemBuilder: (context, index) {
                    bool isExisting = index < existingUrls.length;
                    return Stack(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Image.network(
                              allUrls[index],
                              fit: BoxFit.contain,
                              width: 100,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  errorImageUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index, isExisting),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
