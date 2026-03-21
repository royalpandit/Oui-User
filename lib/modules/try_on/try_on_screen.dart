import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/remote_urls.dart';
import '../../widgets/custom_image.dart';

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({
    super.key,
    required this.productName,
    required this.clothImageUrl,
    required this.clothType,
  });

  final String productName;
  final String clothImageUrl;
  final String clothType;

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _personImagePath;
  bool _loading = false;
  String? _error;
  String? _resultImageBase64;

  static bool _isPngBytes(List<int> bytes) {
    if (bytes.length < 8) return false;
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (file != null && mounted) {
        setState(() {
          _personImagePath = file.path;
          _error = null;
          _resultImageBase64 = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to pick image: $e');
    }
  }

  Future<void> _runTryOn() async {
    if (_personImagePath == null) {
      setState(() => _error = 'Please add your photo first.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _resultImageBase64 = null;
    });
    try {
      try {
        await http
            .get(Uri.parse(RemoteUrls.tryOnHealthUrl))
            .timeout(const Duration(seconds: 10));
      } catch (_) {}

      final uri = Uri.parse(RemoteUrls.tryOnApiUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Oui-User/1.0';
      request.fields['cloth_type'] = widget.clothType;

      final personBytes = await File(_personImagePath!).readAsBytes();
      final personIsPng = _isPngBytes(personBytes);
      request.files.add(http.MultipartFile.fromBytes(
        'person_image',
        personBytes,
        filename: personIsPng ? 'person.png' : 'person.jpg',
        contentType: MediaType('image', personIsPng ? 'png' : 'jpeg'),
      ));

      final clothBytes = await http.readBytes(Uri.parse(widget.clothImageUrl));
      final isPng = _isPngBytes(clothBytes) ||
          widget.clothImageUrl.toLowerCase().contains('.png');
      request.files.add(http.MultipartFile.fromBytes(
        'cloth_image',
        clothBytes,
        filename: isPng ? 'cloth.png' : 'cloth.jpg',
        contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
      ));

      final streamed = await request
          .send()
          .timeout(const Duration(seconds: 180), onTimeout: () => throw Exception('Try-on timed out'));
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (!response.statusCode.toString().startsWith('2')) {
        String detail = 'Request failed (${response.statusCode})';
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>?;
          if (json?['detail'] != null) detail = json!['detail'].toString();
        } catch (_) {}
        setState(() {
          _loading = false;
          _error = detail;
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      final base64 = data?['imageBase64'] as String?;
      if (base64 == null || base64.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Invalid response from server.';
        });
        return;
      }
      setState(() {
        _loading = false;
        _resultImageBase64 = base64;
        _error = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _reset() {
    setState(() {
      _personImagePath = null;
      _resultImageBase64 = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF131313),
        appBar: AppBar(
          backgroundColor: const Color(0xFF131313),
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Virtual Try-On',
            style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _resultImageBase64 != null
              ? _ResultView(
                  base64: _resultImageBase64!,
                  onRetry: _reset,
                )
              : _TryOnForm(
                  productName: widget.productName,
                  clothImageUrl: widget.clothImageUrl,
                  personImagePath: _personImagePath,
                  loading: _loading,
                  error: _error,
                  onPickCamera: () => _pickImage(ImageSource.camera),
                  onPickGallery: () => _pickImage(ImageSource.gallery),
                  onTryOn: _runTryOn,
                ),
        ),
      ),
    );
  }
}

// ─── Form view ───────────────────────────────────────────────────────────────

class _TryOnForm extends StatelessWidget {
  const _TryOnForm({
    required this.productName,
    required this.clothImageUrl,
    required this.personImagePath,
    required this.loading,
    required this.error,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onTryOn,
  });

  final String productName;
  final String clothImageUrl;
  final String? personImagePath;
  final bool loading;
  final String? error;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onTryOn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B1B),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.checkroom_outlined, size: 14, color: Color(0xFF919191)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    productName,
                    style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFFE5E2E1)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Step row
          _StepRow(
            step: '1',
            label: 'Garment Preview',
            done: true,
          ),
          const SizedBox(height: 10),

          // Garment image — full width
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFF1C1B1B),
            child: CustomImage(
              path: clothImageUrl,
              fit: BoxFit.contain,
              height: 220,
              width: double.infinity,
            ),
          ),

          const SizedBox(height: 24),

          _StepRow(
            step: '2',
            label: 'Your Photo',
            done: personImagePath != null,
          ),
          const SizedBox(height: 10),

          // Person preview card
          GestureDetector(
            onTap: loading ? null : onPickGallery,
            child: Container(
              height: 220,
              width: double.infinity,
              color: const Color(0xFF1C1B1B),
              child: personImagePath != null
                  ? Image.file(
                      File(personImagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFF262626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline_rounded, size: 30, color: Color(0xFF919191)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to add your photo',
                          style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFC7C6C6), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full body, plain background preferred',
                          style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF5E5E5E)),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Camera / Gallery row
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: loading ? null : onPickCamera,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: loading ? null : onPickGallery,
                ),
              ),
            ],
          ),

          // Error banner
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1B1B),
                border: Border.fromBorderSide(BorderSide(color: Color(0xFF2A2A2A))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF919191)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error!,
                      style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFFE5E2E1)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          _StepRow(step: '3', label: 'Generate', done: false),
          const SizedBox(height: 10),

          // Try On CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : onTryOn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5E2E1),
                foregroundColor: const Color(0xFF131313),
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Color(0xFFE5E2E1), strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Try It On',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Hint text
          Center(
            child: Text(
              'Processing may take up to 60 seconds',
              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF5E5E5E)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Result view ─────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  const _ResultView({required this.base64, required this.onRetry});

  final String base64;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Look',
            style: GoogleFonts.notoSerif(fontSize: 20, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, color: const Color(0xFFE5E2E1)),
          ),
          const SizedBox(height: 4),
          Text(
            'Here is how you\'ll look in this outfit.',
            style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF919191)),
          ),
          const SizedBox(height: 16),
          Container(
            color: const Color(0xFF1C1B1B),
            child: Image.memory(
              base64Decode(base64),
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5E2E1),
                foregroundColor: const Color(0xFF131313),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF5E5E5E), width: 1.5),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'Back to Product',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.label, required this.done});

  final String step;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: done ? const Color(0xFFE5E2E1) : const Color(0xFF262626),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Color(0xFF131313))
              : Text(
                  step,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF919191)),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: onTap != null ? const Color(0xFFE5E2E1) : const Color(0xFF5E5E5E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: onTap != null ? const Color(0xFFE5E2E1) : const Color(0xFF5E5E5E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
