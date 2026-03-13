import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/view/privacy_policy_page.dart';

class HelpSupportPage extends ConsumerWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            _buildSection(
              context: context,
              title: 'Frequently Asked Questions',
              children: [
                _buildFAQItem(
                  context: context,
                  question: 'How do I add items to my wardrobe?',
                  answer:
                      'Go to the Wardrobe tab and tap the + button to add new clothing items. You can take photos or upload images from your gallery.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'How does the outfit recommendation work?',
                  answer:
                      'Our AI analyzes your wardrobe items and suggests combinations based on your preferences, the occasion, and current fashion trends.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'Can I share my outfits with friends?',
                  answer:
                      'Yes! You can share your favorite outfits on social media or send them directly to friends through the app.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'How do I update my profile information?',
                  answer:
                      'Go to Profile > Edit Profile to update your name, email, bio, and profile picture.',
                ),
                _buildFAQItem(
                  context: context,
                  question: 'Is my data secure?',
                  answer:
                      'Yes, we use industry-standard encryption to protect your personal information and wardrobe data.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Support Section
            _buildSection(
              context: context,
              title: 'Contact Support',
              children: [
                _buildContactTile(
                  context: context,
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'contact@bonique.com',
                  onTap: () => _launchEmail(),
                ),
                _buildContactTile(
                  context: context,
                  icon: Icons.phone_outlined,
                  title: 'Phone Support',
                  subtitle: '+1 (781) 579-9475',
                  onTap: () => _launchPhone(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Information
            _buildSection(
              context: context,
              title: 'App Information',
              children: [
                _buildInfoTile(
                  context: context,
                  title: 'Version',
                  value: '1.0.0',
                ),
                _buildInfoTile(context: context, title: 'Build', value: '1'),
                _buildInfoTile(
                  context: context,
                  title: 'Privacy Policy',
                  value: 'View our privacy policy',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            const PrivacyPolicyPage(showAgreeSection: false),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildFAQItem({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@bonique.com',
      query: 'subject=Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Fallback: copy email to clipboard
      // You could implement clipboard functionality here
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+17815799475');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, you'd send this to your backend
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bug report submitted! Thank you for your feedback.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
