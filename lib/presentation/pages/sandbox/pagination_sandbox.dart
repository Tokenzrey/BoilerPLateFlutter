import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/layout/pagination.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/switch.dart';
import 'package:boilerplate/core/widgets/components/forms/select.dart';

class PaginationSandbox extends StatefulWidget {
  const PaginationSandbox({super.key});

  @override
  State<PaginationSandbox> createState() => _PaginationSandboxState();
}

class _PaginationSandboxState extends State<PaginationSandbox> {
  // Global playground configuration options
  int _maxPages = 5;
  PaginationSize _size = PaginationSize.medium;
  bool _showLabels = true;
  bool _hideNextOnLastPage = false;
  bool _hidePrevOnFirstPage = false;
  bool _showSkipToFirstPage = true;
  bool _showSkipToLastPage = true;
  bool _showTotalPages = true;
  PaginationButtonType _buttonType = PaginationButtonType.ghost;
  Axis _direction = Axis.horizontal;
  bool _responsive = true;
  String? _nextLabel;
  String? _previousLabel;

  // Theme options
  bool _useDarkTheme = false;
  bool _useCustomTheme = false;
  Color _primaryColor = AppColors.primary;

  // Playground state
  int _playgroundCurrentPage = 3;
  int _playgroundTotalPages = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Pagination Sandbox',
            variant: TextVariant.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // Basic examples
            _buildBasicExamples(),
            const SizedBox(height: 32),

            // Styling examples
            _buildStylingExamples(),
            const SizedBox(height: 32),

            // Layout examples
            _buildLayoutExamples(),
            const SizedBox(height: 32),

            // Advanced examples
            _buildAdvancedExamples(),
            const SizedBox(height: 32),

            // Interactive playground
            _buildPlayground(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Pagination Component',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'Explore the various options and configurations for the Pagination component.',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[700],
        ),
      ],
    );
  }

  Widget _buildBasicExamples() {
    return _buildSection(
      'Basic Examples',
      'Default pagination variants for common use cases.',
      [
        _buildExampleCard(
          'Standard Pagination',
          'Default pagination with page numbers, previous/next buttons, and navigation to first/last pages.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Pagination(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (page) {
    // Handle page change
  },
)''',
        ),
        _buildExampleCard(
          'Simple Pagination',
          'Minimalist pagination with just page numbers and navigation buttons.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Pagination.simple(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination.simple(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (page) {
    // Handle page change
  },
)''',
        ),
        _buildExampleCard(
          'Compact Pagination',
          'Space-efficient pagination ideal for mobile views.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Pagination.compact(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination.compact(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (page) {
    // Handle page change
  },
)''',
        ),
        _buildExampleCard(
          'Pagination with Info',
          'Shows total page count alongside navigation controls.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Pagination.withInfo(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination.withInfo(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (page) {
    // Handle page change
  },
)''',
        ),
        _buildExampleCard(
          'Single Page',
          'Custom widget is displayed when there is only one page.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 1;
                final totalPages = 1;

                return Pagination(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      currentPage = page;
                    });
                  },
                  singlePageWidget: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text('Only one page available'),
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 1,
  totalPages: 1,
  onPageChanged: (page) {},
  singlePageWidget: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: const Text('Only one page available'),
  ),
)''',
        ),
      ],
    );
  }

  Widget _buildStylingExamples() {
    return _buildSection(
      'Styling & Themes',
      'Customize the appearance of pagination components.',
      [
        _buildExampleCard(
          'Button Types',
          'Different button styles: Ghost (default), Outline, and Filled.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for each pagination
                int ghostCurrentPage = 3;
                int outlineCurrentPage = 3;
                int filledCurrentPage = 3;
                final totalPages = 10;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Ghost Buttons (Default)',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: ghostCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            ghostCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Outline Buttons',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: outlineCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            outlineCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        pageButtonBuilder:
                            (context, pageNumber, isActive, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.outline,
                            size: PaginationSize.medium,
                            active: isActive,
                            theme: PaginationTheme.fromContext(context),
                            child: Text(pageNumber.toString()),
                          );
                        },
                        // Make all buttons consistent with outline style
                        previousButtonBuilder: (context, isDisabled, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.outline,
                            size: PaginationSize.medium,
                            active: false,
                            theme: PaginationTheme.fromContext(context),
                            child: const Icon(Icons.chevron_left, size: 16),
                          );
                        },
                        nextButtonBuilder: (context, isDisabled, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.outline,
                            size: PaginationSize.medium,
                            active: false,
                            theme: PaginationTheme.fromContext(context),
                            child: const Icon(Icons.chevron_right, size: 16),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Filled Buttons',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: filledCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            filledCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        pageButtonBuilder:
                            (context, pageNumber, isActive, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.filled,
                            size: PaginationSize.medium,
                            active: isActive,
                            theme: PaginationTheme.fromContext(context),
                            child: Text(pageNumber.toString()),
                          );
                        },
                        // Make all buttons consistent with filled style
                        previousButtonBuilder: (context, isDisabled, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.filled,
                            size: PaginationSize.medium,
                            active: false,
                            theme: PaginationTheme.fromContext(context),
                            child: const Icon(Icons.chevron_left, size: 16),
                          );
                        },
                        nextButtonBuilder: (context, isDisabled, onTap) {
                          return PaginationButton(
                            onPressed: onTap,
                            type: PaginationButtonType.filled,
                            size: PaginationSize.medium,
                            active: false,
                            theme: PaginationTheme.fromContext(context),
                            child: const Icon(Icons.chevron_right, size: 16),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          '''
// Ghost Buttons (Default)
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
)

// Outline Buttons
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  pageButtonBuilder: (context, pageNumber, isActive, onTap) {
    return PaginationButton(
      onPressed: onTap,
      child: Text(pageNumber.toString()),
      type: PaginationButtonType.outline,
      size: PaginationSize.medium,
      active: isActive,
      theme: PaginationTheme.fromContext(context),
    );
  },
)

// Filled Buttons
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  pageButtonBuilder: (context, pageNumber, isActive, onTap) {
    return PaginationButton(
      onPressed: onTap,
      child: Text(pageNumber.toString()),
      type: PaginationButtonType.filled,
      size: PaginationSize.medium,
      active: isActive,
      theme: PaginationTheme.fromContext(context),
    );
  },
)''',
        ),
        _buildExampleCard(
          'Button Sizes',
          'Small, Medium (default), and Large pagination buttons.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for each pagination
                int smallCurrentPage = 3;
                int mediumCurrentPage = 3;
                int largeCurrentPage = 3;
                final totalPages = 10;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Small', variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: smallCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            smallCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        size: PaginationSize.small,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Medium (Default)',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: mediumCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            mediumCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        size: PaginationSize.medium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Large', variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: largeCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            largeCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        size: PaginationSize.large,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          '''
// Small
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  size: PaginationSize.small,
)

// Medium (Default)
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  size: PaginationSize.medium,
)

// Large
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  size: PaginationSize.large,
)''',
        ),
        _buildExampleCard(
          'Custom Themes',
          'Dark theme and custom color themes for pagination.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for each pagination
                int darkThemeCurrentPage = 3;
                int customThemeCurrentPage = 3;
                final totalPages = 10;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Dark Theme', variant: TextVariant.bodySmall),
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[850],
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Builder(
                          builder: (context) => Pagination(
                            currentPage: darkThemeCurrentPage,
                            totalPages: totalPages,
                            onPageChanged: (page) {
                              setState(() {
                                darkThemeCurrentPage = page;
                              });
                            },
                            maxPages: 5,
                            showLabels: false,
                            theme: PaginationTheme.dark(context),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Custom Brand Theme',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: customThemeCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            customThemeCurrentPage = page;
                          });
                        },
                        maxPages: 5,
                        showLabels: false,
                        theme: PaginationTheme.custom(
                          primaryColor: AppColors.accent,
                          textColor: AppColors.neutral[800]!,
                          backgroundColor: AppColors.neutral[50]!,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          '''
// Dark Theme
Container(
  color: Colors.grey[850],
  child: Pagination(
    currentPage: 3,
    totalPages: 10,
    onPageChanged: (_) {},
    theme: PaginationTheme.dark(context),
  ),
)

// Custom Brand Theme
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  theme: PaginationTheme.custom(
    primaryColor: AppColors.accent,
    textColor: AppColors.neutral[800]!,
    backgroundColor: AppColors.neutral[50]!,
    borderRadius: BorderRadius.circular(8),
  ),
)''',
        ),
      ],
    );
  }

  Widget _buildLayoutExamples() {
    return _buildSection(
      'Layout Options',
      'Control the layout and direction of pagination components.',
      [
        _buildExampleCard(
          'Horizontal Layout',
          'Default layout direction with buttons arranged horizontally.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Pagination(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    direction: Axis.horizontal,
                    maxPages: 5,
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  direction: Axis.horizontal, // Default
  maxPages: 5,
)''',
        ),
        _buildExampleCard(
          'Vertical Layout',
          'Stack pagination buttons vertically.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SizedBox(
                  width: 200,
                  child: Pagination(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    direction: Axis.vertical,
                    maxPages: 5,
                    showLabels: false,
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  direction: Axis.vertical,
  maxPages: 5,
  showLabels: false,
)''',
        ),
        _buildExampleCard(
          'Container Styling',
          'Add background, padding, and borders to the pagination container.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Pagination(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      containerDecoration: BoxDecoration(
                        color: AppColors.neutral[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.neutral[300]!),
                      ),
                      padding: const EdgeInsets.all(16),
                      itemSpacing: 12,
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  containerDecoration: BoxDecoration(
    color: AppColors.neutral[100],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.neutral[300]!),
  ),
  padding: const EdgeInsets.all(16),
  itemSpacing: 12,
)''',
        ),
        _buildExampleCard(
          'Responsive Behavior',
          'Adjusts layout based on available space.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for each pagination
                int fullSizeCurrentPage = 3;
                int constrainedCurrentPage = 3;
                final totalPages = 10;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Full Size', variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Pagination(
                        currentPage: fullSizeCurrentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) {
                          setState(() {
                            fullSizeCurrentPage = page;
                          });
                        },
                        responsive: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AppText('Constrained Width',
                        variant: TextVariant.bodySmall),
                    const SizedBox(height: 8),
                    Container(
                      width: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neutral[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Pagination(
                          currentPage: constrainedCurrentPage,
                          totalPages: totalPages,
                          onPageChanged: (page) {
                            setState(() {
                              constrainedCurrentPage = page;
                            });
                          },
                          responsive: true,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          '''
// Full Width
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  responsive: true, // Default
)

// Constrained Width
Container(
  width: 250,
  child: Pagination(
    currentPage: 3, 
    totalPages: 10,
    onPageChanged: (_) {},
    responsive: true,
  ),
)''',
        ),
      ],
    );
  }

  Widget _buildAdvancedExamples() {
    return _buildSection(
      'Advanced Features',
      'Explore custom button builders and advanced pagination features.',
      [
        _buildExampleCard(
          'Custom Button Styling',
          'Use custom button builders to create unique pagination styles.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Semantics(
                    container: true,
                    label: 'Custom styled pagination',
                    child: Pagination(
                      currentPage: currentPage,
                      totalPages: totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      maxPages: 5,
                      pageButtonBuilder:
                          (context, pageNumber, isActive, onTap) {
                        return Semantics(
                          button: true,
                          label:
                              'Page $pageNumber ${isActive ? '(current)' : ''}',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Material(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: onTap,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    pageNumber.toString(),
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : AppColors.neutral[800],
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      previousButtonBuilder: (context, isDisabled, onTap) {
                        return Semantics(
                          button: true,
                          label: 'Previous page',
                          enabled: !isDisabled,
                          child: IconButton(
                            onPressed: onTap,
                            icon: const Icon(Icons.arrow_back),
                            color: isDisabled
                                ? AppColors.neutral[400]
                                : AppColors.primary,
                          ),
                        );
                      },
                      nextButtonBuilder: (context, isDisabled, onTap) {
                        return Semantics(
                          button: true,
                          label: 'Next page',
                          enabled: !isDisabled,
                          child: IconButton(
                            onPressed: onTap,
                            icon: const Icon(Icons.arrow_forward),
                            color: isDisabled
                                ? AppColors.neutral[400]
                                : AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  maxPages: 5,
  pageButtonBuilder: (context, pageNumber, isActive, onTap) {
    return Material(
      color: isActive ? AppColors.primary : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.neutral[800],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  },
  previousButtonBuilder: (context, isDisabled, onTap) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back),
      color: isDisabled ? AppColors.neutral[400] : AppColors.primary,
    );
  },
  nextButtonBuilder: (context, isDisabled, onTap) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.arrow_forward),
      color: isDisabled ? AppColors.neutral[400] : AppColors.primary,
    );
  },
)''',
        ),
        _buildExampleCard(
          'Custom Total Pages Display',
          'Customize the "of X pages" display.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 3;
                final totalPages = 10;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Pagination(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    showTotalPages: true,
                    totalPagesBuilder: (context, currentPage, totalPages) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Page $currentPage of $totalPages',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 3,
  totalPages: 10,
  onPageChanged: (_) {},
  showTotalPages: true,
  totalPagesBuilder: (context, currentPage, totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Page \$currentPage of \$totalPages',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  },
)''',
        ),
        _buildExampleCard(
          'Custom Ellipsis',
          'Replace the default ellipsis with custom design.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 5;
                final totalPages = 20;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Pagination(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    maxPages: 5,
                    ellipsisBuilder: (context) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 5,
  totalPages: 20,
  onPageChanged: (_) {},
  maxPages: 5,
  ellipsisBuilder: (context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  },
)''',
        ),
        _buildExampleCard(
          'First/Last Page Controls',
          'Customize navigation to first and last pages.',
          (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                // Local state for this example
                int currentPage = 5;
                final totalPages = 20;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Pagination(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    maxPages: 5,
                    showSkipToFirstPage: true,
                    showSkipToLastPage: true,
                    firstPageButtonBuilder: (context, isDisabled, onTap) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Tooltip(
                          message: 'Go to first page',
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.first_page,
                                color: isDisabled
                                    ? AppColors.neutral[400]
                                    : AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    lastPageButtonBuilder: (context, isDisabled, onTap) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Tooltip(
                          message: 'Go to last page',
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.last_page,
                                color: isDisabled
                                    ? AppColors.neutral[400]
                                    : AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          '''
Pagination(
  currentPage: 5,
  totalPages: 20,
  onPageChanged: (_) {},
  maxPages: 5,
  showSkipToFirstPage: true,
  showSkipToLastPage: true,
  firstPageButtonBuilder: (context, isDisabled, onTap) {
    return Tooltip(
      message: 'Go to first page',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.first_page,
            color: isDisabled ? AppColors.neutral[400] : AppColors.primary,
          ),
        ),
      ),
    );
  },
  lastPageButtonBuilder: (context, isDisabled, onTap) {
    return Tooltip(
      message: 'Go to last page',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.last_page,
            color: isDisabled ? AppColors.neutral[400] : AppColors.primary,
          ),
        ),
      ),
    );
  },
)''',
        ),
      ],
    );
  }

  Widget _buildPlayground() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Interactive Playground',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        AppText(
          'Experiment with different pagination configurations in real-time.',
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral[700],
        ),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildControls(),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: _buildConfiguredPagination(),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.neutral[900],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AppText(
                    _generatePlaygroundCode(),
                    variant: TextVariant.bodySmall,
                    color: AppColors.neutral[200],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Configuration Controls',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Current Page', variant: TextVariant.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _playgroundCurrentPage.toDouble(),
                          min: 1,
                          max: _playgroundTotalPages.toDouble(),
                          divisions: _playgroundTotalPages - 1,
                          label: _playgroundCurrentPage.toString(),
                          onChanged: (value) {
                            setState(() {
                              _playgroundCurrentPage = value.toInt();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(_playgroundCurrentPage.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Total Pages', variant: TextVariant.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _playgroundTotalPages.toDouble(),
                          min: 1,
                          max: 20,
                          divisions: 19,
                          label: _playgroundTotalPages.toString(),
                          onChanged: (value) {
                            setState(() {
                              int newTotal = value.toInt();
                              if (_playgroundCurrentPage > newTotal) {
                                // Adjust current page if total pages reduced
                                _playgroundCurrentPage = newTotal;
                              }
                              _playgroundTotalPages = newTotal;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(_playgroundTotalPages.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<int>(
                label: 'Max Visible Pages',
                initialValue: _maxPages,
                options: [
                  const SelectOption<int>(value: 3, label: '3'),
                  const SelectOption<int>(value: 5, label: '5'),
                  const SelectOption<int>(value: 7, label: '7'),
                  const SelectOption<int>(value: 9, label: '9'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _maxPages = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<PaginationSize>(
                label: 'Size',
                initialValue: _size,
                options: [
                  const SelectOption<PaginationSize>(
                    value: PaginationSize.small,
                    label: 'Small',
                  ),
                  const SelectOption<PaginationSize>(
                    value: PaginationSize.medium,
                    label: 'Medium',
                  ),
                  const SelectOption<PaginationSize>(
                    value: PaginationSize.large,
                    label: 'Large',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _size = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<PaginationButtonType>(
                label: 'Button Type',
                initialValue: _buttonType,
                options: [
                  const SelectOption<PaginationButtonType>(
                    value: PaginationButtonType.ghost,
                    label: 'Ghost',
                  ),
                  const SelectOption<PaginationButtonType>(
                    value: PaginationButtonType.outline,
                    label: 'Outline',
                  ),
                  const SelectOption<PaginationButtonType>(
                    value: PaginationButtonType.filled,
                    label: 'Filled',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _buttonType = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Show Text Labels',
                value: _showLabels,
                onChanged: (value) {
                  setState(() {
                    _showLabels = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Hide Next on Last Page',
                value: _hideNextOnLastPage,
                onChanged: (value) {
                  setState(() {
                    _hideNextOnLastPage = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Hide Prev on First Page',
                value: _hidePrevOnFirstPage,
                onChanged: (value) {
                  setState(() {
                    _hidePrevOnFirstPage = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Show First Page Button',
                value: _showSkipToFirstPage,
                onChanged: (value) {
                  setState(() {
                    _showSkipToFirstPage = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Show Last Page Button',
                value: _showSkipToLastPage,
                onChanged: (value) {
                  setState(() {
                    _showSkipToLastPage = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Show Total Pages',
                value: _showTotalPages,
                onChanged: (value) {
                  setState(() {
                    _showTotalPages = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Vertical Layout',
                value: _direction == Axis.vertical,
                onChanged: (value) {
                  setState(() {
                    _direction = value ? Axis.vertical : Axis.horizontal;
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Responsive',
                value: _responsive,
                onChanged: (value) {
                  setState(() {
                    _responsive = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Use Dark Theme',
                value: _useDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _useDarkTheme = value;
                    if (value) {
                      _useCustomTheme = false;
                    }
                  });
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: SwitchInputWidget(
                label: 'Use Custom Theme',
                value: _useCustomTheme,
                onChanged: (value) {
                  setState(() {
                    _useCustomTheme = value;
                    if (value) {
                      _useDarkTheme = false;
                    }
                  });
                },
              ),
            ),
            if (_useCustomTheme)
              SizedBox(
                width: 180,
                child: FormSelectField<Color>(
                  label: 'Primary Color',
                  initialValue: _primaryColor,
                  options: [
                    SelectOption<Color>(
                        value: AppColors.primary, label: 'Primary'),
                    SelectOption<Color>(
                        value: AppColors.secondary, label: 'Secondary'),
                    SelectOption<Color>(
                        value: AppColors.accent, label: 'Accent'),
                    SelectOption<Color>(
                        value: AppColors.success, label: 'Success'),
                    SelectOption<Color>(
                        value: AppColors.destructive, label: 'Destructive'),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _primaryColor = value;
                      });
                    }
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfiguredPagination() {
    // Get the theme based on current selections
    PaginationTheme? theme = _getSelectedTheme(context);

    // Create custom button builders based on button type
    Widget Function(BuildContext, int, bool, VoidCallback?)? pageButtonBuilder;
    Widget Function(BuildContext, bool, VoidCallback?)? previousButtonBuilder;
    Widget Function(BuildContext, bool, VoidCallback?)? nextButtonBuilder;
    Widget Function(BuildContext, bool, VoidCallback?)? firstPageButtonBuilder;
    Widget Function(BuildContext, bool, VoidCallback?)? lastPageButtonBuilder;

    // Apply button type consistently to all buttons
    if (_buttonType != PaginationButtonType.ghost) {
      pageButtonBuilder = (context, pageNumber, isActive, onTap) {
        return PaginationButton(
          onPressed: onTap,
          type: _buttonType,
          size: _size,
          active: isActive,
          theme: theme ?? PaginationTheme.fromContext(context),
          child: Text(pageNumber.toString()),
        );
      };

      previousButtonBuilder = (context, isDisabled, onTap) {
        return PaginationButton(
          onPressed: onTap,
          type: _buttonType,
          size: _size,
          theme: theme ?? PaginationTheme.fromContext(context),
          child: _showLabels
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, size: 16),
                    const SizedBox(width: 4),
                    Text(_previousLabel ?? "Previous"),
                  ],
                )
              : const Icon(Icons.chevron_left),
        );
      };

      nextButtonBuilder = (context, isDisabled, onTap) {
        return PaginationButton(
          onPressed: onTap,
          type: _buttonType,
          size: _size,
          theme: theme ?? PaginationTheme.fromContext(context),
          child: _showLabels
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_nextLabel ?? "Next"),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                )
              : const Icon(Icons.chevron_right),
        );
      };

      firstPageButtonBuilder = (context, isDisabled, onTap) {
        return PaginationButton(
          onPressed: onTap,
          type: _buttonType,
          size: _size,
          theme: theme ?? PaginationTheme.fromContext(context),
          child: const Icon(Icons.first_page, size: 16),
        );
      };

      lastPageButtonBuilder = (context, isDisabled, onTap) {
        return PaginationButton(
          onPressed: onTap,
          type: _buttonType,
          size: _size,
          theme: theme ?? PaginationTheme.fromContext(context),
          child: const Icon(Icons.last_page, size: 16),
        );
      };
    }

    // Build the pagination with all configured options
    Widget pagination = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Pagination(
        currentPage: _playgroundCurrentPage,
        totalPages: _playgroundTotalPages,
        onPageChanged: (page) {
          setState(() {
            _playgroundCurrentPage = page;
          });
        },
        maxPages: _maxPages,
        showLabels: _showLabels,
        hideNextOnLastPage: _hideNextOnLastPage,
        hidePrevOnFirstPage: _hidePrevOnFirstPage,
        showSkipToFirstPage: _showSkipToFirstPage,
        showSkipToLastPage: _showSkipToLastPage,
        showTotalPages: _showTotalPages,
        size: _size,
        direction: _direction,
        responsive: _responsive,
        nextLabel: _nextLabel,
        previousLabel: _previousLabel,
        theme: theme,
        pageButtonBuilder: pageButtonBuilder,
        previousButtonBuilder: previousButtonBuilder,
        nextButtonBuilder: nextButtonBuilder,
        firstPageButtonBuilder: firstPageButtonBuilder,
        lastPageButtonBuilder: lastPageButtonBuilder,
      ),
    );

    // If using dark theme, wrap in a dark container
    if (_useDarkTheme) {
      pagination = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
        ),
        child: pagination,
      );
    }

    return pagination;
  }

  PaginationTheme? _getSelectedTheme(BuildContext context) {
    if (_useDarkTheme) {
      return PaginationTheme.dark(context);
    }

    if (_useCustomTheme) {
      return PaginationTheme.custom(
        primaryColor: _primaryColor,
        textColor: AppColors.neutral[800]!,
        backgroundColor: AppColors.neutral[50]!,
      );
    }

    return null; // Use default theme
  }

  String _generatePlaygroundCode() {
    final StringBuffer code = StringBuffer();

    code.writeln('Pagination(');
    code.writeln('  currentPage: $_playgroundCurrentPage,');
    code.writeln('  totalPages: $_playgroundTotalPages,');
    code.writeln('  onPageChanged: (page) {');
    code.writeln('    // Handle page change');
    code.writeln('  },');

    if (_maxPages != 5) {
      code.writeln('  maxPages: $_maxPages,');
    }

    if (!_showLabels) {
      code.writeln('  showLabels: false,');
    }

    if (_hideNextOnLastPage) {
      code.writeln('  hideNextOnLastPage: true,');
    }

    if (_hidePrevOnFirstPage) {
      code.writeln('  hidePrevOnFirstPage: true,');
    }

    if (!_showSkipToFirstPage) {
      code.writeln('  showSkipToFirstPage: false,');
    }

    if (!_showSkipToLastPage) {
      code.writeln('  showSkipToLastPage: false,');
    }

    if (_showTotalPages) {
      code.writeln('  showTotalPages: true,');
    }

    if (_size != PaginationSize.medium) {
      code.writeln(
          '  size: PaginationSize.${_size.toString().split('.').last},');
    }

    if (_direction != Axis.horizontal) {
      code.writeln('  direction: Axis.vertical,');
    }

    if (!_responsive) {
      code.writeln('  responsive: false,');
    }

    if (_buttonType != PaginationButtonType.ghost) {
      code.writeln(
          '  pageButtonBuilder: (context, pageNumber, isActive, onTap) {');
      code.writeln('    return PaginationButton(');
      code.writeln('      onPressed: onTap,');
      code.writeln('      child: Text(pageNumber.toString()),');
      code.writeln(
          '      type: PaginationButtonType.${_buttonType.toString().split('.').last},');
      code.writeln(
          '      size: PaginationSize.${_size.toString().split('.').last},');
      code.writeln('      active: isActive,');

      if (_useDarkTheme) {
        code.writeln('      theme: PaginationTheme.dark(context),');
      } else if (_useCustomTheme) {
        code.writeln('      theme: PaginationTheme.custom(');
        code.writeln(
            '        primaryColor: AppColors.${_getPrimaryColorName()},');
        code.writeln('        textColor: AppColors.neutral[800]!,');
        code.writeln('        backgroundColor: AppColors.neutral[50]!,');
        code.writeln('      ),');
      } else {
        code.writeln('      theme: PaginationTheme.fromContext(context),');
      }

      code.writeln('    );');
      code.writeln('  },');
    }

    if (_useDarkTheme) {
      code.writeln('  theme: PaginationTheme.dark(context),');
    } else if (_useCustomTheme) {
      code.writeln('  theme: PaginationTheme.custom(');
      code.writeln('    primaryColor: AppColors.${_getPrimaryColorName()},');
      code.writeln('    textColor: AppColors.neutral[800]!,');
      code.writeln('    backgroundColor: AppColors.neutral[50]!,');
      code.writeln('  ),');
    }

    code.writeln(')');

    return code.toString();
  }

  String _getPrimaryColorName() {
    if (_primaryColor == AppColors.primary) return 'primary';
    if (_primaryColor == AppColors.secondary) return 'secondary';
    if (_primaryColor == AppColors.accent) return 'accent';
    if (_primaryColor == AppColors.success) return 'success';
    if (_primaryColor == AppColors.destructive) return 'destructive';
    return 'primary';
  }

  Widget _buildSection(
      String title, String description, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral[700],
        ),
        const SizedBox(height: 16),
        ...examples,
      ],
    );
  }

  Widget _buildExampleCard(
    String title,
    String description,
    Widget Function(BuildContext) contentBuilder,
    String codeSnippet,
  ) {
    return _buildCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                AppText(
                  description,
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral[600],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.neutral[50],
            child: Center(child: contentBuilder(context)),
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.neutral[900],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AppText(
                codeSnippet,
                variant: TextVariant.bodySmall,
                color: AppColors.neutral[200],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
