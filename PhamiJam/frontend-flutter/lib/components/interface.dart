import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class Interface extends StatelessWidget {
  final Duration progress;
  final Duration? duration;
  final bool isPlaying;
  final double currentSliderValue;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPlayPauseToggle;
  final VoidCallback onPrevious;
  final VoidCallback onForward;
  final ValueChanged<double> onVolumeChange;
  final String artist;
  final String songName;
  final double volume = 20.0;

  const Interface({
    super.key,
    required this.progress,
    required this.duration,
    required this.isPlaying,
    required this.currentSliderValue,
    required this.onSeek,
    required this.onPlayPauseToggle,
    required this.onPrevious,
    required this.onForward,
    required this.onVolumeChange,
    required this.artist,
    required this.songName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      color: Color(0xFFb5832e),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ProgressBar(
              progress: progress,
              total: duration ?? Duration.zero,
              thumbGlowRadius: 25,
              thumbRadius: 10,
              thumbColor: Color(0xFF121212),
              baseBarColor: Color(0xFFece1d4),
              onSeek: (duration) {
                onSeek(duration);
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "$artist - $songName",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onPrevious,
                    icon: Icon(
                      Icons.skip_previous_outlined,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: onPlayPauseToggle,
                    icon:
                        isPlaying
                            ? Icon(
                              Icons.pause_circle_outline_outlined,
                              color: Colors.black,
                            )
                            : Icon(
                              Icons.play_arrow_outlined,
                              color: Colors.black,
                            ),
                  ),
                  IconButton(
                    onPressed: onForward,
                    icon: Icon(Icons.skip_next_outlined, color: Colors.black),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => debugPrint("muted"),
                      icon: Icon(Icons.volume_up_outlined, color: Colors.black),
                    ),
                    Slider(
                      thumbColor: Color(0xFF121212),
                      value: volume,
                      max: 100,
                      onChanged: (value) {
                        debugPrint("Volume: $value");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
