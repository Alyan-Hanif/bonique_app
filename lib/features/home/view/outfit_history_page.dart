import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bonique/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bonique/data/repositories/wardrobe_repository.dart';
import 'package:bonique/core/utils/snackbar_utils.dart';
import 'package:bonique/core/widgets/loading_animation.dart';
import 'package:photo_view/photo_view.dart';

class OutfitHistoryPage extends ConsumerStatefulWidget {
  const OutfitHistoryPage({super.key});

  @override
  ConsumerState<OutfitHistoryPage> createState() => _OutfitHistoryPageState();
}

class _OutfitHistoryPageState extends ConsumerState<OutfitHistoryPage> {
  bool _isLoading = false;
  bool _imagesPreloaded = false;
  Map<String, dynamic>? _historyData;
  List<dynamic>? _lastHistoryItems;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final authState = ref.read(authViewModelProvider);

    if (!authState.isLoggedIn) {
      setState(() {
        _errorMessage = 'Please log in to view your outfit history';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imagesPreloaded = false;
    });

    try {
      final userId = authState.currentUserModel!.id;
      print('🔍 Fetching outfit history for user: $userId');

      final history = await WardrobeRepository.getTryOnHistory(userId);

      setState(() {
        _historyData = history;
        _isLoading = false;
      });

      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          title: 'History Loaded',
          message: 'Your outfit history has been loaded successfully',
        );
      }
    } catch (e) {
      print('❌ Failed to fetch history: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        SnackbarUtils.showError(
          context,
          title: 'Error',
          message: 'Failed to load outfit history: $e',
        );
      }
    }
  }

  Future<void> _preloadImages(List<dynamic> historyItems) async {
    try {
      print('🚀 STARTING _preloadImages() with ${historyItems.length} items');

      if (historyItems.isNotEmpty) {
        print('🖼️ PRELOADING ${historyItems.length} try-on images...');
        final imageUrls = historyItems
            .where((item) => item['try_on_url'] != null)
            .map((item) => item['try_on_url'] as String)
            .toList();

        for (var url in imageUrls) {
          print('   - Preloading image: $url');
        }

        await Future.wait(
          imageUrls.map((url) => precacheImage(NetworkImage(url), context)),
        );
        print('✅ ALL TRY-ON IMAGES PRELOADED');
      } else {
        print('⚠️ NO HISTORY ITEMS FOUND - EMPTY LIST');
      }

      if (mounted) {
        print('🔄 SETTING STATE: _imagesPreloaded=true');
        setState(() {
          _imagesPreloaded = true;
        });
        print('✅ STATE UPDATED SUCCESSFULLY');
      } else {
        print('⚠️ WIDGET NOT MOUNTED - SKIPPING STATE UPDATE');
      }
    } catch (e) {
      print('❌ ERROR in _preloadImages: $e');
      print('❌ STACK TRACE: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _imagesPreloaded = true;
        });
      }
    }
  }

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Outfit History',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingAnimation(
          message: 'Loading your outfit history...',
          width: 150,
          height: 150,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error Loading History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_historyData == null) {
      return Center(
        child: Text(
          'No history data available',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    // Display the history data
    final data = _historyData!['data'];
    if (data == null || (data is List && data.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Outfit History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try on some outfits to see them here!',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Parse the history items
    final List<dynamic> historyItems = data is List ? data : [data];

    // Check if we have new data or need to start preloading
    final hasNewData =
        _lastHistoryItems == null ||
        _lastHistoryItems!.length != historyItems.length ||
        !_imagesPreloaded;

    if (hasNewData) {
      print('🔄 NEW HISTORY DATA DETECTED OR PRELOADING NEEDED');
      _lastHistoryItems = historyItems;
      _imagesPreloaded = false;
      print('🚀 STARTING PRELOADING...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadImages(historyItems);
      });
    }

    // Show loading while preloading images
    if (!_imagesPreloaded) {
      return const Center(
        child: LoadingAnimation(
          message: 'Loading images...',
          width: 150,
          height: 150,
        ),
      );
    }

    // Display the history items with fade-in animation
    return AnimatedOpacity(
      opacity: _imagesPreloaded ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: RefreshIndicator(
        onRefresh: _fetchHistory,
        color: Theme.of(context).colorScheme.primary,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return _buildHistoryCard(item);
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final String? tryOnUrl = item['try_on_url'];
    final String? createdAt = item['created_at'];

    // Parse and format date
    String formattedDate = 'Unknown date';
    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt);
        formattedDate =
            '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return GestureDetector(
      onTap: () => _showImageDetail(item),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: tryOnUrl != null
                  ? Image.network(
                      tryOnUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),
            ),

            // Info section
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _ImageDetailPage(item: item)),
    );
  }
}

class _ImageDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ImageDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    final String? tryOnUrl = item['try_on_url'];
    final String? createdAt = item['created_at'];

    // Parse and format date
    String formattedDate = 'Unknown date';
    if (createdAt != null) {
      try {
        final dateTime = DateTime.parse(createdAt);
        formattedDate =
            '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDate = createdAt;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Try-On Result',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoBottomSheet(context),
          ),
        ],
      ),
      body: tryOnUrl != null
          ? PhotoView(
              imageProvider: NetworkImage(tryOnUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Center(
                child: CircularProgressIndicator(
                  value: event == null
                      ? 0
                      : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  color: Colors.white,
                ),
              ),
              errorBuilder: (context, error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No image available',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Text(
            formattedDate,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Try-On Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Details
            _buildInfoRow(
              Icons.calendar_today,
              'Created',
              item['created_at'] ?? 'Unknown',
            ),
            if (item['overall_assessment'] != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.assessment,
                'Assessment',
                item['overall_assessment'],
              ),
            ],
            if (item['recommendation'] != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.lightbulb_outline,
                'Recommendation',
                item['recommendation'],
              ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
