import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ImageSandbox extends StatefulWidget {
  const ImageSandbox({super.key});

  @override
  State<ImageSandbox> createState() => _ImageSandboxState();
}

class _ImageSandboxState extends State<ImageSandbox> {
  // State for refreshing network images to demonstrate loading
  bool _refreshNetworkImages = false;
  bool _showErrorImage = false;
  int _randomSeed = 0;

  // State for fade duration selection
  Duration _selectedFadeDuration = const Duration(milliseconds: 300);
  final List<Duration> _fadeDurations = const [
    Duration(milliseconds: 0),
    Duration(milliseconds: 300),
    Duration(milliseconds: 800),
    Duration(milliseconds: 1500),
  ];

  @override
  Widget build(BuildContext context) {
    // Generate image URLs outside the build method
    final String baseNetworkUrl = 'https://picsum.photos/seed';
    final String timestampParam =
        DateTime.now().millisecondsSinceEpoch.toString();

    // Pre-generate all image URLs
    final Map<String, String> imageUrls = {
      'basic':
          '$baseNetworkUrl/${_randomSeed + 1}/600/400?timestamp=$timestampParam',
      'progressive':
          '$baseNetworkUrl/${_randomSeed + 2}/1200/800?timestamp=$timestampParam',
      'fade':
          '$baseNetworkUrl/${_randomSeed + 3}/600/400?timestamp=$timestampParam',
      'error':
          '$baseNetworkUrl/${_randomSeed + 4}/600/400?timestamp=$timestampParam',
      'border1':
          '$baseNetworkUrl/${_randomSeed + 10}/300/300?timestamp=$timestampParam',
      'border2':
          '$baseNetworkUrl/${_randomSeed + 11}/300/300?timestamp=$timestampParam',
      'border3':
          '$baseNetworkUrl/${_randomSeed + 12}/300/300?timestamp=$timestampParam',
      'custom':
          '$baseNetworkUrl/${_randomSeed + 20}/800/400?timestamp=$timestampParam',
      'headerImage':
          '$baseNetworkUrl/${_randomSeed + 40}/600/300?timestamp=$timestampParam',
    };

    // Pre-generate gallery grid URLs
    final List<String> galleryUrls = List.generate(
        6,
        (index) =>
            '$baseNetworkUrl/${_randomSeed + 30 + index}/300/300?timestamp=$timestampParam');

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header
        const AppText(
          'Image Sandbox',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'A comprehensive demonstration of the AppImage component and its variants',
          variant: TextVariant.bodyLarge,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 32),

        // Network Images Section
        _buildSection(
          title: 'Network Images',
          description: 'Loading images from remote URLs',
          children: [
            // Controls for demonstration
            _buildControlsRow(),
            const SizedBox(height: 16),

            // Basic Network Image
            _buildSubsection(
              title: 'Basic Network Image',
              description: 'Simple network image with border radius',
              child: _buildNetworkImageExample(imageUrls['basic']!),
            ),

            // Progressive Loading
            _buildSubsection(
              title: 'Progressive Loading',
              description: 'Shows loading progress indicator while loading',
              child: _buildProgressiveLoadingExample(imageUrls['progressive']!),
            ),

            // Fade Duration
            _buildSubsection(
              title: 'Fade-In Animation',
              description: 'Control the fade-in duration when image loads',
              child: _buildFadeDurationExample(imageUrls['fade']!),
            ),

            // Error State
            _buildSubsection(
              title: 'Error Handling',
              description: 'Shows error state when image fails to load',
              child: _buildErrorHandlingExample(_showErrorImage),
            ),
          ],
        ),

        // Asset Images Section
        _buildSection(
          title: 'Asset Images',
          description: 'Loading images from your app\'s assets',
          children: [
            _buildSubsection(
              title: 'Basic Asset Images',
              description: 'Load images from your app assets',
              child: _buildAssetImagesExample(),
            ),
            _buildSubsection(
              title: 'BoxFit Options',
              description: 'Different BoxFit options for images',
              child: _buildBoxFitExamplesAlternative(),
            ),
          ],
        ),

        // Avatar Images Section
        _buildSection(
          title: 'Avatar Images',
          description: 'Circular profile images with built-in error handling',
          children: [
            _buildSubsection(
              title: 'Avatar Sizes',
              description: 'Different sized avatars with network sources',
              child: _buildAvatarSizesExample(),
            ),
            _buildSubsection(
              title: 'Avatar Error States',
              description: 'Avatars with fallback when image fails to load',
              child: _buildAvatarErrorExample(),
            ),
            _buildSubsection(
              title: 'Asset Avatars',
              description: 'Avatars from local assets',
              child: _buildAssetAvatarsExample(),
            ),
          ],
        ),

        // Custom Styling Section
        _buildSection(
          title: 'Custom Styling',
          description: 'Advanced customization options',
          children: [
            _buildSubsection(
              title: 'Custom Border Radius',
              description: 'Apply different border radius to images',
              child: _buildCustomBorderRadiusExample(
                imageUrls['border1']!,
                imageUrls['border2']!,
                imageUrls['border3']!,
              ),
            ),
            _buildSubsection(
              title: 'Custom Loading Widget',
              description: 'Provide your own loading indicator',
              child: _buildCustomLoadingWidgetExample(imageUrls['custom']!),
            ),
            _buildSubsection(
              title: 'Custom Error Widget',
              description: 'Provide your own error state UI',
              child: _buildCustomErrorWidgetExample(),
            ),
          ],
        ),

        // Image Combinations Section
        _buildSection(
          title: 'Practical Examples',
          description: 'Real-world usage examples',
          children: [
            _buildSubsection(
              title: 'App Logo',
              description: 'Using app icon in the UI',
              child: _buildAppLogoExample(),
            ),
            _buildSubsection(
              title: 'Gallery Grid',
              description: 'Grid layout of images',
              child: _buildGalleryGridExample(galleryUrls),
            ),
            _buildSubsection(
              title: 'Card with Image',
              description: 'Image integrated in a card layout',
              child: _buildCardWithImageExample(imageUrls['headerImage']!),
            ),
          ],
        ),

        // Local File Images Section
        _buildSection(
          title: 'File Images',
          description:
              'Loading images from local file system (not shown in sandbox)',
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    'Using AppImage.file:',
                    variant: TextVariant.labelLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral[950]!.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              AppColors.neutral[500]!.withValues(alpha: 0.2)),
                    ),
                    child: AppText(
                      'AppImage.file(\n'
                      '  "/path/to/local/image.jpg",\n'
                      '  width: 300,\n'
                      '  height: 200,\n'
                      '  fit: BoxFit.cover,\n'
                      '  borderRadius: BorderRadius.circular(12),\n'
                      ')',
                      variant: TextVariant.labelMedium,
                      fontFamily: 'monospace',
                      color: AppColors.neutral[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    'Note: File images are not shown in this sandbox as they require access to the device\'s file system. In a real app, you would obtain file paths from camera captures, downloads, or other file operations.',
                    variant: TextVariant.bodySmall,
                    color: AppColors.neutral[500],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildControlsRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Button(
              text: 'Refresh Images',
              leftIcon: Icons.refresh,
              onPressed: () {
                setState(() {
                  _randomSeed = Random().nextInt(1000);
                  _refreshNetworkImages = !_refreshNetworkImages;
                  _showErrorImage = false;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Button(
              text: 'Trigger Error State',
              leftIcon: Icons.error_outline,
              variant: ButtonVariant.outlined,
              onPressed: () {
                setState(() {
                  _showErrorImage = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageExample(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage.network(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.network(\n'
            '  "https://example.com/image.jpg",\n'
            '  height: 200,\n'
            '  fit: BoxFit.cover,\n'
            '  borderRadius: BorderRadius.circular(12),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressiveLoadingExample(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage.network(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
            progressiveLoading: true,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.network(\n'
            '  "https://example.com/large-image.jpg",\n'
            '  height: 200,\n'
            '  fit: BoxFit.cover,\n'
            '  progressiveLoading: true,\n'
            '  borderRadius: BorderRadius.circular(12),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildFadeDurationExample(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Duration selector
          Row(
            children: [
              const AppText(
                'Fade Duration: ',
                variant: TextVariant.labelMedium,
                color: AppColors.neutral,
              ),
              const SizedBox(width: 8),
              DropdownButton<Duration>(
                value: _selectedFadeDuration,
                items: _fadeDurations.map((duration) {
                  final ms = duration.inMilliseconds;
                  return DropdownMenuItem<Duration>(
                    value: duration,
                    child: Text('$ms ms'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFadeDuration = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fade duration example
          AppImage.network(
            imageUrl,
            height: 200,
            fit: BoxFit.cover,
            fadeInDuration: _selectedFadeDuration,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.network(\n'
            '  "https://example.com/image.jpg",\n'
            '  fadeInDuration: Duration(milliseconds: ${_selectedFadeDuration.inMilliseconds}),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorHandlingExample(bool showError) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instead of loading a bad URL, we'll simulate an error state UI
          if (showError)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.neutral[500],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  const AppText(
                    'Failed to load image',
                    variant: TextVariant.labelLarge,
                  ),
                ],
              ),
            )
          else
            AppImage.network(
              'https://picsum.photos/seed/${_randomSeed + 100}/600/400',
              height: 200,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
            ),
          const SizedBox(height: 16),
          const AppText(
            'Default Error Handling:\n'
            'When an image fails to load, AppImage shows a default error widget.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          AppText(
            'AppImage.network(\n'
            '  "https://invalid-image-url.jpg",\n'
            '  height: 200,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetImagesExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of asset examples
          Row(
            children: [
              // App Icon example
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral[500],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppImage.asset(
                        'assets/icons/ic_app.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const AppText(
                      'App Icon',
                      variant: TextVariant.labelMedium,
                      textAlign: TextAlign.center,
                      color: AppColors.neutral,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Profile image example
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral[500],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppImage.asset(
                        'assets/images/profile.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const AppText(
                      'Profile Image',
                      variant: TextVariant.labelMedium,
                      textAlign: TextAlign.center,
                      color: AppColors.neutral,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'Using Asset Images:',
            variant: TextVariant.labelMedium,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral,
          ),
          const SizedBox(height: 8),
          AppText(
            'AppImage.asset(\n'
            '  "assets/icons/ic_app.png",\n'
            '  width: 100,\n'
            '  height: 100,\n'
            '  fit: BoxFit.contain,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
          const SizedBox(height: 16),
          AppText(
            'Note: Make sure all assets are declared in pubspec.yaml under the assets section.',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral[500],
          ),
        ],
      ),
    );
  }

  // Alternative BoxFit examples that avoid potential sizing issues
  Widget _buildBoxFitExamplesAlternative() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'BoxFit determines how the image is inscribed into its container:',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 16),

          // BoxFit descriptions
          _buildBoxFitDescription('BoxFit.cover',
              'Covers the entire container, may crop the image'),
          _buildBoxFitDescription(
              'BoxFit.contain', 'Shows the entire image within the container'),
          _buildBoxFitDescription(
              'BoxFit.fill', 'Stretches the image to fill the container'),
          _buildBoxFitDescription(
              'BoxFit.fitWidth', 'Fits the width, height may overflow'),
          _buildBoxFitDescription(
              'BoxFit.fitHeight', 'Fits the height, width may overflow'),
          _buildBoxFitDescription(
              'BoxFit.none', 'Uses the image\'s original size'),

          const SizedBox(height: 16),
          const AppText(
            'Example with BoxFit.cover:',
            variant: TextVariant.labelMedium,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),

          // Example with the app icon and BoxFit.cover
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.neutral[500],
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppImage.asset(
              'assets/icons/ic_app.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxFitDescription(String name, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: AppText(
              name,
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: AppColors.neutral,
            ),
          ),
          Expanded(
            child: AppText(
              description,
              variant: TextVariant.bodySmall,
              color: AppColors.neutral[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSizesExample() {
    // Use more stable approach for avatar examples
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatarWithLabel(30, 1),
              _buildAvatarWithLabel(48, 2),
              _buildAvatarWithLabel(64, 3),
              _buildAvatarWithLabel(80, 4),
              _buildAvatarWithLabel(100, 5),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.avatar(\n'
            '  src: "https://example.com/avatar.jpg",\n'
            '  size: 64, // Diameter of avatar circle\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithLabel(double size, int index) {
    // Use key to prevent state modifications during build
    final String url = 'https://i.pravatar.cc/300?img=$index';
    return Column(
      children: [
        AppImage.avatar(
          src: url,
          size: size,
          // Add key to ensure proper widget identity
          key: ValueKey('avatar-$size-$index'),
        ),
        const SizedBox(height: 8),
        AppText(
          '$size',
          variant: TextVariant.labelSmall,
          color: AppColors.neutral[500],
        ),
      ],
    );
  }

  Widget _buildAvatarErrorExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  AppImage.avatar(
                    src: 'https://i.pravatar.cc/300?img=10',
                    size: 80,
                    // Use unique key
                    key: const ValueKey('avatar-valid'),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Valid URL',
                    variant: TextVariant.labelSmall,
                    color: AppColors.neutral[400],
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                children: [
                  // For invalid URLs, use a pre-built error widget instead
                  // of letting the AppImage try to load and show an error
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.neutral[500],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                        height: 80,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red, size: 32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    'Invalid URL',
                    variant: TextVariant.labelSmall,
                    color: AppColors.neutral[400],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            'Avatar provides a default fallback icon when an image fails to load.',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral[500],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetAvatarsExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage.avatar(
                src: 'assets/images/profile.png',
                size: 80,
                source: ImageSource.asset,
                // Use unique key
                key: const ValueKey('avatar-asset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.avatar(\n'
            '  src: "assets/images/profile.png",\n'
            '  size: 80,\n'
            '  source: ImageSource.asset,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
          const SizedBox(height: 8),
          AppText(
            'Using a local asset for the avatar image with ImageSource.asset',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral[500],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBorderRadiusExample(
      String url1, String url2, String url3) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Different border radius styles:',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral,
          ),
          const SizedBox(height: 16),

          // Row of images with different border radii
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AppImage.network(
                      url1,
                      height: 120,
                      width: 120, // Explicitly set width to avoid NaN issues
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      // Use unique key
                      key: ValueKey('border-rounded-$url1'),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Rounded',
                      variant: TextVariant.labelSmall,
                      textAlign: TextAlign.center,
                      color: AppColors.neutral[500],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    AppImage.network(
                      url2,
                      height: 120,
                      width: 120, // Explicitly set width to avoid NaN issues
                      fit: BoxFit.cover,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      // Use unique key
                      key: ValueKey('border-custom-$url2'),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Custom Corners',
                      variant: TextVariant.labelSmall,
                      textAlign: TextAlign.center,
                      color: AppColors.neutral[500],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    AppImage.network(
                      url3,
                      height: 120,
                      width: 120, // Explicitly set width to avoid NaN issues
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(60),
                      // Use unique key
                      key: ValueKey('border-circle-$url3'),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      'Circle',
                      variant: TextVariant.labelSmall,
                      textAlign: TextAlign.center,
                      color: AppColors.neutral[500],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLoadingWidgetExample(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom loading widget example
          AppImage.network(
            imageUrl,
            height: 200,
            // Hapus width: double.infinity agar Flutter menggunakan lebar parent secara otomatis
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(12),
            // Use unique key
            key: ValueKey('custom-loading-$imageUrl'),
            loadingWidget: Container(
              width: double
                  .infinity, // di loadingWidget masih boleh, karena di sana digunakan sebagai BoxDecoration
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(height: 16),
                  AppText(
                    'Loading custom image...',
                    variant: TextVariant.labelMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.network(\n'
            '  "https://example.com/image.jpg",\n'
            '  loadingWidget: Container(\n'
            '    // Your custom loading widget\n'
            '  ),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomErrorWidgetExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated error widget without trying to load a bad URL
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.destructive.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.destructive.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 60,
                  color: AppColors.destructive.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                const AppText(
                  'Custom error: Image failed to load',
                  variant: TextVariant.labelLarge,
                  color: AppColors.destructive,
                ),
                const SizedBox(height: 8),
                Button(
                  text: 'Try Again',
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.small,
                  colors: ButtonColors(
                    border: AppColors.destructive,
                    text: AppColors.destructive,
                  ),
                  onPressed: () {
                    setState(() {
                      _refreshNetworkImages = !_refreshNetworkImages;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'AppImage.network(\n'
            '  "https://invalid-url.jpg",\n'
            '  errorWidget: Container(\n'
            '    // Your custom error widget\n'
            '  ),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
            color: AppColors.neutral[400],
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogoExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // App logo small
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppImage.asset(
                  'assets/icons/ic_app.png',
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 12),
              // Text next to logo
              const Expanded(
                child: AppText(
                  'App with Logo',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Centered larger logo
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral[950]!.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AppImage.asset(
                'assets/icons/ic_app.png',
                width: 100,
                height: 100,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            'AppImage.asset(\n'
            '  "assets/icons/ic_app.png",\n'
            '  width: 100,\n'
            '  height: 100,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGridExample(List<String> imageUrls) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery grid with fixed height items to avoid layout issues
          SizedBox(
            height: 240, // Fixed height to avoid layout issues
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppImage.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    // Use index in key to ensure unique identity
                    key: ValueKey('gallery-$index-${imageUrls[index]}'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'Grid of images using AppImage.network in GridView.builder',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral[500],
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithImageExample(String headerImageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card with image example
          Container(
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral[950]!.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: AppImage.network(
                      headerImageUrl,
                      height: 160,
                      fit: BoxFit.cover,
                      key: ValueKey('header-$headerImageUrl'),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppImage.asset(
                            'assets/icons/ic_app.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: AppText(
                              'Card Title with Image',
                              variant: TextVariant.titleMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppImage.avatar(
                            src: 'assets/images/profile.png',
                            size: 32,
                            source: ImageSource.asset,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const AppText(
                        'This is an example of a card with images - header image, app logo, and profile avatar.',
                        variant: TextVariant.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Button(
                        text: 'View Details',
                        variant: ButtonVariant.primary,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 4),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubsection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleSmall,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral[950],
        ),
        AppText(
          description,
          variant: TextVariant.bodySmall,
          color: AppColors.neutral[800],
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}
