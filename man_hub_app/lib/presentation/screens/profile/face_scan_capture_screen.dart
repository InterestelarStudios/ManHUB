import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/face_scan_service.dart';
import '../../widgets/face_scanner_overlay.dart';
import 'face_scan_result_screen.dart';

enum ScanStage { initializing, front, left, right, processing }

/// Tela de captura e escaneamento biométrico facial (Abordagem Tempo Real).
class FaceScanCaptureScreen extends StatefulWidget {
  const FaceScanCaptureScreen({super.key});

  @override
  State<FaceScanCaptureScreen> createState() => _FaceScanCaptureScreenState();
}

class _FaceScanCaptureScreenState extends State<FaceScanCaptureScreen> {
  CameraController? _cameraController;
  CameraDescription? _camera;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  ScanStage _currentStage = ScanStage.initializing;
  String _statusText = 'Inicializando scanner...';
  ScanDirection _direction = ScanDirection.none;
  
  bool _isProcessingFrame = false;
  DateTime? _alignedSince;
  Uint8List? _frontImageBytes;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        _camera!,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _currentStage = ScanStage.front;
        _statusText = 'Olhe diretamente para a câmera';
      });

      _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao acessar a câmera: $e')),
        );
      }
    }
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_camera == null || _cameraController == null) return null;
    
    final sensorOrientation = _camera!.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (_camera!.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessingFrame || _currentStage == ScanStage.processing) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        _resetAlignment('Posicione seu rosto na marcação', ScanDirection.none);
        _isProcessingFrame = false;
        return;
      }

      final face = faces.first;
      final double? rotY = face.headEulerAngleY; // Direita é positivo, esquerda é negativo

      if (rotY == null) {
        _isProcessingFrame = false;
        return;
      }

      if (_currentStage == ScanStage.front) {
        if (rotY > -10 && rotY < 10) {
          _handleAlignment('Mantenha a posição...');
          if (_hasBeenAlignedFor(1500)) {
            await _captureFrontAndMoveToNext();
          }
        } else {
          _resetAlignment('Olhe diretamente para a câmera', ScanDirection.none);
        }
      } else if (_currentStage == ScanStage.left) {
        // Devido ao espelhamento da câmera frontal, a lógica do EulerY é invertida
        if (rotY > 25) { // Agora verifica rotY > 25 para virar à esquerda
          _handleAlignment('Perfeito, mantenha...');
          if (_hasBeenAlignedFor(1000)) {
            setState(() {
              _currentStage = ScanStage.right;
              _alignedSince = null;
            });
          }
        } else {
          _resetAlignment('Vire o rosto para a ESQUERDA', ScanDirection.left);
        }
      } else if (_currentStage == ScanStage.right) {
        if (rotY < -25) { // Agora verifica rotY < -25 para virar à direita
          _handleAlignment('Perfeito, mantenha...');
          if (_hasBeenAlignedFor(1000)) {
            _finishScan();
          }
        } else {
          _resetAlignment('Vire o rosto para a DIREITA', ScanDirection.right);
        }
      }
    } catch (e) {
      debugPrint("Erro ao processar imagem: $e");
    } finally {
      if (mounted) _isProcessingFrame = false;
    }
  }

  void _handleAlignment(String message) {
    if (_alignedSince == null) {
      _alignedSince = DateTime.now();
      HapticFeedback.lightImpact();
    }
    if (_statusText != message && mounted) {
      setState(() {
        _statusText = message;
        _direction = ScanDirection.none;
      });
    }
  }

  void _resetAlignment(String message, ScanDirection direction) {
    _alignedSince = null;
    if ((_statusText != message || _direction != direction) && mounted) {
      setState(() {
        _statusText = message;
        _direction = direction;
      });
    }
  }

  bool _hasBeenAlignedFor(int milliseconds) {
    if (_alignedSince == null) return false;
    return DateTime.now().difference(_alignedSince!).inMilliseconds > milliseconds;
  }

  Future<void> _captureFrontAndMoveToNext() async {
    HapticFeedback.heavyImpact();
    try {
      await _cameraController!.stopImageStream();
      final file = await _cameraController!.takePicture();
      _frontImageBytes = await file.readAsBytes();
      
      if (!mounted) return;
      setState(() {
        _currentStage = ScanStage.left;
        _alignedSince = null;
      });
      await _cameraController!.startImageStream(_processCameraImage);
    } catch (e) {
      debugPrint("Erro ao capturar foto frontal: $e");
      // Fallback em caso de erro, avança mesmo sem a foto
      setState(() {
        _currentStage = ScanStage.left;
        _alignedSince = null;
      });
      await _cameraController!.startImageStream(_processCameraImage);
    }
  }

  Future<void> _finishScan() async {
    HapticFeedback.heavyImpact();
    await _cameraController!.stopImageStream();
    
    if (mounted) {
      setState(() {
        _currentStage = ScanStage.processing;
        _statusText = 'Analisando proporções biométricas...';
        _direction = ScanDirection.none;
      });
    }

    try {
      final bytesToAnalyze = _frontImageBytes ?? Uint8List(0); 
      final result = await FaceScanService().analyzeFace(bytesToAnalyze);

      if (!mounted) return;

      final appliedShape = await Navigator.of(context).push<String>(
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              FaceScanResultScreen(result: result),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );

      if (appliedShape != null && mounted) {
        Navigator.of(context).pop(appliedShape);
      } else if (mounted) {
        setState(() {
          _currentStage = ScanStage.front;
          _statusText = 'Olhe diretamente para a câmera';
          _alignedSince = null;
        });
        await _cameraController!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no diagnóstico: $e')),
        );
        setState(() {
          _currentStage = ScanStage.front;
          _statusText = 'Olhe diretamente para a câmera';
          _alignedSince = null;
        });
        await _cameraController!.startImageStream(_processCameraImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitializing = _currentStage == ScanStage.initializing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'BIOMETRIA FACIAL',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isInitializing)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.neonPrimary),
              ),
            )
          else if (_currentStage == ScanStage.processing)
            _buildProcessingView()
          else
            _buildCameraView(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        CameraPreview(_cameraController!),

        // Overlay do Scanner (Oval, Mira, Setas)
        FaceScannerOverlay(
          isScanning: true,
          statusText: _statusText,
          direction: _direction,
        ),
      ],
    );
  }

  Widget _buildProcessingView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_frontImageBytes != null)
          Image.memory(
            _frontImageBytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        FaceScannerOverlay(
          isScanning: true,
          statusText: _statusText,
          direction: ScanDirection.none,
        ),
      ],
    );
  }
}
