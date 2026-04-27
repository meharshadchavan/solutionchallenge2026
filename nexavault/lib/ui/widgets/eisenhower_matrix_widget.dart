import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/models/file_asset.dart';
import 'package:nexavault/providers/file_repository_provider.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class EisenhowerMatrixWidget extends ConsumerWidget {
  const EisenhowerMatrixWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFiles = ref.watch(fileRepositoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    AppConstants.primaryGradient.createShader(bounds),
                child: const Text(
                  'Agentic Priority Matrix',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Documents are auto-routed by urgency × importance',
            style: TextStyle(color: AppConstants.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 480,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxSize = constraints.maxWidth / 2 - 6;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuadrant(
                            'Do First',
                            'Urgent & Important',
                            const Color(0xFFEF4444),
                            allFiles
                                .where((f) =>
                                    f.quadrant ==
                                    EisenhowerQuadrant.urgentImportant)
                                .toList(),
                            boxSize),
                        _buildQuadrant(
                            'Schedule',
                            'Not Urgent & Important',
                            const Color(0xFF3B82F6),
                            allFiles
                                .where((f) =>
                                    f.quadrant ==
                                    EisenhowerQuadrant.notUrgentImportant)
                                .toList(),
                            boxSize),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuadrant(
                            'Delegate',
                            'Urgent & Not Important',
                            const Color(0xFFF59E0B),
                            allFiles
                                .where((f) =>
                                    f.quadrant ==
                                    EisenhowerQuadrant.urgentNotImportant)
                                .toList(),
                            boxSize),
                        _buildQuadrant(
                            'Eliminate',
                            'Not Urgent & Not Important',
                            const Color(0xFF64748B),
                            allFiles
                                .where((f) =>
                                    f.quadrant ==
                                    EisenhowerQuadrant.notUrgentNotImportant)
                                .toList(),
                            boxSize),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuadrant(String title, String subtitle, Color accent,
      List<FileAsset> files, double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1)
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: accent,
                  ),
                ),
              ),
              if (files.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${files.length}',
                    style: TextStyle(
                        fontSize: 10,
                        color: accent,
                        fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 9,
                color: AppConstants.textMuted),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 1,
            color: AppConstants.borderColor,
          ),
          Expanded(
            child: files.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: ShimmerBox(
                          width: double.infinity,
                          height: 20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_right,
                                size: 12,
                                color: accent.withValues(alpha: 0.7)),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                files[index].name,
                                style: const TextStyle(
                                  fontSize: 10,
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
    );
  }
}
