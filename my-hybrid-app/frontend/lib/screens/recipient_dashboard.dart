import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/fake_map_widget.dart';
import 'qr_scanner_screen.dart';
import 'about_us_screen.dart';

class RecipientDashboard extends StatefulWidget {
  const RecipientDashboard({super.key});

  @override
  State<RecipientDashboard> createState() => _RecipientDashboardState();
}

class _RecipientDashboardState extends State<RecipientDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBite'),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isSharer: false,
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const QRScannerScreen();
      case 2:
        return _buildMapScreen();
      case 3:
        return _buildAboutScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentOrange,
                  AppTheme.accentOrange.withValues(alpha: 0.8),
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
                  'Welcome!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find fresh food donations near you',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Scan QR to Claim',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Navigate to map tab
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Find SmartBite Hub',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week Claimed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'RM 45 worth of food',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RM 200 limit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.225, // 45/200
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fair distribution ensures everyone gets access',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'My Claimed Items',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildClaimedItemCard(
            'Fresh Vegetables Mix',
            'Expires in 2 days',
            'Claimed 1 hour ago',
            AppTheme.successGreen,
          ),
          const SizedBox(height: 12),
          _buildClaimedItemCard(
            'Bread Loaves (2x)',
            'Expires tomorrow',
            'Claimed yesterday',
            AppTheme.warningRed,
          ),
          const SizedBox(height: 12),
          _buildClaimedItemCard(
            'Canned Goods',
            'Expires in 1 week',
            'Claimed 2 days ago',
            AppTheme.successGreen,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your privacy is protected. Only you can see your claimed items.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SmartBite Hub Locations',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Find collection points near you',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You are here',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'Jalan University, Kuantan Campus',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.navigation, color: Colors.red.shade600),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const FakeMapWidget(showHubs: true),

          const SizedBox(height: 24),

          Text(
            'Available Hubs',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          _buildHubListItem(
            'Central Hub',
            'UMPSA Main Campus, Block A',
            '0.3 km away',
            '12 items available',
            AppTheme.successGreen,
          ),
          const SizedBox(height: 12),
          _buildHubListItem(
            'Kuantan Mall Hub',
            'East Coast Mall, Level G',
            '1.8 km away',
            '6 items available',
            AppTheme.accentOrange,
          ),
          const SizedBox(height: 12),
          _buildHubListItem(
            'Community Hub',
            'Taman Gelora Community Center',
            '2.2 km away',
            '9 items available',
            AppTheme.successGreen,
          ),
          const SizedBox(height: 12),
          _buildHubListItem(
            'Hospital Hub',
            'Hospital Tengku Ampuan Afzan',
            '3.1 km away',
            '4 items available',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutScreen() {
    return const AboutUsScreen();
  }

  Widget _buildHubListItem(
    String name,
    String address,
    String distance,
    String items,
    Color statusColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(Icons.store, color: statusColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              distance,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _getEstimatedTime(distance),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    items,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showNavigationDialog(name, address, distance);
                    },
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showHubDetails(name, address, items);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _getEstimatedTime(String distance) {
    final distanceValue = double.tryParse(distance.split(' ').first) ?? 1.0;
    final minutes = (distanceValue * 12)
        .round(); // Assuming 5 km/h walking speed
    return '~${minutes}min walk';
  }

  void _showNavigationDialog(String hubName, String address, String distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.navigation, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text('Navigate to $hubName'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: $address'),
            const SizedBox(height: 8),
            Text('Distance: $distance'),
            const SizedBox(height: 8),
            Text('Estimated time: ${_getEstimatedTime(distance)}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will open your preferred navigation app',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening navigation to $hubName...'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text(
              'Navigate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHubDetails(String hubName, String address, String items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.store, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(hubName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 Address: $address'),
            const SizedBox(height: 8),
            Text('📦 $items'),
            const SizedBox(height: 8),
            const Text('🕒 Operating Hours: 9:00 AM - 6:00 PM'),
            const SizedBox(height: 8),
            const Text('📞 Contact: +60 12-345 6789'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tips_and_updates,
                    color: AppTheme.accentOrange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Present your QR code to collect food items',
                      style: TextStyle(color: AppTheme.accentOrange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimedItemCard(
    String title,
    String expiry,
    String claimedTime,
    Color statusColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(Icons.fastfood, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiry,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    claimedTime,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusColor == AppTheme.successGreen ? 'Safe' : 'Use Soon',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
