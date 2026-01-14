import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';
import '../utils/app_theme.dart';
import 'sharer_dashboard.dart';
import 'recipient_dashboard.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Language Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildLanguageToggle(context)],
                ),

                const SizedBox(height: 32),

                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 50,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SmartBite',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reduce waste, share care',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'How would you like to help?',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                _buildRoleCard(
                  context,
                  title: 'Continue as Sharer',
                  subtitle: 'Share your surplus food with the community',
                  icon: Icons.share,
                  color: AppTheme.primaryGreen,
                  onTap: () => _selectRole(context, UserRole.sharer),
                ),

                const SizedBox(height: 16),

                _buildRoleCard(
                  context,
                  title: 'Continue as Recipient',
                  subtitle: 'Find food donations near you',
                  icon: Icons.volunteer_activism,
                  color: AppTheme.accentOrange,
                  onTap: () => _selectRole(context, UserRole.recipient),
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Together, we can reduce food waste and support our community',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageButton(
              '🇬🇧',
              'en',
              appState.selectedLanguage,
              appState,
            ),
            const SizedBox(width: 8),
            _buildLanguageButton(
              '🇨🇳',
              'zh',
              appState.selectedLanguage,
              appState,
            ),
            const SizedBox(width: 8),
            _buildLanguageButton(
              '🇲🇾',
              'ms',
              appState.selectedLanguage,
              appState,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageButton(
    String flag,
    String code,
    String selected,
    AppState appState,
  ) {
    final isSelected = selected == code;
    return GestureDetector(
      onTap: () => appState.setLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppTheme.primaryGreen) : null,
        ),
        child: Text(flag, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, size: 30, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, UserRole role) {
    context.read<AppState>().setUserRole(role);

    Widget destination;
    if (role == UserRole.sharer) {
      destination = const SharerDashboard();
    } else {
      destination = const RecipientDashboard();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
