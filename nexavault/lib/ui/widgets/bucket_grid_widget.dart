import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/providers/file_repository_provider.dart';
import 'package:nexavault/ui/widgets/file_card_widget.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class BucketGridWidget extends ConsumerWidget {
  const BucketGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFiles = ref.watch(fileRepositoryProvider);

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: AppConstants.missionBucketCategories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.missionBucketCategories[index];
          final accent = AppConstants.bucketColor(category);
          final icon = AppConstants.bucketIcon(category);

          final bucketFiles = allFiles.where((file) {
            if (file.isProcessing) return false;
            return file.category == category;
          }).toList();

          return _AnimatedBucketCard(
            category: category,
            accent: accent,
            icon: icon,
            files: bucketFiles,
            index: index,
          );
        },
      ),
    );
  }
}

class _AnimatedBucketCard extends StatefulWidget {
  final String category;
  final Color accent;
  final IconData icon;
  final List<dynamic> files;
  final int index;

  const _AnimatedBucketCard({
    required this.category,
    required this.accent,
    required this.icon,
    required this.files,
    required this.index,
  });

  @override
  State<_AnimatedBucketCard> createState() => _AnimatedBucketCardState();
}

class _AnimatedBucketCardState extends State<_AnimatedBucketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger entry per card index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppConstants.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with gradient accent
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(13)),
                  border: Border(
                    bottom: BorderSide(
                        color: widget.accent.withValues(alpha: 0.25), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(widget.icon,
                          size: 16,
                          color: widget.accent.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.category,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: widget.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Count bubble
                    if (widget.files.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.files.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: widget.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // File list or empty state
              Expanded(
                child: widget.files.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              color: AppConstants.textMuted.withValues(alpha: 0.4),
                              size: 24),
                          const SizedBox(height: 6),
                          Text(
                            'Empty',
                            style: TextStyle(
                              color:
                                  AppConstants.textMuted.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.files.length,
                        itemBuilder: (context, fileIndex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppConstants.bgSurface,
                              borderRadius: BorderRadius.circular(7),
                              border:
                                  Border.all(color: AppConstants.borderColor),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 12,
                                    color: widget.accent.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.files[fileIndex].name,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppConstants.textMain,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Processing files shown above the grid
class ProcessingFilesWidget extends ConsumerWidget {
  const ProcessingFilesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFiles = ref.watch(fileRepositoryProvider);
    final processingFiles =
        allFiles.where((file) => file.isProcessing).toList();

    if (processingFiles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            processingFiles.map((file) => FileCardWidget(file: file)).toList(),
      ),
    );
  }
}
