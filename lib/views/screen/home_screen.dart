// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:stereo98/controller/home_controller.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/views/screen/drawer_screen.dart';
import 'package:stereo98/widget_helper/network_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(HomeController());
  final sliderValue = 0.7.obs;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SLEEP TIMER DIALOG
  // ==========================================================================
  void _showSleepTimerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A1A2E), Color(0xFF1A0A1E)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sleep Timer',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'La radio si spegne automaticamente',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final active = _controller.sleepTimerMinutes.value;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [15, 30, 45, 60, 90].map((min) {
                  final isActive = active == min;
                  return GestureDetector(
                    onTap: () {
                      _controller.setSleepTimer(min);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 70, height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: isActive ? const LinearGradient(colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)]) : null,
                        color: isActive ? null : Colors.white.withOpacity(0.08),
                        border: Border.all(color: isActive ? Colors.transparent : Colors.white24),
                      ),
                      child: Center(
                        child: Text(
                          '$min min',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
            Obx(() {
              if (_controller.sleepTimerMinutes.value <= 0) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  _controller.cancelSleepTimer();
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withOpacity(0.15),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Disattiva timer',
                    style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // FAN PROFILE DIALOG
  // ==========================================================================
  void _showFanProfileDialog() {
    final nomeController = TextEditingController(text: _controller.fanNome.value);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1A2E), Color(0xFF1A0A1E)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Text('Il tuo profilo fan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFD85D9D).withOpacity(0.15),
                ),
                child: Text(
                  _controller.fanCode.value,
                  style: const TextStyle(color: Color(0xFFD85D9D), fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )),
              const SizedBox(height: 6),
              Obx(() {
                final pos = _controller.fanPosizione.value;
                final votes = _controller.fanTotalVotes.value;
                return Text(
                  '⭐ $votes voti${pos != null ? ' • 🏆 Posizione #$pos' : ''}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                );
              }),
              const SizedBox(height: 20),
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Il tuo nome (facoltativo)',
                  labelStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD85D9D)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _controller.updateFanNome(nomeController.text.trim());
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)]),
                  ),
                  child: const Text(
                    'SALVA',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Il codice fan ti serve per ritirare i premi!',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // RDS WIDGETS
  // ============================================================================

  Widget _buildRdsMarquee(String testo, String url) {
    return GestureDetector(
      onTap: () => _openLink(url),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                const Color(0xFFD85D9D).withOpacity(0.25),
                const Color(0xFF4EC8E8).withOpacity(0.12),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFD85D9D).withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign, color: Color(0xFFD85D9D), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: _MarqueeText(
                  text: testo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRdsPopup(String testo, String url, int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD85D9D).withOpacity(0.25),
              const Color(0xFF4EC8E8).withOpacity(0.15),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFD85D9D).withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Color(0xFFD85D9D), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _openLink(url),
                child: Text(
                  testo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _controller.dismissRdsPopup(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
                child: const Icon(Icons.close, color: Colors.white54, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLink(String link) async {
    if (link.isNotEmpty) {
      final url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Widget _buildRdsSection() {
    return Obx(() {
      if (!_controller.rdsAttivo.value || _controller.rdsMessaggi.isEmpty) {
        return const SizedBox.shrink();
      }

      final widgets = <Widget>[];

      for (int i = 0; i < _controller.rdsMessaggi.length; i++) {
        final msg = _controller.rdsMessaggi[i];
        final testo = msg['testo'] ?? '';
        final tipo = msg['tipo'] ?? 'scroll';
        final url = msg['url'] ?? '';

        if (testo.isEmpty) continue;

        if (tipo == 'popup') {
          if (_controller.rdsDismissed.contains(i)) continue;
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildRdsPopup(testo, url, i),
          ));
        } else {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildRdsMarquee(testo, url),
          ));
        }
      }

      if (widgets.isEmpty) return const SizedBox.shrink();

      return Column(children: widgets);
    });
  }

  Widget _buildCopertina({required bool isShimmer}) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD85D9D).withOpacity(isShimmer ? 0.7 : 0.4),
            blurRadius: isShimmer ? 30 : 20,
            spreadRadius: isShimmer ? 5 : 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(40),
              child: Image.asset(
                'assets/images/logo_header.png',
                fit: BoxFit.contain,
              ),
            ),
            AnimatedOpacity(
              opacity: _controller.artworkOpacity.value,
              duration: const Duration(milliseconds: 400),
              child: Image.network(
                _controller.artworkUrl.value,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // BUILD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerRight,
          child: Image.asset('assets/images/logo_header.png', height: 40, fit: BoxFit.contain),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Sleep Timer indicator in app bar
          Obx(() {
            if (_controller.sleepTimerMinutes.value <= 0) return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => _showSleepTimerDialog(),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF4EC8E8).withOpacity(0.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bedtime, color: Color(0xFF4EC8E8), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _controller.sleepTimerFormatted,
                      style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      drawer: DrawerScreen(),
      body: Stack(
        children: [
          _bodyWidget(context),
          // PREMIO OVERLAY — widget nell'albero, funziona SEMPRE
          Obx(() {
            if (!_controller.premioPending.value) return const SizedBox.shrink();
            return Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A1A2E), Color(0xFF1A0A1E)],
                    ),
                    border: Border.all(color: const Color(0xFFD85D9D), width: 2),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFD85D9D).withOpacity(0.4), blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 50)),
                      const SizedBox(height: 12),
                      const Text(
                        'HAI VINTO!',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _controller.premioMessaggio.value,
                        style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      if (_controller.fanCode.value.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFFD85D9D).withOpacity(0.2),
                            border: Border.all(color: const Color(0xFFD85D9D).withOpacity(0.5)),
                          ),
                          child: Text(
                            'Il tuo codice: ${_controller.fanCode.value}',
                            style: const TextStyle(color: Color(0xFFD85D9D), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _controller.dismissPremio(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)]),
                          ),
                          child: const Text(
                            'FANTASTICO!',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================================
  // BODY
  // ============================================================================

  Widget _bodyWidget(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0A10), Color(0xFF000000), Color(0xFF0A0A1A)],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _upperContainer(context),
            addVerticalSpace(6),

            // ===================== FAN CODE (sopra il play) =====================
            Obx(() {
              if (_controller.fanCode.value.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => _showFanProfileDialog(),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFD85D9D).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFD85D9D).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, color: Color(0xFFD85D9D), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _controller.fanNome.value.isNotEmpty
                          ? '${_controller.fanNome.value} • ${_controller.fanCode.value}'
                          : _controller.fanCode.value,
                        style: const TextStyle(color: Color(0xFFD85D9D), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      if (_controller.fanTotalVotes.value > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '⭐${_controller.fanTotalVotes.value}',
                          style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.8), fontSize: 12),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Icon(Icons.edit, color: const Color(0xFFD85D9D).withOpacity(0.5), size: 12),
                    ],
                  ),
                ),
              );
            }),

            // =================== CONTROLS ROW ===================
            // [🌙 Sleep] [❤️ Cuore] [▶️ Play] [⭐ Voto] 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Sleep Timer
                GestureDetector(
                  onTap: () => _showSleepTimerDialog(),
                  child: Obx(() => Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.sleepTimerMinutes.value > 0
                        ? const Color(0xFF4EC8E8).withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: _controller.sleepTimerMinutes.value > 0
                          ? const Color(0xFF4EC8E8).withOpacity(0.6)
                          : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.bedtime,
                      color: _controller.sleepTimerMinutes.value > 0
                        ? const Color(0xFF4EC8E8)
                        : Colors.white54,
                      size: 22,
                    ),
                  )),
                ),

                const SizedBox(width: 14),

                // ❤️ CUORE — preferiti locali, sempre attivo
                Obx(() => GestureDetector(
                  onTap: () => _controller.toggleFavorite(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.currentSongFavorited.value
                        ? const Color(0xFFD85D9D).withOpacity(0.2)
                        : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: _controller.currentSongFavorited.value
                          ? const Color(0xFFD85D9D).withOpacity(0.6)
                          : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      _controller.currentSongFavorited.value ? Icons.favorite : Icons.favorite_border,
                      color: _controller.currentSongFavorited.value
                        ? const Color(0xFFD85D9D)
                        : Colors.white54,
                      size: 22,
                    ),
                  ),
                )),

                const SizedBox(width: 14),

                // ▶️ PLAY BUTTON
                Obx(() => GestureDetector(
                  onTap: () {
                    if (_controller.isPressed.value) {
                      _controller.stopStream();
                    } else {
                      _controller.playStream();
                    }
                  },
                  child: Container(
                    width: 70.w,
                    height: 70.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)]),
                      boxShadow: [BoxShadow(color: const Color(0xFFD85D9D).withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: Icon(
                      _controller.isPressed.value ? Icons.stop : Icons.play_arrow,
                      color: Colors.white, size: 40,
                    ),
                  ),
                )),

                const SizedBox(width: 14),

                // ⭐ STELLA — voto chart, solo con play attivo
                Obx(() {
                  final playActive = _controller.isPressed.value;
                  final voted = _controller.currentSongVoted.value;
                  return GestureDetector(
                    onTap: playActive ? () => _controller.toggleVote() : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: voted
                          ? const Color(0xFFFFD700).withOpacity(0.2)
                          : Colors.white.withOpacity(playActive ? 0.08 : 0.03),
                        border: Border.all(
                          color: voted
                            ? const Color(0xFFFFD700).withOpacity(0.6)
                            : Colors.white.withOpacity(playActive ? 0.2 : 0.08),
                        ),
                      ),
                      child: Icon(
                        voted ? Icons.star : Icons.star_border,
                        color: voted
                          ? const Color(0xFFFFD700)
                          : (playActive ? Colors.white54 : Colors.white24),
                        size: 22,
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 14),

                // Placeholder per bilanciare (stessa larghezza del sleep)
                const SizedBox(width: 44),
              ],
            ),

            addVerticalSpace(12),

            // RDS MESSAGGI
            _buildRdsSection(),

            // SHOW IN ONDA o PROSSIMA DIRETTA
            Obx(() {
              final show = _controller.showName.value;
              final showImg = _controller.showImage.value;
              final nextShow = _controller.nextShowName.value;
              final nextTime = _controller.nextShowTime.value;
              final numero = _controller.whatsappNumber.value;
              final studio = _controller.whatsappStudio.value;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    if (show.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(colors: [
                            const Color(0xFFD85D9D).withOpacity(0.25),
                            const Color(0xFF4EC8E8).withOpacity(0.12),
                          ]),
                          border: Border.all(color: const Color(0xFFD85D9D), width: 1.5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showImg.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  showImg, width: 60, height: 60, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                ),
                              ),
                            if (showImg.isNotEmpty) const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(color: const Color(0xFFD85D9D), borderRadius: BorderRadius.circular(6)),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: Colors.white, size: 8),
                                            SizedBox(width: 4),
                                            Text('ORA IN ONDA', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.mic, color: Color(0xFF4EC8E8), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(show,
                                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (numero.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        final url = Uri.parse('https://wa.me/$numero');
                                        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.platformDefault);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: const Color(0xFF25D366).withOpacity(0.15),
                                          border: Border.all(color: const Color(0xFF25D366).withOpacity(0.6)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.chat, color: Color(0xFF25D366), size: 16),
                                            const SizedBox(width: 6),
                                            Text('WhatsApp - $studio',
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (nextShow.isNotEmpty) ...[
                      if (show.isNotEmpty) const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF4EC8E8).withOpacity(0.08),
                          border: Border.all(color: const Color(0xFF4EC8E8).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF4EC8E8), size: 16),
                            const SizedBox(width: 8),
                            const Text('Prossima diretta: ', style: TextStyle(color: Color(0xFF4EC8E8), fontSize: 12)),
                            Expanded(
                              child: Text(
                                nextTime.isNotEmpty ? '$nextShow alle $nextTime' : nextShow,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            addVerticalSpace(20.h),
            const NetworkWidget(),
            addVerticalSpace(20.h),
          ],
        ),
      ),
    );
  }

  Container _upperContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: Dimensions.marginSize, horizontal: Dimensions.defaultPaddingSize),
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 500,
        borderRadius: Dimensions.borderRadius * 1.5,
        blur: 10,
        alignment: Alignment.bottomCenter,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFD85D9D).withOpacity(0.1), const Color(0xFF4EC8E8).withOpacity(0.05)],
          stops: const [0.1, 1],
        ),
        borderGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD85D9D), Color(0xFF4EC8E8)],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                final isShimmer = _controller.artworkShimmer.value;
                if (isShimmer) {
                  return AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) {
                      final t = ((_shimmerAnim.value + 1) / 2).clamp(0.0, 1.0);
                      final scale = 1.0 + 0.06 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                      return Transform.scale(
                        scale: scale,
                        child: _buildCopertina(isShimmer: true),
                      );
                    },
                  );
                }
                return _buildCopertina(isShimmer: false);
              }),
              addVerticalSpace(15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_mute, color: Colors.white),
                  Obx(() => SizedBox(
                    width: 220.w,
                    child: Slider(
                      min: 0.0, max: 1.0,
                      activeColor: CustomColor.primaryColorOne,
                      inactiveColor: Colors.white.withOpacity(0.3),
                      thumbColor: CustomColor.primaryColor,
                      value: sliderValue.value,
                      onChanged: (value) async {
                        sliderValue.value = value;
                        await _controller.setVolume(value);
                      },
                    ),
                  )),
                  const Icon(Icons.volume_up, color: Colors.white),
                ],
              ),

              Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.defaultPaddingSize * 0.4),
                child: Text(
                  _controller.titleValue.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )),
              addVerticalSpace(5),

              Obx(() => Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.defaultPaddingSize * 0.4),
                child: Text(
                  _controller.artistValue.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF4EC8E8), fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MARQUEE WIDGET
// =============================================================================
class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeText({required this.text, required this.style});

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    _animController.duration = Duration(milliseconds: (maxScroll * 30).toInt().clamp(4000, 20000));
    _animController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _animController.value * _scrollController.position.maxScrollExtent,
        );
      }
    });
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _scrollController.jumpTo(0);
            _animController.forward(from: 0);
          }
        });
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _animController.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _animController.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(widget.text, style: widget.style),
          ),
        ],
      ),
    );
  }
}
