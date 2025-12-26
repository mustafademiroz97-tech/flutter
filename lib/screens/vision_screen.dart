import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../config/dark_theme_config.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({Key? key}) : super(key: key);

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  late ApiService _apiService;
  final ImagePicker _imagePicker = ImagePicker();
  
  // State management
  bool _isLoading = false;
  bool _isCameraActive = false;
  String? _errorMessage;
  Map<String, dynamic>? _analysisResult;
  File? _selectedImage;
  
  // Camera stream
  late StreamController<List<int>> _cameraStreamController;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _cameraStreamController = StreamController<List<int>>();
  }

  void _initializeApiService() {
    try {
      _apiService = ApiService();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize API Service: ${e.toString()}');
    }
  }

  Future<void> _captureAndAnalyze() async {
    try {
      _setLoading(true);
      _clearError();

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _setLoading(false);
        return;
      }

      final File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImage = imageFile;
      });

      // Send image to API for analysis
      final response = await _apiService.post(
        '/api/capture',
        imageFile: imageFile,
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _analysisResult = response;
          _errorMessage = null;
        });
        _showSuccessMessage('Analysis completed successfully');
      } else {
        _setError(response?['message'] ?? 'Analysis failed');
      }
    } catch (e) {
      _setError('Error during capture and analysis: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _setLoading(false);
        return;
      }

      final File imageFile = File(pickedFile.path);
      setState(() {
        _selectedImage = imageFile;
      });

      // Send image to API for analysis
      final response = await _apiService.post(
        '/api/capture',
        imageFile: imageFile,
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _analysisResult = response;
          _errorMessage = null;
        });
        _showSuccessMessage('Analysis completed successfully');
      } else {
        _setError(response?['message'] ?? 'Analysis failed');
      }
    } catch (e) {
      _setError('Error picking image: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _toggleCameraStream() async {
    try {
      if (_isCameraActive) {
        _disableCameraStream();
      } else {
        await _enableCameraStream();
      }
    } catch (e) {
      _setError('Error toggling camera stream: ${e.toString()}');
    }
  }

  Future<void> _enableCameraStream() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Check if camera stream is available
      final streamUrl = _apiService.cameraVideoFeedUrl;
      
      if (streamUrl.isEmpty) {
        _setError('Camera stream URL is not available');
        return;
      }

      setState(() {
        _isCameraActive = true;
      });
      _showSuccessMessage('Camera stream started');
    } catch (e) {
      _setError('Failed to start camera stream: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _disableCameraStream() {
    setState(() {
      _isCameraActive = false;
      _analysisResult = null;
    });
    _showSuccessMessage('Camera stream stopped');
  }

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DarkThemeConfig.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAnalysis() {
    setState(() {
      _analysisResult = null;
      _selectedImage = null;
      _errorMessage = null;
    });
  }

  Widget _buildCameraPreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: DarkThemeConfig.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: DarkThemeConfig.surfaceColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _isCameraActive
            ? Image.network(
                _apiService.cameraVideoFeedUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Failed to load camera stream',
                      style: TextStyle(
                        color: DarkThemeConfig.errorColor,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.videocam_off_outlined,
                  size: 64,
                  color: DarkThemeConfig.secondaryColor.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    if (_selectedImage == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: DarkThemeConfig.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: DarkThemeConfig.surfaceColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    if (_analysisResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarkThemeConfig.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DarkThemeConfig.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analysis Results',
                style: TextStyle(
                  color: DarkThemeConfig.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: DarkThemeConfig.secondaryColor,
                ),
                onPressed: _clearAnalysis,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._analysisResult!.entries
              .where((entry) => entry.key != 'success' && entry.key != 'timestamp')
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatKey(entry.key),
                          style: TextStyle(
                            color: DarkThemeConfig.secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatValue(entry.value),
                          style: TextStyle(
                            color: DarkThemeConfig.textColor.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          if (_analysisResult!['timestamp'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Timestamp: ${_analysisResult!['timestamp']}',
              style: TextStyle(
                color: DarkThemeConfig.textColor.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'_'),
          (match) => ' ',
        )
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('\n');
    }
    return value.toString();
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DarkThemeConfig.errorColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DarkThemeConfig.errorColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: DarkThemeConfig.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: DarkThemeConfig.errorColor,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: DarkThemeConfig.errorColor,
              size: 18,
            ),
            onPressed: _clearError,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _captureAndAnalyze,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkThemeConfig.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: DarkThemeConfig.primaryColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _pickFromGallery,
            icon: const Icon(Icons.image),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkThemeConfig.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: DarkThemeConfig.primaryColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraStreamButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _toggleCameraStream,
        icon: Icon(
          _isCameraActive ? Icons.videocam_off : Icons.videocam,
        ),
        label: Text(
          _isCameraActive ? 'Stop Stream' : 'Start Stream',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isCameraActive
              ? DarkThemeConfig.errorColor
              : DarkThemeConfig.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: DarkThemeConfig.primaryColor.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('Vision Analysis'),
        backgroundColor: DarkThemeConfig.surfaceColor,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: DarkThemeConfig.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Camera Stream Section
                Text(
                  'Live Camera Stream',
                  style: TextStyle(
                    color: DarkThemeConfig.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildCameraPreview(),
                ),
                const SizedBox(height: 16),
                _buildCameraStreamButton(),
                const SizedBox(height: 24),

                // Image Selection Section
                Text(
                  'Analysis',
                  style: TextStyle(
                    color: DarkThemeConfig.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedImage != null) ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: _buildSelectedImagePreview(),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildActionButtons(),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null) ...[
                  _buildErrorMessage(),
                  const SizedBox(height: 24),
                ],

                // Analysis Results
                if (_analysisResult != null) ...[
                  _buildAnalysisResults(),
                  const SizedBox(height: 24),
                ],

                // Loading Indicator
                if (_isLoading)
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DarkThemeConfig.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: DarkThemeConfig.textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
