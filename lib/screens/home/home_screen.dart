import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_music/controllers/music_controller.dart';
import 'package:phone_music/themes/base_theme.dart';
import 'package:phone_music/widgets/material_icon_button.dart';
import 'package:phone_music/widgets/music_list_item.dart';
import 'package:phone_music/widgets/slider_custom_track_shape.dart';

class HomeScreen extends GetView<MusicController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Phone Music'),
      backgroundColor: darkPrimaryColor,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: controller.musicList().length,
        itemBuilder: (context, index) {
          Color bgColor = lightPrimaryColor;
          if (index % 2 == 0) {
            bgColor = lightBackgroundColor;
          }
          return MusicListItem(
            musicModel: controller.musicList()[index],
            index: index,
            backgroundColor: bgColor,
          );
        },
      );
    });
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Obx(() {
      return Container(
        height: 140,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: darkPrimaryColor),
          ),
          color: primaryColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Text(
                controller.getMusicName(),
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  color: lightTextColor,
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    controller.getCurrentTime(),
                    style: const TextStyle(color: lightTextColor),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackShape:
                          SliderCustomTrackShape(), // this is used to remove padding on left and right of slider
                    ),
                    child: Slider(
                      value: controller.currentPositionPercent(),
                      max: 100,
                      min: 0,
                      onChanged: (double value) {
                        controller.updateSeeking(value);
                      },
                      onChangeStart: (value) {
                        controller.isSeeking(true);
                      },
                      onChangeEnd: (value) {
                        controller.isSeeking(false);
                        controller.seekMusic(value);
                      },
                      thumbColor: accentColor,
                      activeColor: accentColor,
                      inactiveColor: lightBackgroundColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    controller.getMusicDuration(),
                    style: const TextStyle(color: lightTextColor),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialIconButton(
                  onPressed: () {
                    controller.previousButtonPressed();
                  },
                  icon: const Icon(
                    Icons.skip_previous,
                    color: accentColor,
                  ),
                  iconSize: 35,
                ),
                Container(width: 8),
                MaterialIconButton(
                  onPressed: () {
                    controller.playButtonPressed();
                  },
                  icon: Icon(
                    controller.isPlaying() ? Icons.pause : Icons.play_arrow,
                    color: accentColor,
                  ),
                  iconSize: 35,
                ),
                Container(width: 8),
                MaterialIconButton(
                  onPressed: () {
                    controller.nextButtonPressed();
                  },
                  icon: const Icon(
                    Icons.skip_next,
                    color: accentColor,
                  ),
                  iconSize: 35,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
