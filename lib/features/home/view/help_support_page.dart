import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
              title: 'Frequently Asked Questions',
              children: [
                _buildFAQItem(
                  question: 'How do I add items to my wardrobe?',
                  answer:
                      'Go to the Wardrobe tab and tap the + button to add new clothing items. You can take photos or upload images from your gallery.',
                ),
                _buildFAQItem(
                  question: 'How does the outfit recommendation work?',
                  answer:
                      'Our AI analyzes your wardrobe items and suggests combinations based on your preferences, the occasion, and current fashion trends.',
                ),
                _buildFAQItem(
                  question: 'Can I share my outfits with friends?',
                  answer:
                      'Yes! You can share your favorite outfits on social media or send them directly to friends through the app.',
                ),
                _buildFAQItem(
                  question: 'How do I update my profile information?',
                  answer:
                      'Go to Profile > Edit Profile to update your name, email, bio, and profile picture.',
                ),
                _buildFAQItem(
                  question: 'Is my data secure?',
                  answer:
                      'Yes, we use industry-standard encryption to protect your personal information and wardrobe data.',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contact Support Section
            _buildSection(
              title: 'Contact Support',
              children: [
                _buildContactTile(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'Get help via email',
                  onTap: () => _launchEmail(),
                ),
                _buildContactTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Live Chat',
                  subtitle: 'Chat with our support team',
                  onTap: () => _showComingSoon(context, 'Live Chat'),
                ),
                _buildContactTile(
                  icon: Icons.phone_outlined,
                  title: 'Phone Support',
                  subtitle: '+1 (555) 123-4567',
                  onTap: () => _launchPhone(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resources Section
            _buildSection(
              title: 'Resources',
              children: [
                _buildContactTile(
                  icon: Icons.book_outlined,
                  title: 'User Guide',
                  subtitle: 'Learn how to use all features',
                  onTap: () => _showComingSoon(context, 'User Guide'),
                ),
                _buildContactTile(
                  icon: Icons.video_library_outlined,
                  title: 'Video Tutorials',
                  subtitle: 'Watch step-by-step guides',
                  onTap: () => _showComingSoon(context, 'Video Tutorials'),
                ),
                _buildContactTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Report a Bug',
                  subtitle: 'Help us improve the app',
                  onTap: () => _showBugReportDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App Information
            _buildSection(
              title: 'App Information',
              children: [
                _buildInfoTile(title: 'Version', value: '1.0.0'),
                _buildInfoTile(title: 'Build', value: '2024.01.15'),
                _buildInfoTile(
                  title: 'Privacy Policy',
                  value: 'View our privacy policy',
                  onTap: () => _showComingSoon(context, 'Privacy Policy'),
                ),
                _buildInfoTile(
                  title: 'Terms of Service',
                  value: 'View our terms of service',
                  onTap: () => _showComingSoon(context, 'Terms of Service'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B1A18),
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

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1B1A18),
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
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1B1A18)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1B1A18),
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
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Color(0xFF1B1A18),
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
      path: 'support@bonique.ai',
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
    final Uri phoneUri = Uri(scheme: 'tel', path: '+15551234567');

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
