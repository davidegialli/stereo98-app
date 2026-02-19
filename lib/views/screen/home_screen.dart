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
      ),
      drawer: DrawerScreen(),
      body: _bodyWidget(context),
    );
  }

  // ============================================================================
  // RDS WIDGETS
  // ============================================================================

  Widget _buildRdsMarquee() {
    return GestureDetector(
      onTap: () => _openRdsLink(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD85D9D).withOpacity(0.3),
              const Color(0xFF4EC8E8).withOpacity(0.15),
              const Color(0xFFD85D9D).withOpacity(0.3),
            ],
          ),
        ),
        child: _MarqueeText(
          text: _controller.rdsTesto.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildRdsPopup() {
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
                onTap: () => _openRdsLink(),
                child: Text(
                  _controller.rdsTesto.value,
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
              onTap: () => _controller.dismissRdsPopup(),
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

  void _openRdsLink() async {
    final link = _controller.rdsUrl.value;
    if (link.isNotEmpty) {
      final url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
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
            addVerticalSpace(Dimensions.marginSize),

            // PLAY BUTTON
            Obx(() => Center(
              child: GestureDetector(
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
              ),
            )),

            addVerticalSpace(Dimensions.marginSize),

            // RDS MESSAGE
            Obx(() {
              if (!_controller.rdsAttivo.value) return const SizedBox.shrink();

              if (_controller.rdsTipo.value == 'popup') {
                if (_controller.rdsPopupDismissed.value) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRdsPopup(),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRdsMarquee(),
              );
            }),

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
