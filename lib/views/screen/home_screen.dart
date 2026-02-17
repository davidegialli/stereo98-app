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
                    _controller.assetsAudioPlayer.stop();
                  } else {
                    _controller.assetsAudioPlayer.play();
                  }
                  _controller.isPressed.value = !_controller.isPressed.value;
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

            addVerticalSpace(Dimensions.marginSize * 2),

            // SHOW IN ONDA o PROSSIMA DIRETTA
            Obx(() {
              final show = _controller.showName.value;
              final showImg = _controller.showImage.value;
              final nextShow = _controller.nextShowName.value;
              final nextTime = _controller.nextShowTime.value;
              final numero = _controller.whatsappNumber.value;
              final studio = _controller.whatsappStudio.value;

              // Fix: non distruggere widget quando vuoto

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
                            // Ã°Å¸â€Â¥ Foto show
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
                                            Text('WhatsApp Ã¢â‚¬Â¢ $studio',
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
              // COPERTINA con shimmer e crossfade
              Obx(() {
                final isShimmer = _controller.artworkShimmer.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Immagine copertina
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFFD85D9D).withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedOpacity(
                          opacity: _controller.artworkOpacity.value,
                          duration: const Duration(milliseconds: 400),
                          child: Image.network(
                            _controller.artworkUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    // Shimmer overlay durante refresh
                    if (isShimmer)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: AnimatedBuilder(
                            animation: _shimmerAnim,
                            builder: (_, __) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(_shimmerAnim.value - 1, 0),
                                  end: Alignment(_shimmerAnim.value, 0),
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
              addVerticalSpace(15),

              // Volume slider
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
                        await _controller.assetsAudioPlayer.setVolume(value);
                      },
                    ),
                  )),
                  const Icon(Icons.volume_up, color: Colors.white),
                ],
              ),

              // Titolo
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

              // Artista
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
