import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../try_on/presentation/controllers/try_on_controller.dart';
import '../controllers/catalog_controller.dart';
import '../data/mock_catalog_data.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upca,
    BarcodeFormat.upce,
    BarcodeFormat.code128,
    BarcodeFormat.qrCode,
  ]);

  CameraController? _cameraController;
  bool _isProcessingFrame = false;
  bool _barcodeDetected = false;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    _initScannerCamera();
  }

  Future<void> _initScannerCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _statusText = 'No physical camera detected. Use simulated barcodes below.');
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _statusText = 'Align garment tag / barcode within target');

      _cameraController!.startImageStream(_processCameraFrame);
    } catch (e) {
      debugPrint('[BarcodeScanner] Camera initialization error: $e');
      setState(() => _statusText = 'Camera unavailable. Use simulated barcode triggers below.');
    }
  }

  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _barcodeDetected) return;
    _isProcessingFrame = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final camera = _cameraController?.description;
      final imageRotation = camera != null
          ? InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg
          : InputImageRotation.rotation0deg;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty && !_barcodeDetected) {
        final rawValue = barcodes.first.rawValue;
        if (rawValue != null && rawValue.isNotEmpty) {
          _handleBarcodeFound(rawValue);
        }
      }
    } catch (e) {
      debugPrint('[BarcodeScanner] Frame analysis error: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _handleBarcodeFound(String barcode) async {
    if (_barcodeDetected) return;
    setState(() {
      _barcodeDetected = true;
      _statusText = 'Tag Scanned: $barcode\nMatching catalog...';
    });

    final product = await ref.read(catalogControllerProvider.notifier).lookupBarcode(barcode);

    if (!mounted) return;

    if (product != null) {
      ref.read(tryOnControllerProvider.notifier).selectProduct(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Matched in-store product: ${product.title}'),
          backgroundColor: const Color(0xFF00E676),
        ),
      );
      // Direct jump to try-on workspace
      context.go('${RouteConstants.tryOnPath}?productId=${product.id}');
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          title: const Text('Unknown Barcode', style: TextStyle(color: Colors.white)),
          content: Text(
            'Barcode "$barcode" was not found in the retail catalog database.',
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _barcodeDetected = false;
                  _statusText = 'Align garment tag / barcode within target';
                });
              },
              child: const Text('Scan Again', style: TextStyle(color: Color(0xFF6C63FF))),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('In-Store Scanner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview Layer
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!)
          else
            Container(
              color: const Color(0xFF18181B),
              child: const Center(
                child: Icon(Icons.qr_code_scanner, size: 80, color: Colors.white24),
              ),
            ),

          // Reticle Overlay
          Center(
            child: Container(
              width: 280,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00E676), width: 2.5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Status & Instruction Text
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _statusText ?? 'Point camera at physical garment tag or barcode',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Quick In-Store Test Barcodes Drawer (For Simulators & Physical Testing)
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24).withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulate In-Store Tag Scan:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MockCatalogData.sampleProducts.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.qr_code, size: 16, color: Color(0xFF00E676)),
                            label: Text(
                              '${p.title.split(' ').first} (${p.barcode.substring(0, 6)}...)',
                              style: const TextStyle(fontSize: 11, color: Colors.white),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.08),
                            side: const BorderSide(color: Colors.white24),
                            onPressed: () => _handleBarcodeFound(p.barcode),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
