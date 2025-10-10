import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class Interface extends StatefulWidget {
  final Duration progress;
  final Duration? duration;
  final bool isPlaying;
  final bool isMuted;
  final double currentSliderValue;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPlayPauseToggle;
  final VoidCallback onToggleVolume;
  final VoidCallback onPrevious;
  final VoidCallback onForward;
  final ValueChanged<double> onVolumeChange;
  final String artist;
  final String songName;

  Interface({
    super.key,
    required this.progress,
    required this.duration,
    required this.isPlaying,
    required this.isMuted,
    required this.currentSliderValue,
    required this.onSeek,
    required this.onPlayPauseToggle,
    required this.onToggleVolume,
    required this.onPrevious,
    required this.onForward,
    required this.onVolumeChange,
    required this.artist,
    required this.songName,
  });

  @override
  State<Interface> createState() => _InterfaceState();
}

class _InterfaceState extends State<Interface> {
  double? oldVolume;

  void handleToggleVolume() {
    if (!widget.isMuted) {
      oldVolume = widget.currentSliderValue;
      widget.onVolumeChange(0);
    } else {
      widget.onVolumeChange(oldVolume ?? 20.0);
    }
    widget.onToggleVolume();
  }

  void handleSliderChange(double value) {
    widget.onVolumeChange(value);
    if (value == 0 && !widget.isMuted) {
      widget.onToggleVolume();
    } else if (value > 0 && widget.isMuted) {
      widget.onToggleVolume();
    }
    if (value > 0) oldVolume = value;
  }

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
              progress: widget.progress,
              total: widget.duration ?? Duration.zero,
              thumbGlowRadius: 25,
              thumbRadius: 10,
              thumbColor: Color(0xFF121212),
              baseBarColor: Color(0xFFece1d4),
              onSeek: widget.onSeek,
            ),
          ),
          SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Song info (left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: SizedBox(
                      width: 220,
                      height: 24,
                      child: Marquee(
                        text: "${widget.artist} - ${widget.songName}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        scrollAxis: Axis.horizontal,
                        blankSpace: 40.0,
                        velocity: 30.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                      ),
                    ),
                  ),
                ),
                // Control buttons (center)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: widget.onPrevious,
                      icon: Icon(
                        Icons.skip_previous_outlined,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onPlayPauseToggle,
                      icon:
                          widget.isPlaying
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
                      onPressed: widget.onForward,
                      icon: Icon(Icons.skip_next_outlined, color: Colors.black),
                    ),
                  ],
                ),
                // Volume controls (right)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: handleToggleVolume,
                          icon:
                              !widget.isMuted
                                  ? Icon(
                                    Icons.volume_up_outlined,
                                    color: Colors.black,
                                  )
                                  : Icon(
                                    Icons.volume_off_outlined,
                                    color: Colors.black,
                                  ),
                        ),
                        SizedBox(
                          width: 200,
                          child: Slider(
                            thumbColor: Color(0xFF121212),
                            value: widget.currentSliderValue,
                            max: 100,
                            onChanged: handleSliderChange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
