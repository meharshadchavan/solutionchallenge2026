import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nexavault/providers/file_repository_provider.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class DropzoneWidget extends ConsumerStatefulWidget {
  const DropzoneWidget({super.key});

  @override
  ConsumerState<DropzoneWidget> createState() => _DropzoneWidgetState();
}

class _DropzoneWidgetState extends ConsumerState<DropzoneWidget>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    ref.read(fileRepositoryProvider.notifier).addNewFile(file.name, file.bytes);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: _pickFile,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: 130,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovering
                ? AppConstants.primary.withValues(alpha: 0.08)
                : AppConstants.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovering
                  ? AppConstants.primary.withValues(alpha: 0.6)
                  : AppConstants.borderColor,
              width: 1.5,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AppConstants.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConstants.primary
                          .withValues(alpha: _pulseAnim.value * 0.12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 26,
                        color: AppConstants.primary
                            .withValues(alpha: 0.6 + _pulseAnim.value * 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      AppConstants.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Tap to Upload a Resource File',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PDF, DOCX, PNG — text extracted & analyzed automatically',
                  style: TextStyle(
                    color: AppConstants.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
