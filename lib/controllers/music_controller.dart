import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_music/models/music_model.dart';

class MusicController extends GetxController {
  AudioHandler? _audioHandler;
  List<String> musicFolderPath = [];
  final musicList = [].obs;
  final isPlaying = false.obs;
  final isSeeking = false.obs;
  final currentPositionPercent = 0.0.obs;
  final currentSongIndex = 0.obs;
  final musicPosition = Duration().obs;
  final musicDuration = Duration().obs;

  @override
  void onInit() async {
    super.onInit();

    if (!(await Permission.storage.isGranted)) {
      Permission.storage.request();
    }

    if (!(await Permission.audio.isGranted)) {
      Permission.audio.request();
    }

    await getMusicFolder('0');
    await getMusicFolder('1');
    for (int i = 0; i < musicFolderPath.length; i++) {
      await getMusicFile(musicFolderPath[i]);
    }
    updateMusicListInHandler();
  }

  Future<void> getMusicFolder(String storageType) async {
    try {
      Directory? rootFolder =
          Directory.fromUri(Uri(path: '/storage/emulated/$storageType'));
      List<FileSystemEntity>? fileList = rootFolder.listSync();

      print('external path is ${rootFolder.path}');
      print('fileList length is ${fileList.length}');
      print('fileList is $fileList');
      for (int i = 0; i < fileList.length; i++) {
        List<String> file = fileList[i].path.split('/');
        String folderName = file.last.toLowerCase();
        if (folderName == 'music' ||
            folderName == 'musics' ||
            folderName == 'my music' ||
            folderName == 'my musics') {
          musicFolderPath.add(fileList[i].path);
          print('saving path ${fileList[i].path}');
        }
      }
    } on UnsupportedError catch (e) {
      print('path "/storage/emulated/$storageType" not found : $e');
    } on FileSystemException catch (e) {
      print('directory or file does not exist : $e');
    } catch (e) {
      print('unknown error : $e');
    }
  }

  Future<void> getMusicFile(String path) async {
    try {
      Directory? musicFolder = Directory.fromUri(Uri(path: path));
      List<FileSystemEntity>? fileList = musicFolder.listSync();
      for (int i = 0; i < fileList.length; i++) {
        List<String> file = fileList[i].path.split('/');
        String fileName = file.last;
        if (fileName.endsWith('.mp3')) {
          print('adding file $fileName from path ${fileList[i].path}');
          musicList().add(MusicModel(name: fileName, path: fileList[i].path));
        }
      }
    } on UnsupportedError catch (e) {
      print('path "$path" not found : $e');
    } on FileSystemException catch (e) {
      print('directory or file does not exist : $e');
    } catch (e) {
      print('unknown error : $e');
    }
  }

  void setAudioHandler(AudioHandler handler) {
    print('setAudioHandler called musicList length is ${musicList().length}');
    _audioHandler = handler;

    _audioHandler?.playbackState.listen((event) {
      isPlaying(event.playing);
      currentSongIndex(event.queueIndex);
    });
    _audioHandler?.mediaItem.listen((event) {
      musicDuration(event?.duration);
    });
    AudioService.position.listen((event) {
      if (!isSeeking() && musicDuration().inMilliseconds > 0) {
        musicPosition(event);
        currentPositionPercent(musicPosition().inMilliseconds /
            musicDuration().inMilliseconds *
            100);
      }
    });
  }

  void updateMusicListInHandler() {
    for (int i = 0; i < musicList().length; i++) {
      _audioHandler?.addQueueItem(MediaItem(
        id: musicList()[i].path,
        title: musicList()[i].name,
      ));
    }
  }

  void playButtonPressed() {
    if (isPlaying()) {
      _audioHandler?.pause();
    } else {
      _audioHandler?.play();
    }
  }

  void nextButtonPressed() {
    _audioHandler?.skipToNext();
  }

  void previousButtonPressed() {
    _audioHandler?.skipToPrevious();
  }

  void onMusicPressed(int index) {
    print('onMusicPressed called : $index');
    _audioHandler?.skipToQueueItem(index);
  }

  void updateSeeking(double percent) {
    currentPositionPercent(percent);
    int newTime = (musicDuration().inMilliseconds * (percent / 100)).toInt();
    musicPosition(Duration(milliseconds: newTime));
  }

  void seekMusic(double percent) async {
    currentPositionPercent(percent);
    int newTime = (musicDuration().inMilliseconds * (percent / 100)).toInt();
    await _audioHandler?.seek(Duration(milliseconds: newTime));
  }

  String getFormattedTime(Duration duration) {
    String returnValue = '';
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    if (duration.inHours > 0) {
      returnValue = '${twoDigits(duration.inHours)}:';
    }
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    returnValue += '$twoDigitMinutes:$twoDigitSeconds';
    return returnValue;
  }

  String getCurrentTime() {
    return getFormattedTime(musicPosition());
  }

  String getMusicDuration() {
    return getFormattedTime(musicDuration());
  }

  String getMusicName() {
    if (musicList.isNotEmpty) {
      return musicList()[currentSongIndex()].name;
    } else {
      return '...';
    }
  }
}
