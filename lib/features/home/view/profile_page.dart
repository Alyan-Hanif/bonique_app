import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/home_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    final displayName = state.username ?? 'John Ahem';
    const email = 'john432@bonique.ai';

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
                        backgroundImage: null,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
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
                  items: const [
                    _SettingsItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      subtitle: 'Name, Photo, Personal Info',
                    ),
                    _SettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Account & Security',
                      subtitle: 'Change Password, Manage Login Methods',
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Outfit Suggestions, Style Tips, Reminders',
                    ),
                    _SettingsItem(
                      icon: Icons.history,
                      title: 'Outfit History',
                      subtitle: 'Saved Outfits',
                    ),
                    _SettingsItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQ, Contact Support',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: controller.signOut,
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

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
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
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
