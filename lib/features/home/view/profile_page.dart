import 'package:bonique/features/auth/view/account_page.dart';
import 'package:bonique/features/home/view/edit_profile_page.dart';
import 'package:bonique/features/home/view/account_security_page.dart';
// import 'package:bonique/features/home/view/outfit_history_page.dart';
import 'package:bonique/features/home/view/help_support_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/home_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final authState = ref.watch(authViewModelProvider);

    // Get user info from Supabase auth state
    final user = authState.isLoggedIn
        ? ref.read(authViewModelProvider.notifier).currentUser
        : null;
    final displayName =
        user?.userMetadata?['full_name'] ?? state.username ?? 'John Ahem';
    final email = user?.email ?? 'john432@bonique.ai';

    // Listen for auth state changes to handle logout
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (!next.isLoggedIn && previous?.isLoggedIn == true) {
        // User has been logged out, navigate to auth page
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            title: const Text('Profile'),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  color: const Color(0xFFF7F7F7),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            authState.currentUserModel?.avatarUrl != null
                            ? NetworkImage(
                                authState.currentUserModel!.avatarUrl!,
                              )
                            : null,
                        child: authState.currentUserModel?.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 36,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SettingsList(
                  items: [
                    _SettingsItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      subtitle: 'Name, Photo, Personal Info',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Account & Security',
                      subtitle: 'Change Password, Manage Login Methods',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountSecurityPage(),
                        ),
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.history,
                      title: 'Outfit History',
                      subtitle: 'Saved Outfits',
                      onTap: () => {},
                    ),
                    _SettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQ, Contact Support',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context, controller),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF0F0F0),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Log Out'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    HomeController controller,
  ) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await controller.signOut();
    }
  }
}

class _SettingsList extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _SettingsTile(item: items[i]),
              if (i != items.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
}

class _SettingsTile extends StatelessWidget {
  final _SettingsItem item;

  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFF0F0F0),
        child: Icon(item.icon, color: Colors.black87),
      ),
      title: Text(
        item.title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
      ),
      onTap: item.onTap,
    );
  }
}
