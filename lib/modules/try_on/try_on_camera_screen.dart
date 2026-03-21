import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';

/// Snapchat/Instagram-style custom camera with live viewfinder,
/// silhouette guide frame, timer, gallery shortcut.
/// Returns captured photo path via Navigator.pop, or 'OPEN_GALLERY'.
class TryOnCameraScreen extends StatefulWidget {
  const TryOnCameraScreen({super.key});

  @override
  State<TryOnCameraScreen> createState() => _TryOnCameraScreenState();
}

class _TryOnCameraScreenState extends State<TryOnCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isFrontCamera = false; // back camera by default for full-body
  String? _error;

  int _timerSeconds = 0; // 0 = instant capture
  int _countdown = 0;
  Timer? _countdownTimer;
  bool _isCapturing = false;
  bool _isDisposed = false;

  // Gallery shortcut thumbnail
  Uint8List? _lastPhotoThumb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startup();
  }

  /// Sequential startup: init camera first, then load gallery thumbnail.
  /// Avoids simultaneous permission requests which crash on Android 14+.
  Future<void> _startup() async {
    await _initCamera();
    if (mounted) _loadLastPhoto();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only dispose camera when truly paused (home button / app switch),
    // NOT on inactive (permission dialogs, notification shade).
    if (state == AppLifecycleState.paused) {
      _controller?.dispose();
      _controller = null;
      if (mounted) setState(() => _isInitialized = false);
    } else if (state == AppLifecycleState.resumed) {
      if (_controller == null && !_isDisposed) {
        _initCamera();
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) setState(() => _error = 'No cameras available');
        return;
      }

      final direction =
          _isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back;
      final cam = _cameras.firstWhere(
        (c) => c.lensDirection == direction,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      _controller = controller;
      setState(() {
        _isInitialized = true;
        _error = null;
      });
    } on CameraException catch (e) {
      if (mounted) setState(() => _error = 'Camera: ${e.description}');
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera init failed');
    }
  }

  Future<void> _loadLastPhoto() async {
    try {
      final perm = await PhotoManager.requestPermissionExtend();
      if (!perm.isAuth && !perm.hasAccess) return;
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false)
          ],
        ),
      );
      if (albums.isEmpty) return;
      final assets =
          await albums.first.getAssetListRange(start: 0, end: 1);
      if (assets.isEmpty) return;
      final thumb = await assets.first
          .thumbnailDataWithSize(const ThumbnailSize(80, 80));
      if (mounted && thumb != null) {
        setState(() => _lastPhotoThumb = thumb);
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing) return;
    setState(() {
      _isInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });
    await _controller?.dispose();
    _controller = null;
    await _initCamera();
  }

  void _onCaptureTap() {
    if (_isCapturing || _countdown > 0) return;
    if (_timerSeconds == 0) {
      _capturePhoto();
      return;
    }
    setState(() => _countdown = _timerSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        setState(() => _countdown = 0);
        _capturePhoto();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _capturePhoto() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized || _isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      // Haptic feedback like Snapchat
      HapticFeedback.mediumImpact();

      final file = await ctrl.takePicture();
      if (mounted) Navigator.pop(context, file.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _error = 'Capture failed — try again';
        });
      }
    }
  }

  void _cycleTimer() {
    if (_countdown > 0) return;
    setState(() {
      _timerSeconds = _timerSeconds == 0
          ? 3
          : _timerSeconds == 3
              ? 5
              : _timerSeconds == 5
                  ? 10
                  : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // Frame rect calculation
    const frameHInset = 48.0;
    const frameTopGap = 76.0; // enough room for guidance text above frame
    final frameTop = topPad + 80 + frameTopGap;
    final frameBottom = bottomPad + 196;
    final frameLeft = frameHInset;
    final frameRight = screenW - frameHInset;
    final frameHeight = screenH - frameTop - frameBottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0E0E),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Live camera preview (full screen) ──
            if (_isInitialized && _controller != null)
              Positioned.fill(child: _buildCameraPreview())
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 48, color: Color(0xFF555555)),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            fontSize: 14, color: const Color(0xFF777777)),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          setState(() => _error = null);
                          _initCamera();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: const Color(0xFF555555)),
                          ),
                          child: Text('RETRY',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white,
                                  letterSpacing: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 1.5),
              ),

            // ── 2. Overlay with cutout (white frost outside frame) ──
            Positioned.fill(
              child: CustomPaint(
                painter: _FrameCutoutPainter(
                  frameRect: Rect.fromLTRB(
                    frameLeft,
                    frameTop,
                    frameRight,
                    screenH - frameBottom,
                  ),
                  overlayColor: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),

            // ── 3. Frame border + corner markers ──
            Positioned(
              left: frameHInset,
              top: frameTop,
              right: frameHInset,
              child: SizedBox(
                height: frameHeight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Stack(
                    children: [
                      _cornerMarker(Alignment.topLeft),
                      _cornerMarker(Alignment.topRight),
                      _cornerMarker(Alignment.bottomLeft),
                      _cornerMarker(Alignment.bottomRight),
                      // Countdown
                      if (_countdown > 0)
                        Center(
                          child: Text(
                            '$_countdown',
                            style: GoogleFonts.notoSerif(
                              fontSize: 120,
                              fontWeight: FontWeight.w300,
                              color:
                                  Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // ── 4. Top bar ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80 + topPad,
                padding:
                    EdgeInsets.only(top: topPad, left: 32, right: 32),
                decoration:
                    const BoxDecoration(color: Color(0xCC0E0E0E)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'TRY-ON',
                          style: GoogleFonts.notoSerif(
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 2.80,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Icon(Icons.flip_camera_ios_outlined,
                          size: 20,
                          color: Colors.white.withValues(alpha: 0.80)),
                    ),
                  ],
                ),
              ),
            ),

            // ── 5. Guidance text (below top bar, above frame) ──
            Positioned(
              left: 32,
              right: 32,
              top: topPad + 80 + 6,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    color: Colors.black.withValues(alpha: 0.50),
                    child: Text(
                      'GUIDANCE ACTIVE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                        letterSpacing: 3,
                        height: 1.50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Align your body within the frame',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.50,
                    ),
                  ),
                ],
              ),
            ),

            // ── 6. Bottom controls ──
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    32, 16, 32, bottomPad + 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.70),
                      Colors.black.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Distance hint
                    Opacity(
                      opacity: 0.60,
                      child: Text(
                        'MAINTAIN 2 METERS DISTANCE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFFC7C6C6),
                          letterSpacing: 1,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // PHOTO label
                    Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text(
                        'PHOTO',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white,
                          letterSpacing: 2.20,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Capture row
                    SizedBox(
                      width: 320,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gallery shortcut (latest photo thumbnail)
                          GestureDetector(
                            onTap: () =>
                                Navigator.pop(context, 'OPEN_GALLERY'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.20),
                                  width: 2,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _lastPhotoThumb != null
                                  ? Image.memory(
                                      _lastPhotoThumb!,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                    )
                                  : const Icon(
                                      Icons.photo_library_outlined,
                                      size: 18,
                                      color: Colors.white70),
                            ),
                          ),
                          // Capture button
                          GestureDetector(
                            onTap: _onCaptureTap,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 120),
                                width: _isCapturing ? 44 : 64,
                                height: _isCapturing ? 44 : 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          // Timer toggle
                          GestureDetector(
                            onTap: _cycleTimer,
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              child: _timerSeconds == 0
                                  ? Icon(Icons.timer_off_outlined,
                                      size: 22,
                                      color: Colors.white
                                          .withValues(alpha: 0.50))
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(Icons.timer_outlined,
                                            size: 22,
                                            color: Colors.white),
                                        Positioned(
                                          bottom: 2,
                                          child: Text(
                                            '${_timerSeconds}s',
                                            style: GoogleFonts.inter(
                                              fontSize: 8,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final ctrl = _controller!;
    final previewSize = ctrl.value.previewSize!;
    // previewSize is in landscape orientation (width > height)
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(ctrl),
          ),
        ),
      ),
    );
  }

  Widget _cornerMarker(Alignment alignment) {
    const size = 28.0;
    const inset = 24.0;
    return Positioned(
      left: alignment == Alignment.topLeft ||
              alignment == Alignment.bottomLeft
          ? inset
          : null,
      right: alignment == Alignment.topRight ||
              alignment == Alignment.bottomRight
          ? inset
          : null,
      top: alignment == Alignment.topLeft ||
              alignment == Alignment.topRight
          ? inset
          : null,
      bottom: alignment == Alignment.bottomLeft ||
              alignment == Alignment.bottomRight
          ? inset
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight)
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft)
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
            right: (alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.white, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Custom painter that draws a dark overlay with a rectangular cutout
/// so the camera feed is clearly visible inside the frame.
class _FrameCutoutPainter extends CustomPainter {
  final Rect frameRect;
  final Color overlayColor;

  _FrameCutoutPainter({required this.frameRect, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = overlayColor;
    // Draw overlay with hole
    final outer = Path()..addRect(Offset.zero & size);
    final inner = Path()..addRect(frameRect);
    final combined = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_FrameCutoutPainter old) =>
      old.frameRect != frameRect || old.overlayColor != overlayColor;
}
