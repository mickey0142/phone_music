import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  AudioPlayer audioPlayer = AudioPlayer();
  List<MediaItem> musicList = [];
  int currentIndex = 0;
  PlaybackState _playbackState = PlaybackState(
    controls: [
      MediaControl.skipToPrevious,
      MediaControl.pause,
      MediaControl.skipToNext,
    ],
    playing: false,
  );

  MyAudioHandler() {
    audioPlayer.onPlayerStateChanged.listen((PlayerState event) {
      if (event == PlayerState.stopped || event == PlayerState.paused) {
        _playbackState = _playbackState.copyWith(
          playing: false,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
          ],
        );
        playbackState.add(_playbackState);
      } else if (event == PlayerState.playing) {
        _playbackState = _playbackState.copyWith(
          playing: true,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.skipToNext,
          ],
          queueIndex: currentIndex,
        );
        playbackState.add(_playbackState);
      }
    });
    audioPlayer.onDurationChanged.listen((event) {
      musicList[currentIndex] =
          musicList[currentIndex].copyWith(duration: event);
      mediaItem.add(musicList[currentIndex]);
    });
    audioPlayer.onPositionChanged.listen((event) {
      _playbackState = _playbackState.copyWith(updatePosition: event);
      playbackState.add(_playbackState);
    });
    audioPlayer.onPlayerComplete.listen((event) async {
      skipToNext();
    });
  }

  Future<void> initFirstSong() async {
    await audioPlayer.setSourceDeviceFile(musicList[currentIndex].id);
    audioPlayer.onDurationChanged.listen((event) {
      musicList[currentIndex] =
          musicList[currentIndex].copyWith(duration: event);
      mediaItem.add(musicList[currentIndex]);
    });
  }

  @override
  Future<void> play() async {
    // All 'play' requests from all origins route to here. Implement this
    // callback to start playing audio appropriate to your app. e.g. music.
    await audioPlayer.play(DeviceFileSource(musicList[currentIndex].id));
  }

  @override
  Future<void> pause() async {
    print('pause in MyAudioHandler called');
    audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    print('stop in MyAudioHandler called');
  }

  @override
  Future<void> seek(Duration position) async {
    print('seek in MyAudioHandler called duration is $position');
    audioPlayer.seek(position);
    _playbackState = _playbackState.copyWith(
      updatePosition: position,
    );
    playbackState.add(_playbackState);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    print('skipToQueueItem in MyAudioHandler called i is $index');
    currentIndex = index;
    _playbackState = _playbackState.copyWith(queueIndex: currentIndex);
    playbackState.add(_playbackState);
    play();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    print('addQueueItem called mediaItem is $mediaItem');
    if (musicList.isEmpty) {
      musicList.add(mediaItem);
      initFirstSong();
    } else {
      musicList.add(mediaItem);
    }
  }

  @override
  Future<void> skipToNext() async {
    currentIndex += 1;
    if (currentIndex >= musicList.length) {
      currentIndex = 0;
    }
    _playbackState = _playbackState.copyWith(queueIndex: currentIndex);
    playbackState.add(_playbackState);
    play();
  }

  @override
  Future<void> skipToPrevious() async {
    currentIndex -= 1;
    if (currentIndex < 0) {
      currentIndex = musicList.length;
    }
    _playbackState = _playbackState.copyWith(queueIndex: currentIndex);
    playbackState.add(_playbackState);
    play();
  }
}
