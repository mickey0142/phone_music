import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_music/controllers/music_controller.dart';
import 'package:phone_music/routes/app_pages.dart';
import 'package:phone_music/utils/audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(MusicController(), permanent: true);

  final _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.maytat.phone_music.channel.audio',
      androidNotificationChannelName: 'Music playback',
    ),
  );
  Get.find<MusicController>().setAudioHandler(_audioHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Music',
      initialRoute: Routes.HOME,
      getPages: AppPages.routes,
      builder: (BuildContext context, Widget? child) {
        return child ?? Container();
      },
    );
  }
}
