import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medicine_form_data.dart';
import '../services/ai_scanner_service.dart';
import 'add_edit_medicine_page.dart';
import 'widgets/scan_result_review_sheet.dart';

class ScanPrescriptionPage extends ConsumerStatefulWidget {
  const ScanPrescriptionPage({super.key});

  @override
  ConsumerState<ScanPrescriptionPage> createState() =>
      _ScanPrescriptionPageState();
}

class _ScanPrescriptionPageState extends ConsumerState<ScanPrescriptionPage>
    with WidgetsBindingObserver {
  static const _primaryBlue = Color(0xFF38C2EE);

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No cameras available on this device.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      // Use back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) {
      return;
    }

    try {
      final xFile = await _cameraController!.takePicture();
      await _processImage(File(xFile.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;

    await _processImage(File(xFile.path));
  }

  Future<void> _processImage(File imageFile) async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Analyzing prescription with Gemini AI...',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final medications =
          await AiScannerService.scanPrescription(imageFile);

      if (mounted) Navigator.of(context).pop(); // close dialog

      if (medications.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No medications found in the prescription.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      debugPrint('AI Scanner response: $medications');

      // If multiple medications found, let user pick one
      Map<String, dynamic> selected;
      if (medications.length == 1) {
        selected = medications.first;
      } else {
        if (!mounted) return;
        final picked = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Medication',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${medications.length} medications found',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...medications.map(
                    (med) => ListTile(
                      leading: Icon(Icons.medication_outlined,
                          color: _primaryBlue),
                      title: Text(
                        med['name']?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${med['milligrams'] ?? ''} ${med['type'] ?? ''} · ${med['dose'] ?? '1'}x · ${med['meal_instruction'] ?? ''}',
                        style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12.sp),
                      ),
                      onTap: () => Navigator.of(context).pop(med),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        if (picked == null) {
          setState(() => _isProcessing = false);
          return;
        }
        selected = picked;
      }

      // Show the review sheet so the user can verify and add missing info
      if (!mounted) return;
      final reviewed = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFFEAF6FB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) => ScanResultReviewSheet(
            scannedData: selected,
          ),
        ),
      );

      if (reviewed == null) {
        // User dismissed the review sheet
        setState(() => _isProcessing = false);
        return;
      }

      // Build pre-filled form data from reviewed result and navigate
      final formData = _buildFormData(reviewed);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reviewed['name']} added successfully!'),
            backgroundColor: _primaryBlue,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AddEditMedicinePage(existing: formData),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // close dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Scan failed: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  MedicineFormData _buildFormData(Map<String, dynamic> data) {
    final form = MedicineFormData();

    if (data['name'] != null) {
      form.name = data['name'].toString();
    }
    if (data['milligrams'] != null &&
        data['milligrams'].toString().isNotEmpty) {
      form.milligrams = data['milligrams'].toString();
    }
    if (data['dose'] != null) {
      form.dose = data['dose'].toString();
    }
    if (data['type'] != null) {
      final typeStr = data['type'].toString().toLowerCase();
      final matchedType = MedicineType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => MedicineType.pills,
      );
      form.type = matchedType;
    }
    if (data['time'] != null) {
      final timeStr = data['time'].toString();
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 9;
        final m = int.tryParse(parts[1]) ?? 0;
        form.time = TimeOfDay(hour: h, minute: m);
      }
    }
    if (data['meal_instruction'] != null) {
      form.mealInstruction = data['meal_instruction'].toString();
    }

    return form;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            _buildCameraPreview(),

            // Top bar (back + title + gallery button)
            _buildTopBar(),

            // Scanner overlay frame
            _buildScannerOverlay(),

            // Bottom capture button
            _buildCaptureButton(),

            // Processing overlay
            if (_isProcessing) _buildProcessingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 1,
          height: _cameraController!.value.previewSize?.width ?? 1,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),

            // Title
            Expanded(
              child: Text(
                'Scan Prescription',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Gallery button
            IconButton(
              onPressed: _isProcessing ? null : _pickFromGallery,
              icon: Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
              tooltip: 'Add Image',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ScannerOverlayPainter(
            borderColor: _primaryBlue,
            overlayColor: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 40.h,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Hint text
          Text(
            'Position prescription within the frame',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 20.h),

          // Capture button
          GestureDetector(
            onTap: _isProcessing ? null : _capturePhoto,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4.w),
              ),
              child: Center(
                child: Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: _primaryBlue,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16.h),
              Text(
                'Processing...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scanner overlay painter ──────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final Color overlayColor;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = size.width * 0.85;
    final frameHeight = size.height * 0.40;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2 - 20;
    final rect = Rect.fromLTWH(left, top, frameWidth, frameHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Draw semi-transparent overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(rrect);
    final combinedPath =
        Path.combine(PathOperation.difference, overlayPath, cutoutPath);

    canvas.drawPath(
      combinedPath,
      Paint()..color = overlayColor,
    );

    // Draw corner brackets
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 30.0;
    const r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + cornerLen)
        ..lineTo(rect.left, rect.top + r)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + r, rect.top)
        ..lineTo(rect.left + cornerLen, rect.top),
      borderPaint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLen, rect.top)
        ..lineTo(rect.right - r, rect.top)
        ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + r)
        ..lineTo(rect.right, rect.top + cornerLen),
      borderPaint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - cornerLen)
        ..lineTo(rect.left, rect.bottom - r)
        ..quadraticBezierTo(
            rect.left, rect.bottom, rect.left + r, rect.bottom)
        ..lineTo(rect.left + cornerLen, rect.bottom),
      borderPaint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - cornerLen, rect.bottom)
        ..lineTo(rect.right - r, rect.bottom)
        ..quadraticBezierTo(
            rect.right, rect.bottom, rect.right, rect.bottom - r)
        ..lineTo(rect.right, rect.bottom - cornerLen),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
