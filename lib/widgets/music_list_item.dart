import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_music/controllers/music_controller.dart';
import 'package:phone_music/models/music_model.dart';
import 'package:phone_music/themes/base_theme.dart';

class MusicListItem extends StatelessWidget {
  final MusicModel musicModel;
  final Color backgroundColor;
  final int index;
  final musicController = Get.find<MusicController>();

  MusicListItem({
    Key? key,
    required this.musicModel,
    required this.index,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          musicController.onMusicPressed(index);
        },
        child: Container(
          padding:
              const EdgeInsets.only(top: 16, left: 8, bottom: 16, right: 16),
          child: Row(
            children: [
              const Icon(
                Icons.music_note,
                color: darkTextColor,
              ),
              Container(width: 8),
              Expanded(
                child: Text(
                  musicModel.name,
                  style: const TextStyle(
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                    color: darkTextColor,
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
