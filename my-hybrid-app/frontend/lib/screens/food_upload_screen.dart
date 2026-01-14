import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';
import 'delivery_tracking_screen.dart';

class FoodUploadScreen extends StatefulWidget {
  const FoodUploadScreen({super.key});

  @override
  State<FoodUploadScreen> createState() => _FoodUploadScreenState();
}

class _FoodUploadScreenState extends State<FoodUploadScreen> {
  bool _isScanning = false;
  bool _isScanMode = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Meat';
  bool _isHalal = true;
  DateTime? _selectedDate;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Food'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isScanMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isScanMode
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'AI Scan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isScanMode
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isScanMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_isScanMode
                              ? AppTheme.primaryGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Manual Input',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isScanMode
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_isScanMode) ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen, width: 2),
                  ),
                  child: _isScanning
                      ? _buildScanningAnimation()
                      : _buildCameraPlaceholder(),
                ),
              ),
            ] else ...[
              Expanded(child: _buildManualInputForm()),
            ],

            const SizedBox(height: 24),

            if (_isScanMode && !_isScanning)
              ElevatedButton(
                onPressed: _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Start Scanning',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else if (_isScanMode && _isScanning)
              ElevatedButton(
                onPressed: _stopScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Stop Scanning',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              ElevatedButton(
                onPressed: _submitFoodDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Upload Food Details',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    if (_selectedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(_selectedImage!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: () => setState(() => _selectedImage = null),
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: AppTheme.primaryGreen.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to take photo or select image',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'AI will automatically detect food type and details',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
        ),
        const SizedBox(height: 24),
        Text(
          'Detecting food type...',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryGreen),
        ),
        const SizedBox(height: 8),
        Text(
          'Please hold steady',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildManualInputForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name *',
                hintText: 'e.g., Chicken Breast',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Food name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items:
                  [
                        'Meat',
                        'Vegetables',
                        'Fruits',
                        'Dairy',
                        'Grains',
                        'Prepared Food',
                      ]
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional details about the food',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('Halal:', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(width: 16),
                  Switch(
                    value: _isHalal,
                    onChanged: (value) {
                      setState(() {
                        _isHalal = value;
                      });
                    },
                    thumbColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.primaryGreen;
                      }
                      return Colors.grey;
                    }),
                    trackColor: WidgetStateProperty.resolveWith<Color>((
                      states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return AppTheme.primaryGreen.withValues(alpha: 0.5);
                      }
                      return Colors.grey.withValues(alpha: 0.3);
                    }),
                  ),
                  const Spacer(),
                  Text(
                    _isHalal ? 'Yes' : 'No',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isHalal
                          ? AppTheme.primaryGreen
                          : AppTheme.warningRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expiry Date *',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select expiry date',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: _selectedDate != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            if (_selectedDate == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Expiry date is required',
                style: TextStyle(color: AppTheme.warningRed, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),

            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Approximate Value (RM) *',
                hintText: '15.00',
                prefixText: 'RM ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Value is required';
                }
                final double? amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Commission Fee Notice',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.accentOrange,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SmartBite charges a 3% commission to maintain our platform and support community operations.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_valueController.text.isNotEmpty) ...[
                    Text(
                      'Example: For RM ${_valueController.text} food value = RM ${(_calculateCommission()).toStringAsFixed(2)} fee',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.primaryGreen;
                    }
                    return Colors.grey;
                  }),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _acceptTerms = !_acceptTerms;
                      });
                    },
                    child: Text(
                      'I accept the commission fee and terms of service for food sharing on SmartBite platform.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateCommission() {
    final double value = double.tryParse(_valueController.text) ?? 0.0;
    return value * 0.03;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Expiry Date',
      cancelText: 'Cancel',
      confirmText: 'Select',
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _startScanning() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: AppTheme.warningRed,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // Call real AI API
      final result = await ApiService.analyzeFood(_selectedImage!);

      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      if (result['success'] == true && result['data'] != null) {
        _showDetectionResultFromAI(result['data']);
      } else {
        _showErrorDialog('AI could not analyze the food. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isScanning = false;
      });

      _showErrorDialog(
        'Connection error: $e\n\nTried API: ${ApiService.baseUrl}\n\nMake sure the backend server is running and reachable from your phone.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDetectionResultFromAI(Map<String, dynamic> data) {
    final String foodName = data['food_name'] ?? 'Unknown Food';
    final String category = data['category'] ?? 'Prepared Food';
    final bool isHalal = data['is_halal'] ?? true;
    final int expiryDays = data['estimated_expiry_days'] ?? 3;
    final double estimatedValue = (data['estimated_value'] ?? 10.0).toDouble();
    final String explanation = data['explanation'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            const Text('Food Detected!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow('Food:', foodName),
              _buildResultRow('Category:', category),
              _buildResultRow('Halal:', isHalal ? 'Yes ✓' : 'No'),
              _buildResultRow('Expires in:', '$expiryDays days'),
              _buildResultRow(
                'Est. Value:',
                'RM ${estimatedValue.toStringAsFixed(2)}',
              ),
              if (explanation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Commission: RM ${(estimatedValue * 0.03).toStringAsFixed(2)} (3%)\nNet value: RM ${(estimatedValue * 0.97).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isScanMode = false;
                _nameController.text = foodName;
                _selectedCategory = _mapCategory(category);
                _isHalal = isHalal;
                _valueController.text = estimatedValue.toStringAsFixed(2);
                _selectedDate = DateTime.now().add(Duration(days: expiryDays));
              });
            },
            child: const Text('Edit Details'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessAndTracking(
                FoodItem(
                  name: foodName,
                  category: _mapCategory(category),
                  isHalal: isHalal,
                  expiryDate: DateTime.now().add(Duration(days: expiryDays)),
                  value: estimatedValue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text(
              'Confirm & Share',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 3),
          ),
        ],
      ),
    );
  }

  String _mapCategory(String aiCategory) {
    final mapping = {
      'meat': 'Meat',
      'vegetables': 'Vegetables',
      'fruits': 'Fruits',
      'dairy': 'Dairy',
      'grains': 'Grains',
      'prepared_food': 'Prepared Food',
      'prepared food': 'Prepared Food',
    };
    return mapping[aiCategory.toLowerCase()] ?? 'Prepared Food';
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  void _submitFoodDetails() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date'),
          backgroundColor: AppTheme.warningRed,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and commission fee'),
          backgroundColor: AppTheme.warningRed,
        ),
      );
      return;
    }

    final foodItem = FoodItem(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      isHalal: _isHalal,
      expiryDate: _selectedDate!,
      value: double.parse(_valueController.text),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    _showSuccessAndTracking(foodItem);
  }

  void _showSuccessAndTracking(FoodItem foodItem) {
    final String trackingNumber =
        'SB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successGreen,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking Number: $trackingNumber',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Food: ${foodItem.name}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your food donation has been submitted and is under review. A driver will be assigned shortly after approval.',
              style: TextStyle(fontSize: 14, fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryTrackingScreen(
                        trackingNumber: trackingNumber,
                        foodName: foodItem.name,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Track Delivery',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
