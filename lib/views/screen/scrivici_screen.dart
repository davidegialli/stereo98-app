// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controller/home_controller.dart';
import '../../utils/custom_color.dart';

class ScriviciScreen extends StatefulWidget {
  const ScriviciScreen({super.key});
  @override
  State<ScriviciScreen> createState() => _ScriviciScreenState();
}

class _ScriviciScreenState extends State<ScriviciScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _codiceFanCtrl  = TextEditingController();
  final _testoCtrl      = TextEditingController();

  File? _foto;
  File? _audio;
  bool _isRecording = false;
  bool _isSending   = false;

  final _recorder     = AudioRecorder();
  final _imagePicker  = ImagePicker();

  @override
  void initState() {
    super.initState();
    try {
      final hc = Get.find<HomeController>();
      if (hc.fanNome.value.isNotEmpty) _nomeCtrl.text      = hc.fanNome.value;
      if (hc.fanCode.value.isNotEmpty) _codiceFanCtrl.text = hc.fanCode.value;
    } catch (_) {}
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _codiceFanCtrl.dispose();
    _testoCtrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() { _isRecording = false; if (path != null) _audio = File(path); });
    } else {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        Get.snackbar('Permesso negato', 'Abilita il microfono nelle impostazioni',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/contattaci_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _inviaMessaggio() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      final request = http.MultipartRequest(
        'POST', Uri.parse('https://stereo98.com/wp-json/stereo98/v1/scrivici'));
      request.fields['nome']       = _nomeCtrl.text.trim();
      request.fields['email']      = _emailCtrl.text.trim();
      request.fields['codice_fan'] = _codiceFanCtrl.text.trim();
      request.fields['testo']      = _testoCtrl.text.trim();
      if (_foto != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', _foto!.path));
      }
      if (_audio != null) {
        request.files.add(await http.MultipartFile.fromPath('audio', _audio!.path,
            contentType: MediaType('audio', 'mp4')));
      }
      final response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar('Inviato! 🎉', 'Il tuo messaggio è stato inviato con successo',
            backgroundColor: const Color(0xFFD85D9D), colorText: Colors.white,
            duration: const Duration(seconds: 3));
      } else {
        final body = await response.stream.bytesToString();
        throw Exception('Errore server: ${response.statusCode} - $body');
      }
    } catch (e) {
      Get.snackbar('Errore', 'Invio fallito. Controlla la connessione e riprova.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgTop    = theme.primaryColor;
    final bgMid    = theme.cardColor;
    final bgBottom = theme.canvasColor;
    final fieldFill = Colors.black.withOpacity(0.15);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: bgTop,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CustomColor.whiteColor),
          onPressed: () => Get.close(1),
        ),
        title: const Text('Contattaci',
            style: TextStyle(color: CustomColor.whiteColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgMid, bgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _label('Nome *'),
                  const SizedBox(height: 6),
                  _field(_nomeCtrl, 'Il tuo nome', fill: fieldFill,
                      validator: (v) => v!.trim().isEmpty ? 'Campo obbligatorio' : null),
                  const SizedBox(height: 16),

                  _label('Email (opzionale)'),
                  const SizedBox(height: 6),
                  _field(_emailCtrl, 'La tua email', fill: fieldFill,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  _label('Codice Fan (opzionale)'),
                  const SizedBox(height: 6),
                  _field(_codiceFanCtrl, 'Il tuo codice fan', fill: fieldFill),
                  const SizedBox(height: 16),

                  _label('Messaggio *'),
                  const SizedBox(height: 6),
                  _field(_testoCtrl, 'Scrivi il tuo messaggio...', fill: fieldFill, maxLines: 5,
                      validator: (v) => v!.trim().isEmpty ? 'Campo obbligatorio' : null),
                  const SizedBox(height: 24),

                  // FOTO
                  _label('Foto (opzionale)'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.photo_library, color: Color(0xFFD85D9D), size: 18),
                        label: Text(_foto == null ? 'Scegli foto' : 'Cambia foto',
                            style: const TextStyle(color: Colors.white70)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      if (_foto != null) ...[
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_foto!, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                          onPressed: () => setState(() => _foto = null),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // AUDIO
                  _label('Messaggio audio (opzionale)'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? Colors.red.withOpacity(0.20)
                                : Colors.black.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: _isRecording ? Colors.red : Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_isRecording ? Icons.stop : Icons.mic,
                                  color: _isRecording ? Colors.red : const Color(0xFFD85D9D),
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _isRecording
                                    ? 'Ferma registrazione'
                                    : (_audio != null ? 'Riregistra' : 'Registra audio'),
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_audio != null && !_isRecording) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.check_circle, color: Color(0xFFD85D9D), size: 20),
                        const SizedBox(width: 4),
                        const Text('Registrato',
                            style: TextStyle(color: Colors.white54, fontSize: 13)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                          onPressed: () => setState(() => _audio = null),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 36),

                  // INVIA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _inviaMessaggio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD85D9D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        disabledBackgroundColor: Colors.white12,
                      ),
                      child: _isSending
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Invia messaggio',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _field(TextEditingController ctrl, String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required Color fill,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD85D9D))),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
