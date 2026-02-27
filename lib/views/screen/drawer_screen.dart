// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stereo98/routes/routes.dart';
import 'package:stereo98/utils/custom_color.dart';
import 'package:stereo98/utils/dimsensions.dart';
import 'package:stereo98/utils/size.dart';
import 'package:stereo98/utils/strings.dart';
import 'package:stereo98/widget_helper/image_widget.dart';
import 'package:stereo98/widget_helper/menu_item_widget.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatelessWidget {
  DrawerScreen({super.key});

  final _dialog = RatingDialog(
    initialRating: 1.0,
    title: const Text(
      'Stereo 98 DAB+',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    ),
    message: const Text(
      'Lascia la tua valutazione!',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ),
    image: Image.asset(Strings.splashLogo, height: 150),
    submitButtonText: 'Invia',
    onCancelled: () {},
    onSubmitted: (response) {
      if (response.rating >= 3.0) {
        StoreRedirect.redirect(
          androidAppId: 'com.stereo98.dabplus',
          iOSAppId: '6759221003',
        );
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).canvasColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(30)),
      ),
      child: ListView(
        children: [
          _headerDrawer(context),
          Divider(height: 2, color: CustomColor.whiteColor.withOpacity(0.5)),
          _listWidget(context),
        ],
      ),
    );
  }

  Container _headerDrawer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.defaultPaddingSize),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).cardColor,
            Theme.of(context).canvasColor,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: mainEnd,
        crossAxisAlignment: crossCenter,
        children: const [ImageWidget()],
      ),
    );
  }

  Column _listWidget(BuildContext context) {
    return Column(
      children: [
        MenuItemWidget(
          screenName: 'Palinsesto',
          icon: Icons.calendar_today,
          onPressed: () => Get.toNamed(Routes.palinsestoScreen),
        ),
        MenuItemWidget(
          screenName: 'Shows',
          icon: Icons.mic,
          onPressed: () => Get.toNamed(Routes.showsScreen),
        ),
        MenuItemWidget(
          screenName: 'Podcast',
          icon: Icons.podcasts,
          onPressed: () => Get.toNamed(Routes.podcastScreen),
        ),
        MenuItemWidget(
          screenName: 'Hai ascoltato',
          icon: Icons.history,
          onPressed: () => Get.toNamed(Routes.cronologiaScreen),
        ),
        MenuItemWidget(
          screenName: 'Sondaggi',
          icon: Icons.poll,
          onPressed: () => Get.toNamed(Routes.sondaggiScreen),
        ),
        MenuItemWidget(
          screenName: 'Scrivici',
          icon: Icons.mail_outline,
          onPressed: () => Get.toNamed(Routes.scriviciScreen),
        ),
        MenuItemWidget(
          screenName: 'Website',
          icon: Icons.language,
          onPressed: () async {
            final url = Uri.parse('https://stereo98.com');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.platformDefault);
            }
          },
        ),
        MenuItemWidget(
          screenName: 'Come funziona',
          icon: Icons.help_outline,
          onPressed: () => Get.toNamed(Routes.istruzioniScreen),
        ),
        MenuItemWidget(
          screenName: 'Chi Siamo',
          icon: Icons.info,
          onPressed: () => Get.toNamed(Routes.aboutScreen),
        ),
        MenuItemWidget(
          screenName: 'Impostazioni',
          icon: Icons.settings,
          onPressed: () => Get.toNamed(Routes.settingsScreen),
        ),
        MenuItemWidget(
          screenName: 'Valutaci',
          icon: Icons.star_half,
          onPressed: () => showDialog(context: context, builder: (_) => _dialog),
        ),
      ],
    );
  }
}
