import 'package:flutter/material.dart';
import 'package:nexavault/models/file_asset.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class FileCardWidget extends StatefulWidget {
  final FileAsset file;
  const FileCardWidget({super.key, required this.file});

  @override
  State<FileCardWidget> createState() => _FileCardWidgetState();
}

class _FileCardWidgetState extends State<FileCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.file.isProcessing
                ? AppConstants.primary.withValues(alpha: 0.4)
                : AppConstants.borderColor,
          ),
          boxShadow: widget.file.isProcessing
              ? [
                  BoxShadow(
                    color: AppConstants.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppConstants.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.file.isProcessing
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primary),
                      ),
                    )
                  : const Icon(Icons.description_outlined,
                      color: AppConstants.primary, size: 20),
            ),
            const SizedBox(width: 12),
            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppConstants.textMain,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (widget.file.isProcessing)
                    Row(
                      children: [
                        const ThinkingDotsWidget(),
                        const SizedBox(width: 8),
                        const Text(
                          'Agent is reasoning…',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppConstants.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 12,
                            color: AppConstants.primary.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text(
                          widget.file.category ?? 'Allocated',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppConstants.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Confidence badge (if done)
            if (!widget.file.isProcessing && widget.file.confidence != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppConstants.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${widget.file.confidence}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
