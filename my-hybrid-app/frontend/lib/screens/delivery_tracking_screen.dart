import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/fake_map_widget.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String trackingNumber;
  final String foodName;

  const DeliveryTrackingScreen({
    super.key,
    required this.trackingNumber,
    required this.foodName,
  });

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  int _currentStep = 0;
  String _riderLocation = "pickup";
  bool _reviewApproved = false;

  @override
  void initState() {
    super.initState();
    _startTrackingAnimation();
  }

  void _startTrackingAnimation() {
    // Stage 0: Review (before assigning a driver)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _reviewApproved = true;
      });
    });

    // Stage 1: Driver assigned (starts after review)
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _riderLocation = "onway";
      });
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 2;
        _riderLocation = "hub";
      });
    });

    Future.delayed(const Duration(seconds: 11), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreen.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentStep == 0
                        ? (_reviewApproved
                              ? 'Review Approved'
                              : 'Food Under Review')
                        : 'Food Pickup In Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_currentStep == 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      _reviewApproved
                          ? 'Proceeding to assign a driver...'
                          : 'We are verifying your submission...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Tracking: ${widget.trackingNumber}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Item: ${widget.foodName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Live Tracking',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            FakeMapWidget(
              showHubs: true,
              showRider: _currentStep < 3,
              riderLocation: _riderLocation,
            ),

            const SizedBox(height: 24),

            Text(
              'Pickup Progress',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            _buildProgressStep(
              0,
              _reviewApproved ? 'Review Approved' : 'Under Review',
              _reviewApproved
                  ? 'Your submission passed review. Assigning a driver now.'
                  : 'Your food submission is under review',
              Icons.inventory_2,
              isCompleted: _currentStep > 0,
              isActive: _currentStep == 0,
            ),
            _buildProgressStep(
              1,
              'Driver Assigned',
              'Ahmad (Rider #1249) is on the way',
              Icons.person,
              isCompleted: _currentStep >= 1,
              isActive: _currentStep == 1,
            ),
            _buildProgressStep(
              2,
              'On the Way',
              'Driver is picking up your food',
              Icons.motorcycle,
              isCompleted: _currentStep >= 2,
              isActive: _currentStep == 2,
            ),
            _buildProgressStep(
              3,
              'Delivered to Hub',
              'Food is now available for collection',
              Icons.restaurant,
              isCompleted: _currentStep >= 3,
              isActive: _currentStep == 3,
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppTheme.accentOrange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Completion',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _currentStep >= 3
                              ? 'Completed!'
                              : '${15 - (_currentStep * 3)} minutes',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: _currentStep >= 3
                                    ? AppTheme.successGreen
                                    : AppTheme.accentOrange,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_currentStep >= 1 && _currentStep < 3) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver Contact',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ahmad (Rider #1249)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+60 12-345 6789',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_currentStep >= 3) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Food Successfully Delivered!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your food is now available at Central Hub for collection by recipients.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentStep >= 3 ? 'Back to Dashboard' : 'Continue Tracking',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(
    int stepIndex,
    String title,
    String description,
    IconData icon, {
    required bool isCompleted,
    required bool isActive,
  }) {
    final Color stepColor = isCompleted
        ? AppTheme.successGreen
        : isActive
        ? AppTheme.accentOrange
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stepColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stepColor, width: 2),
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: stepColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: stepColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isActive) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.accentOrange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
