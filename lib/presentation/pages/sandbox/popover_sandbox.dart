import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';

class PopoverSandbox extends StatefulWidget {
  const PopoverSandbox({super.key});

  @override
  State<PopoverSandbox> createState() => _PopoverSandboxState();
}

class _PopoverSandboxState extends State<PopoverSandbox> {
  final PopoverController _controller = PopoverController();
  final GlobalKey _fixedKey = GlobalKey();
  final GlobalKey _followKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();

  String _selectedOption = 'None';
  bool _isFollowing = true;
  PopoverConstraint _widthConstraint = PopoverConstraint.flexible;
  PopoverConstraint _heightConstraint = PopoverConstraint.flexible;
  bool _allowInvertHorizontal = true;
  bool _allowInvertVertical = true;
  bool _isModal = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Popover Sandbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoPopover,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Basic Popover Positioning',
              child: _buildPositioningDemo(),
            ),
            _buildSection(
              title: 'Popover Constraints',
              child: _buildConstraintsDemo(),
            ),
            _buildSection(
              title: 'Interactive Behavior',
              child: _buildInteractiveBehaviorDemo(),
            ),
            _buildSection(
              title: 'Advanced Features',
              child: _buildAdvancedFeaturesDemo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPositioningDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tap buttons to show popovers with different anchoring:'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _positionButton(
              'Top',
              alignment: Alignment.topCenter,
              anchorAlignment: Alignment.bottomCenter,
              offset: const Offset(0, -8),
            ),
            _positionButton(
              'Bottom',
              alignment: Alignment.bottomCenter,
              anchorAlignment: Alignment.topCenter,
              offset: const Offset(0, 8),
            ),
            _positionButton(
              'Left',
              alignment: Alignment.centerLeft,
              anchorAlignment: Alignment.centerRight,
              offset: const Offset(-8, 0),
            ),
            _positionButton(
              'Right',
              alignment: Alignment.centerRight,
              anchorAlignment: Alignment.centerLeft,
              offset: const Offset(8, 0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _positionButton(
              'Top-Left',
              alignment: Alignment.topLeft,
              anchorAlignment: Alignment.bottomRight,
              offset: const Offset(-8, -8),
            ),
            _positionButton(
              'Top-Right',
              alignment: Alignment.topRight,
              anchorAlignment: Alignment.bottomLeft,
              offset: const Offset(8, -8),
            ),
            _positionButton(
              'Bottom-Left',
              alignment: Alignment.bottomLeft,
              anchorAlignment: Alignment.topRight,
              offset: const Offset(-8, 8),
            ),
            _positionButton(
              'Bottom-Right',
              alignment: Alignment.bottomRight,
              anchorAlignment: Alignment.topLeft,
              offset: const Offset(8, 8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _positionButton(
    String label, {
    required AlignmentGeometry alignment,
    required AlignmentGeometry anchorAlignment,
    required Offset offset,
  }) {
    return Builder(
      builder: (buttonContext) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        onPressed: () {
          showPopover(
            context: buttonContext,
            alignment: alignment,
            anchorAlignment: anchorAlignment,
            offset: offset,
            builder: (_) => _buildSimplePopoverContent('$label Popover'),
          );
        },
        child: Text(label),
      ),
    );
  }

  Widget _buildConstraintsDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Experiment with different constraint types:'),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Width Constraint: '),
            const SizedBox(width: 8),
            DropdownButton<PopoverConstraint>(
              value: _widthConstraint,
              onChanged: (value) => setState(() => _widthConstraint = value!),
              items: PopoverConstraint.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.toString().split('.').last),
                      ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Height Constraint: '),
            const SizedBox(width: 8),
            DropdownButton<PopoverConstraint>(
              value: _heightConstraint,
              onChanged: (value) => setState(() => _heightConstraint = value!),
              items: PopoverConstraint.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.toString().split('.').last),
                      ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            key: _fixedKey,
            onPressed: _showConstrainedPopover,
            child: const Text('Show Constrained Popover'),
          ),
        ),
      ],
    );
  }

  void _showConstrainedPopover() {
    final fixedSize = (_widthConstraint == PopoverConstraint.fixed ||
            _heightConstraint == PopoverConstraint.fixed)
        ? Size(
            _widthConstraint == PopoverConstraint.fixed ? 200 : double.nan,
            _heightConstraint == PopoverConstraint.fixed ? 200 : double.nan,
          )
        : null;

    showPopover(
      context: _fixedKey.currentContext!,
      alignment: Alignment.topCenter,
      anchorAlignment: Alignment.bottomCenter,
      widthConstraint: _widthConstraint,
      heightConstraint: _heightConstraint,
      offset: const Offset(0, 12),
      fixedSize: fixedSize,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Width: ${_widthConstraint.toString().split('.').last}'),
            const SizedBox(height: 8),
            Text('Height: ${_heightConstraint.toString().split('.').last}'),
            const SizedBox(height: 16),
            const Text('This content demonstrates the selected constraints.'),
            if (_widthConstraint == PopoverConstraint.contentSize ||
                _heightConstraint == PopoverConstraint.contentSize)
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 300,
                height: 150,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Text('Content with specific size'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveBehaviorDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interactive behavior settings:'),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Modal (with backdrop)'),
          subtitle: const Text('Controls whether popover has a barrier'),
          value: _isModal,
          onChanged: (value) => setState(() => _isModal = value),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Follow anchor'),
          subtitle: const Text('Popover follows anchor when it moves'),
          value: _isFollowing,
          onChanged: (value) => setState(() => _isFollowing = value),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Allow horizontal flip'),
          subtitle: const Text('Flip horizontally at screen edges'),
          value: _allowInvertHorizontal,
          onChanged: (value) => setState(() => _allowInvertHorizontal = value),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Allow vertical flip'),
          subtitle: const Text('Flip vertically at screen edges'),
          value: _allowInvertVertical,
          onChanged: (value) => setState(() => _allowInvertVertical = value),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 16),
        Center(
          child: CompositedTransformTarget(
            link: _layerLink,
            child: ElevatedButton(
              key: _followKey,
              onPressed: _showInteractivePopover,
              child: const Text('Show Interactive Popover'),
            ),
          ),
        ),
      ],
    );
  }

  void _showInteractivePopover() {
    showPopover(
      context: _followKey.currentContext!,
      alignment: Alignment.topCenter,
      anchorAlignment: Alignment.bottomCenter,
      modal: _isModal,
      follow: _isFollowing,
      allowInvertHorizontal: _allowInvertHorizontal,
      allowInvertVertical: _allowInvertVertical,
      layerLink: _isFollowing ? _layerLink : null,
      offset: const Offset(0, 12),
      builder: (_) => _buildSimplePopoverContent(
        'Interactive Popover',
        details: [
          'Modal: ${_isModal ? 'Yes' : 'No'}',
          'Follow: ${_isFollowing ? 'Yes' : 'No'}',
          'H-Flip: ${_allowInvertHorizontal ? 'Yes' : 'No'}',
          'V-Flip: ${_allowInvertVertical ? 'Yes' : 'No'}',
        ],
      ),
    );
  }

  Widget _buildAdvancedFeaturesDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _showWithResultPopover,
              child: const Text('Popover with Result'),
            ),
            ElevatedButton(
              onPressed: _showAnimatedPopover,
              child: const Text('Custom Animation'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _showNestedPopover,
              child: const Text('Nested Popovers'),
            ),
            ElevatedButton(
              onPressed: _showControllerPopover,
              child: const Text('Controller Demo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Selected option: $_selectedOption',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Future<void> _showWithResultPopover() async {
    final completer = showPopover<String>(
      context: context,
      position: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 3,
      ),
      alignment: Alignment.center,
      builder: (context) => Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select an option:'),
            ),
            const Divider(height: 0),
            _optionButton(context, 'Option A'),
            const Divider(height: 0),
            _optionButton(context, 'Option B'),
            const Divider(height: 0),
            _optionButton(context, 'Option C'),
          ],
        ),
      ),
    );

    final result = await completer.future;

    if (result != null) {
      setState(() => _selectedOption = result);
    }
  }

  Widget _optionButton(BuildContext context, String option) {
    return InkWell(
      onTap: () => closeOverlay(context, option),
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(option),
      ),
    );
  }

  void _showAnimatedPopover() {
    showPopover(
      context: context,
      position: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      alignment: Alignment.center,
      showDuration: const Duration(milliseconds: 500),
      dismissDuration: const Duration(milliseconds: 300),
      transitionAlignment: Alignment.topCenter,
      builder: (_) => Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.animation, size: 48, color: Colors.deepPurple),
              SizedBox(height: 16),
              Text(
                'Custom Animation Popover',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This popover uses custom animation durations\nand transition alignment.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNestedPopover() {
    showPopover(
      context: context,
      position: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      alignment: Alignment.center,
      builder: (outerContext) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This is the outer popover'),
              const SizedBox(height: 16),
              Builder(
                builder: (nestedContext) => ElevatedButton(
                  onPressed: () {
                    showPopover(
                      context: nestedContext,
                      alignment: Alignment.topCenter,
                      anchorAlignment: Alignment.bottomCenter,
                      offset: const Offset(0, 8),
                      builder: (_) => Card(
                        color: Colors.amber.shade50,
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('This is a nested popover!'),
                        ),
                      ),
                    );
                  },
                  child: const Text('Show nested popover'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showControllerPopover() {
    _controller.show(
      context: context,
      offset: Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      alignment: Alignment.center,
      builder: (_) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Controller Demo'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _controller.alignment = Alignment.centerLeft;
                    },
                    child: const Text('Left'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _controller.alignment = Alignment.center;
                    },
                    child: const Text('Center'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _controller.alignment = Alignment.centerRight;
                    },
                    child: const Text('Right'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _controller.close(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoPopover() {
    final width = MediaQuery.of(context).size.width;

    showPopover(
      context: context,
      position: Offset(width - 30, kToolbarHeight / 2),
      alignment: Alignment.topRight,
      widthConstraint: PopoverConstraint.fixed,
      heightConstraint: PopoverConstraint.flexible,
      fixedSize: Size(width * 0.8, double.nan),
      builder: (_) => Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Popover System Sandbox',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'This sandbox demonstrates the various features of the popover system:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              _FeatureItem('• Different positioning and alignment options'),
              _FeatureItem(
                  '• Various size constraints (flexible, fixed, content-based)'),
              _FeatureItem('• Modal vs non-modal popovers'),
              _FeatureItem('• Follow behavior with anchor tracking'),
              _FeatureItem('• Screen edge detection with inversion'),
              _FeatureItem('• Custom animation and durations'),
              _FeatureItem('• Result handling with futures'),
              _FeatureItem('• Nested popovers for complex UIs'),
              _FeatureItem('• PopoverController for advanced control'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplePopoverContent(String title, {List<String>? details}) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (details != null) ...[
              const SizedBox(height: 8),
              ...details.map((detail) => Text(detail)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }
}
