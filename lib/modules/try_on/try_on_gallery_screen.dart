import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

/// Instagram/Snapchat-style gallery picker with device photos.
/// On Android < 14, falls back to system image picker.
/// Full-width vertical layout. Returns selected photo path.
class TryOnGalleryScreen extends StatefulWidget {
  const TryOnGalleryScreen({super.key});

  @override
  State<TryOnGalleryScreen> createState() => _TryOnGalleryScreenState();
}

class _TryOnGalleryScreenState extends State<TryOnGalleryScreen> {
  List<AssetEntity> _assets = [];
  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _currentAlbum;
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isContinuing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  /// Opens the system image picker via image_picker package.
  /// Used as fallback for Android < 14.
  Future<void> _openSystemGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        Navigator.pop(context, image.path);
      } else if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Android < 14 (SDK < 34): use system gallery picker directly
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt < 34) {
        await _openSystemGallery();
        return;
      }
    }

    final permission = await PhotoManager.requestPermissionExtend();
    // Accept both full and limited (Android 14+) access
    if (!permission.isAuth && !permission.hasAccess) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Please allow photo access to continue';
        });
      }
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false)
        ],
      ),
    );

    if (albums.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'No photos found on this device';
        });
      }
      return;
    }

    _albums = albums;
    _currentAlbum = albums.first;

    final count = await _currentAlbum!.assetCountAsync;
    if (count == 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'No photos found';
        });
      }
      return;
    }

    final assets = await _currentAlbum!.getAssetListRange(
      start: 0,
      end: count > 50 ? 50 : count,
    );

    if (mounted) {
      setState(() {
        _assets = assets;
        _selectedIndex = 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _onContinue() async {
    if (_assets.isEmpty || _isContinuing) return;
    setState(() => _isContinuing = true);

    try {
      final file = await _assets[_selectedIndex].file;
      if (file != null && mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      if (mounted) setState(() => _isContinuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Stack(
          children: [
            // ── Scrollable content ──
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF131313), strokeWidth: 1.5),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_outlined,
                          size: 48, color: Color(0xFFAAAAAA)),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: const Color(0xFF777777)),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => PhotoManager.openSetting(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF131313)),
                          ),
                          child: Text(
                            'OPEN SETTINGS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF131313),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildGalleryBody(topPad),

            // ── Header bar ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80 + topPad,
                padding: EdgeInsets.only(
                    top: topPad, left: 32, right: 32),
                decoration: const BoxDecoration(
                  color: Color(0xCC131313),
                ),
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
                          'SELECT PHOTO',
                          style: GoogleFonts.notoSerif(
                            fontSize: 14,
                            color: Colors.white,
                            letterSpacing: 2.80,
                            height: 1.43,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                  ],
                ),
              ),
            ),

            // ── Bottom CONTINUE button ──
            if (_assets.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFFF9F9F9),
                        const Color(0xE5F9F9F9),
                        const Color(0x00F9F9F9),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      32, 24, 32, bottomPad + 32),
                  child: GestureDetector(
                    onTap: _onContinue,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48),
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: _isContinuing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CONTINUE',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 3.30,
                                    height: 1.50,
                                  ),
                                ),
                                Icon(Icons.arrow_forward,
                                    size: 18,
                                    color: Colors.white
                                        .withValues(alpha: 0.60)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryBody(double topPad) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPad + 80 + 32,
        left: 16,
        right: 16,
        bottom: 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Heading ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERSONAL ARCHIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF5E5E5E),
                    letterSpacing: 1,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'YOUR\nCANVAS',
                  style: GoogleFonts.notoSerif(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B1B1B),
                    letterSpacing: -2.40,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── Grid with quotes ──
          ..._buildGridWithQuotes(),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  static const _quotes = [
    '"Style is a way to say\nwho you are without\nhaving to speak."',
    '"Fashion fades, only\nstyle remains the same."',
    '"Elegance is the only\nbeauty that never fades."',
    '"Dress like you\'re\nalready famous."',
    '"In a world full of trends,\nremain a classic."',
    '"Simplicity is the\nkeynote of all\ntrue elegance."',
  ];

  List<Widget> _buildGridWithQuotes() {
    final widgets = <Widget>[];
    int photoIndex = 0;

    while (photoIndex < _assets.length) {
      // Take up to 5 photos for this group
      final groupEnd =
          (photoIndex + 5).clamp(0, _assets.length);
      final groupPhotos =
          List.generate(groupEnd - photoIndex, (i) => photoIndex + i);

      widgets.add(_buildPhotoGroup(groupPhotos));

      photoIndex = groupEnd;

      // Insert quote after every 5-photo group
      if (photoIndex < _assets.length || groupPhotos.length == 5) {
        final quoteIdx =
            (photoIndex ~/ 5 - 1) % _quotes.length;
        widgets.add(_buildQuote(_quotes[quoteIdx]));
      }
    }

    return widgets;
  }

  /// Builds a group of photos in a mixed grid layout.
  /// Pattern: Row of 2, then Row of 3, or single wide, etc.
  Widget _buildPhotoGroup(List<int> indices) {
    if (indices.isEmpty) return const SizedBox.shrink();

    final widgets = <Widget>[];
    int i = 0;

    while (i < indices.length) {
      final remaining = indices.length - i;

      if (remaining >= 3) {
        // Row of 2 (tall)
        widgets.add(
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(child: _gridCell(indices[i], 220)),
                const SizedBox(width: 4),
                Expanded(child: _gridCell(indices[i + 1], 220)),
              ],
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        // 1 wide
        widgets.add(
          SizedBox(
            height: 180,
            child: _gridCell(indices[i + 2], 180),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        i += 3;
      } else if (remaining == 2) {
        // Row of 2
        widgets.add(
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: _gridCell(indices[i], 200)),
                const SizedBox(width: 4),
                Expanded(
                    flex: 2,
                    child: _gridCell(indices[i + 1], 200)),
              ],
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        i += 2;
      } else {
        // Single wide
        widgets.add(
          SizedBox(
            height: 240,
            child: _gridCell(indices[i], 240),
          ),
        );
        widgets.add(const SizedBox(height: 4));
        i += 1;
      }
    }

    return Column(children: widgets);
  }

  Widget _gridCell(int index, double height) {
    final isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        width: double.infinity,
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          border: isSelected
              ? Border.all(color: const Color(0xFF131313), width: 2)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: isSelected ? 1.0 : 0.65,
              child: _AssetImage(
                asset: _assets[index],
                width: 400,
                height: (height * 1.5).toInt(),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 26,
                  height: 26,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Icon(Icons.check,
                      size: 14, color: Color(0xFF131313)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuote(String quote) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      child: Center(
        child: Text(
          quote,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF999999),
            height: 1.60,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }


}

/// Robust image widget that loads thumbnails from an AssetEntity
/// with loading/error states.
class _AssetImage extends StatefulWidget {
  final AssetEntity asset;
  final int width;
  final int height;

  const _AssetImage({
    required this.asset,
    required this.width,
    required this.height,
  });

  @override
  State<_AssetImage> createState() => _AssetImageState();
}

class _AssetImageState extends State<_AssetImage> {
  Uint8List? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AssetImage old) {
    super.didUpdateWidget(old);
    if (old.asset.id != widget.asset.id) {
      _bytes = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final bytes = await widget.asset.thumbnailDataWithSize(
        ThumbnailSize(widget.width, widget.height),
        quality: 85,
      );
      if (mounted) {
        if (bytes != null && bytes.isNotEmpty) {
          setState(() => _bytes = bytes);
        } else {
          // Fallback: try to load full file
          final file = await widget.asset.file;
          if (file != null && mounted) {
            final fileBytes = await file.readAsBytes();
            setState(() => _bytes = fileBytes);
          } else {
            setState(() => _failed = true);
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: const Color(0xFFEEEEEE),
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              size: 32, color: Color(0xFFCCCCCC)),
        ),
      );
    }
    if (_bytes == null) {
      return Container(
        color: const Color(0xFFF3F3F3),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 1.5, color: Color(0xFFCCCCCC)),
          ),
        ),
      );
    }
    return Image.memory(
      _bytes!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
