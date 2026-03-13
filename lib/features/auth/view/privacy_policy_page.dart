import 'package:flutter/material.dart';

/// Full-screen privacy policy view.
/// - When opened from signup: pass [onAgree] (and optionally keep [showAgreeSection] = true)
///   so the Agree button is shown and required.
/// - When opened from other pages (e.g. Help & Support): set [showAgreeSection] to false
///   to show the policy as read-only with no Agree button.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({
    super.key,
    this.onAgree,
    this.showAgreeSection = true,
  });

  /// Called when user taps "Agree" at the bottom. Caller should set terms agreed and may pop.
  final VoidCallback? onAgree;

  /// Whether to show the bottom "Do you agree?" section with the Agree button.
  /// Defaults to true (used for signup flow). Set to false for read-only views.
  final bool showAgreeSection;

  static const String route = '/privacy-policy';

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollThresholdPx = 80;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Check scroll position after first layout (e.g. if content is short)
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    // If there's nothing to scroll (short content), consider at bottom
    final reachedBottom =
        maxScroll <= 0 || (maxScroll - currentScroll) <= _scrollThresholdPx;
    if (reachedBottom != _hasScrolledToBottom) {
      setState(() => _hasScrolledToBottom = reachedBottom);
    }
  }

  static const String _content = '''
Effective Date: 02/07/2026

Bonique LLC ("Bonique," "we," "us," or "our") operates an AI-powered virtual try-on and fashion styling platform (the "Service"). This Privacy Policy explains how we collect, use, disclose, retain, and protect Personal Data when you use our Service, and it describes your rights under applicable privacy laws, including the General Data Protection Regulation (GDPR) and the California Consumer Privacy Act, as amended by the California Privacy Rights Act (CCPA/CPRA).

Information We Collect
We collect Personal Data that you voluntarily provide when you interact with the Service. This includes images and photographs that you upload or capture using your device camera, images of wardrobe items, responses to questionnaires related to style or preferences, user identifiers such as account or user IDs, and any information you choose to provide when communicating with Bonique.

How We Collect and Process Images
When you use the virtual try-on feature, you may select an existing image from your device or take a new photo through the application. Images are subject to size and quality limits to ensure efficient processing. The image is first stored locally on your device and then uploaded to secure cloud storage managed by Supabase. Images are stored in a designated storage bucket using a path that includes your user ID and a timestamp. Once uploaded, the application receives a URL that allows Bonique's backend systems to access the image securely.

The application then sends a request to Bonique's AI backend, which includes references to the uploaded person image, the selected clothing item, and your user identifier. Bonique's AI systems process these inputs to generate a virtual try-on image that visually combines the person image and the clothing item. The resulting image is returned to the application and displayed to you, where you may choose to save it or try another outfit.

When you upload wardrobe items separately, those images are sent to Bonique's AI backend for analysis. The AI systems extract relevant attributes such as clothing type, color, fabric, and other descriptive features. The resulting analysis is stored in Bonique's database to support wardrobe organization and styling features.

Purposes of Processing
Bonique processes Personal Data in order to provide and operate the Service, generate virtual try-on results, analyze clothing items, personalize styling recommendations, maintain and improve platform functionality, enhance user experience, and ensure platform security. In addition, Bonique may use images and questionnaire data to train and improve its AI models over time in order to increase the quality, accuracy, and reliability of the Service. Where feasible, training activities use aggregated or de-identified data.

Legal Bases for Processing
Bonique processes Personal Data based on contractual necessity where processing is required to deliver the Service, on consent where applicable, on legitimate interests related to improving and securing the Service, and where necessary to comply with legal obligations. When processing is based on consent, you may withdraw that consent at any time.

Sharing and Disclosure of Personal Data
Bonique shares Personal Data only to the extent necessary to operate the Service. This includes sharing data with cloud storage providers, AI processing services, and infrastructure providers that support image processing, analytics, and system reliability. Bonique does not sell Personal Data to third parties.

Data Retention
Bonique retains Personal Data only for as long as it is necessary to fulfill the purposes described in this Policy or to meet legal and operational requirements. When Personal Data is no longer required, it is deleted, anonymized, or aggregated. If immediate deletion is not possible, the data is securely stored and isolated from further processing until deletion occurs.

Your Privacy Rights
Depending on your location, you may have rights to access, correct, delete, or restrict the processing of your Personal Data, to object to certain processing activities, to request data portability, and to withdraw consent where processing is based on consent. California residents have additional rights under the CCPA/CPRA, including the right to know what Personal Data is collected, the right to request deletion or correction, and the right not to be discriminated against for exercising privacy rights.

Security
Bonique uses appropriate technical and organizational measures designed to protect Personal Data against unauthorized access, loss, misuse, or alteration. These measures are proportionate to the sensitivity of the data and the risks associated with processing.

Policy Updates
Bonique may update this Privacy Policy from time to time. Material changes will be communicated through the Service or by other appropriate means.

Contact Information
If you have questions or concerns about this Privacy Policy or our data practices, you may contact us at contact@bonique.co
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: SelectableText(
                  _content.trim(),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),
            // Do you agree? section – only shown when [showAgreeSection] is true.
            if (widget.showAgreeSection)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Do you agree to this Privacy Policy?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (!_hasScrolledToBottom) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Scroll to the bottom to enable Agree',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _hasScrolledToBottom
                            ? () {
                                widget.onAgree?.call();
                                Navigator.of(context).pop();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Agree'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
