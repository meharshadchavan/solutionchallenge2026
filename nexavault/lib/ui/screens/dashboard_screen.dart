import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/ui/widgets/bucket_grid_widget.dart';
import 'package:nexavault/ui/widgets/dropzone_widget.dart';
import 'package:nexavault/ui/widgets/eisenhower_matrix_widget.dart';
import 'package:nexavault/ui/widgets/rag_search_bar.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bgDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppConstants.backgroundGradient),
        child: Stack(
          children: [
            // Ambient background blobs
            _AmbientBlob(
              color: AppConstants.primary,
              size: 400,
              top: -100,
              left: -100,
              delay: Duration.zero,
            ),
            _AmbientBlob(
              color: AppConstants.blue,
              size: 320,
              bottom: -80,
              right: -80,
              delay: const Duration(seconds: 5),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildNavBar(),
                  // Tab bar
                  _buildTabBar(),
                  const SizedBox(height: 8),
                  // Agent search bar
                  const RagSearchBar(),
                  const SizedBox(height: 8),
                  // File upload zone
                  const DropzoneWidget(),
                  // Processing files
                  const ProcessingFilesWidget(),
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                "Resource Allocation Buckets",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            BucketGridWidget(),
                          ],
                        ),
                        const EisenhowerMatrixWidget(),
                      ],
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

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.primary, AppConstants.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: const Icon(Icons.hub_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textMain,
                  ),
                  children: [
                    TextSpan(text: 'Nexa'),
                    const WidgetSpan(
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: _greenShader,
                        child: Text(
                          'Vault',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Right: badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.primary.withValues(alpha: 0.1),
              border: Border.all(color: AppConstants.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                AnimatedGlowDot(color: AppConstants.primary),
                const SizedBox(width: 6),
                const Text(
                  'Smart Resource Allocation',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(12),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppConstants.primary, AppConstants.blue],
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppConstants.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: "Mission Buckets"),
            Tab(text: "Priority Matrix"),
          ],
        ),
      ),
    );
  }
}

// Top-level shader function (required for const WidgetSpan compatibility)
Shader _greenShader(Rect bounds) => const LinearGradient(
      colors: [AppConstants.primary, AppConstants.blue],
    ).createShader(bounds);

// Deprecated getter below — no longer used
// Shader Function(Rect) get _greenGradientShader { ... }

// ── Ambient animated blob ─────────────────────────────────────────────
class _AmbientBlob extends StatefulWidget {
  final Color color;
  final double size;
  final double? top, left, bottom, right;
  final Duration delay;

  const _AmbientBlob({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.bottom,
    this.right,
    required this.delay,
  });

  @override
  State<_AmbientBlob> createState() => _AmbientBlobState();
}

class _AmbientBlobState extends State<_AmbientBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);
    _anim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(40, -40),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      bottom: widget.bottom,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: _anim.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: 0.18),
                  widget.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
