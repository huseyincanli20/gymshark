import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/exercise_repository.dart';
import '../theme/app_theme.dart';

class ExerciseWebSyncModal extends StatefulWidget {
  const ExerciseWebSyncModal({super.key});

  @override
  State<ExerciseWebSyncModal> createState() => _ExerciseWebSyncModalState();
}

class _ExerciseWebSyncModalState extends State<ExerciseWebSyncModal> {
  final _repo = ExerciseRepository.instance;
  late TextEditingController _endpointController;
  final TextEditingController _jsonInputController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: _repo.remoteApiEndpoint);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _jsonInputController.dispose();
    super.dispose();
  }

  Future<void> _syncFromWeb() async {
    setState(() => _isLoading = true);
    final endpoint = _endpointController.text.trim();
    await _repo.setRemoteApiEndpoint(endpoint);
    final success = await _repo.syncFromWeb(customUrl: endpoint);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("İnternet sitesinden ${_repo.exercises.length} egzersiz ve GIF başarıyla senkronize edildi! 🌐🔄"),
            backgroundColor: AppTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bağlantı sağlanamadı veya URL geçersiz. Lütfen endpoint adresini kontrol edin veya alttaki JSON içe aktarmayı kullanın."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _importJson() async {
    final text = _jsonInputController.text.trim();
    if (text.isEmpty) return;

    final success = await _repo.importFromJsonString(text);
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("JSON verisi başarıyla yüklendi! (${_repo.exercises.length} egzersiz)"),
            backgroundColor: AppTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Geçersiz JSON formatı!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _exportJson() {
    final jsonStr = _repo.exportToJsonString();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tüm egzersizler ve GIF linkleri JSON olarak panoya kopyalandı! 📋"),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Başlık
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: AppTheme.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Web / İnternet Sitesi Senkronizasyonu",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Egzersizleri ve .GIF'leri online sitenizden güncelleyin",
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Canlı Web API URL
                      const Text(
                        "1. Web API / İnternet Sitesi Linki (URL)",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accent),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Kendi web sitenizden veya GitHub/Gist/JSONBin üzerinden egzersiz ve GIF verilerini tek tıkla çekin:",
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _endpointController,
                        decoration: InputDecoration(
                          hintText: "https://mysite.com/api/exercises.json",
                          prefixIcon: const Icon(Icons.link, color: AppTheme.primary),
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.sync, color: Colors.white),
                          label: Text(
                            _isLoading ? "Veriler Çekiliyor..." : "Siteden Güncelle & Senkronize Et",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          onPressed: _isLoading ? null : _syncFromWeb,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 16),

                      // 2. Doğrudan JSON Dışa / İçe Aktarma
                      const Text(
                        "2. Web Sitesi için JSON Dışa / İçe Aktarma",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accent),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Egzersiz ve GIF listesini sitenize yüklemek için kopyalayabilir veya sitenizdeki JSON'u buraya yapıştırabilirsiniz:",
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.copy, size: 16, color: AppTheme.primary),
                              label: const Text("JSON'u Kopyala (Export)", style: TextStyle(color: Colors.white, fontSize: 12)),
                              onPressed: _exportJson,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.restore, size: 16, color: Colors.redAccent),
                              label: const Text("Varsayılana Sıfırla", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                              onPressed: () async {
                                final nav = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                await _repo.resetToDefaults();
                                if (mounted) {
                                  nav.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(content: Text("Egzersiz listesi fabrika ayarlarına sıfırlandı.")),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _jsonInputController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: 'Web sitenizdeki JSON metnini buraya yapıştırın...\n[{"id":"ex_1", "name":"...", "thumbnailUrl":"https://...gif", ...}]',
                          filled: true,
                          fillColor: AppTheme.surfaceColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.surfaceColor,
                            side: const BorderSide(color: AppTheme.accent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.file_download_outlined, color: AppTheme.accent, size: 18),
                          label: const Text("Yapıştırılan JSON'u Uygula", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                          onPressed: _importJson,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
