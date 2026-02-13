import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/remote_urls.dart';
import '../../utils/constants.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/rounded_app_bar.dart';

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

  /// PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
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
      if (mounted) {
        setState(() => _error = 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _runTryOn() async {
    if (_personImagePath == null) {
      setState(() => _error = 'Please capture or upload your photo first.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _resultImageBase64 = null;
    });

    try {
      // Optional: health check
      try {
        final healthRes = await http
            .get(Uri.parse(RemoteUrls.tryOnHealthUrl))
            .timeout(const Duration(seconds: 10));
        if (!healthRes.statusCode.toString().startsWith('2')) {
          debugPrint('[TryOn] Health returned ${healthRes.statusCode}');
        }
      } catch (_) {}

      final uri = Uri.parse(RemoteUrls.tryOnApiUrl);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Oui-User/1.0';

      request.fields['cloth_type'] = widget.clothType;
      // Backend requires image/jpeg or image/png (rejects application/octet-stream)
      final personFile = File(_personImagePath!);
      final personBytes = await personFile.readAsBytes();
      final personIsPng = _isPngBytes(personBytes);
      request.files.add(http.MultipartFile.fromBytes(
        'person_image',
        personBytes,
        filename: personIsPng ? 'person.png' : 'person.jpg',
        contentType: MediaType('image', personIsPng ? 'png' : 'jpeg'),
      ));

      final clothBytes = await http.readBytes(Uri.parse(widget.clothImageUrl));
      // Backend requires image/jpeg or image/png (rejects application/octet-stream)
      final isPng = _isPngBytes(clothBytes) ||
          widget.clothImageUrl.toLowerCase().contains('.png');
      request.files.add(http.MultipartFile.fromBytes(
        'cloth_image',
        clothBytes,
        filename: isPng ? 'cloth.png' : 'cloth.jpg',
        contentType: MediaType('image', isPng ? 'png' : 'jpeg'),
      ));

      final streamed = await request.send().timeout(
            const Duration(seconds: 180),
            onTimeout: () => throw Exception('Try-on timed out'),
          );
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (!response.statusCode.toString().startsWith('2')) {
        final body = response.body;
        String detail = 'Request failed ${response.statusCode}';
        try {
          final json = jsonDecode(body) as Map<String, dynamic>?;
          if (json != null && json['detail'] != null) {
            detail = json['detail'].toString();
          }
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
          _error = 'Invalid response: no image';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoundedAppBar(
        titleText: 'Virtual Try-On',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Try on: ${widget.productName}',
                style: headlineTextStyle(18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildClothPreview(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPersonPreview(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: redColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: paragraphTextStyle(14).copyWith(color: redColor),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _runTryOn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Utils.dynamicPrimaryColor(context),
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: white),
                        )
                      : const Text('Try On'),
                ),
              ),
              if (_resultImageBase64 != null) ...[
                const SizedBox(height: 24),
                Text('Result', style: headlineTextStyle(16)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(_resultImageBase64!),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  setState(() {
                    _personImagePath = null;
                    _resultImageBase64 = null;
                    _error = null;
                  });
                },
                child: const Text('Start over'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClothPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomImage(
        path: widget.clothImageUrl,
        fit: BoxFit.cover,
        height: 160,
        width: double.infinity,
      ),
    );
  }

  Widget _buildPersonPreview() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _personImagePath != null
          ? Image.file(
              File(_personImagePath!),
              fit: BoxFit.cover,
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 48, color: grayColor),
                  const SizedBox(height: 8),
                  Text(
                    'Your photo',
                    style: paragraphTextStyle(12),
                  ),
                ],
              ),
            ),
    );
  }
}
