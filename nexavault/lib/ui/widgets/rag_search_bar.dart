import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nexavault/providers/agentic_provider.dart';
import 'package:nexavault/providers/file_repository_provider.dart';
import 'package:nexavault/ui/widgets/shared_widgets.dart';
import 'package:nexavault/utils/constants.dart';

class RagSearchBar extends ConsumerStatefulWidget {
  const RagSearchBar({super.key});

  @override
  ConsumerState<RagSearchBar> createState() => _RagSearchBarState();
}

class _RagSearchBarState extends ConsumerState<RagSearchBar> {
  final TextEditingController _controller = TextEditingController();
  String _agentResponse = "";
  bool _isSearching = false;

  bool get _useLocalLlm =>
      dotenv.env['USE_LOCAL_AGENT']?.toLowerCase() == 'true';

  Future<void> _performSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _agentResponse = "";
    });

    try {
      String response;
      if (_useLocalLlm) {
        response = await _queryLocalLlm(query);
      } else {
        final allFiles = ref.read(fileRepositoryProvider);
        final agentService = ref.read(agenticServiceProvider);
        response = await agentService.searchAndQuery(query, allFiles);
      }
      setState(() {
        _agentResponse = response;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _agentResponse = "Agent encountered an error: $e";
        _isSearching = false;
      });
    }
  }

  Future<String> _queryLocalLlm(String userQuery) async {
    final allFiles = ref.read(fileRepositoryProvider);
    final ctxText = allFiles
        .where((f) => !f.isProcessing && f.snippet != null)
        .map((f) =>
            "File: ${f.name}\nCategory: ${f.category}\nSnippet: ${f.snippet}")
        .join("\n\n---\n\n");

    final localUrl = dotenv.env['LOCAL_LLM_URL'] ??
        'http://192.168.1.142:1234/v1/chat/completions';

    final body = jsonEncode({
      "model": "gemma-4",
      "messages": [
        {
          "role": "system",
          "content":
              "You are NexaVault's AI assistant. Use the following uploaded documents as context:\n\n$ctxText"
        },
        {"role": "user", "content": userQuery}
      ],
      "temperature": 0.7,
      "max_tokens": 300,
    });

    final res = await http
        .post(
          Uri.parse(localUrl),
          headers: {"Content-Type": "application/json"},
          body: body,
        )
        .timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['choices'][0]['message']['content'] as String;
    }
    throw Exception("Local LLM returned status ${res.statusCode}");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      AppConstants.primaryGradient.createShader(bounds),
                  child: Icon(
                    _useLocalLlm ? Icons.offline_bolt : Icons.psychology,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(
                        color: AppConstants.textMain, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _useLocalLlm
                          ? "Ask Gemma (offline)…"
                          : "Ask Agent about your resources…",
                      hintStyle: const TextStyle(
                          color: AppConstants.textMuted, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                // Send / loading indicator
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: ThinkingDotsWidget(),
                  )
                else
                  GestureDetector(
                    onTap: _performSearch,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppConstants.primary, AppConstants.blue],
                        ),
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            // Response area
            if (_agentResponse.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(top: 10),
                height: 1,
                color: AppConstants.borderColor,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) =>
                        AppConstants.primaryGradient.createShader(bounds),
                    child: const Icon(Icons.smart_toy_outlined, size: 15),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _agentResponse,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppConstants.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
