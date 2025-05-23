import 'package:flutter/material.dart';
import 'package:phamijam/components/interface.dart';
import 'package:phamijam/components/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/models/playback_model.dart';
import 'package:phamijam/components/audio_player_singleton.dart';

class CreatePlaylist extends StatefulWidget {
  const CreatePlaylist({super.key});

  @override
  State<CreatePlaylist> createState() => _CreatePlaylistState();
}

class _CreatePlaylistState extends State<CreatePlaylist> {
  @override
  Widget build(BuildContext context) {
    final playback = Provider.of<PlaybackModel>(context);

    return Scaffold(
      backgroundColor: Color(0xFFdba43a),
      body: Stack(
        children: [
          Align(alignment: Alignment.topLeft, child: Sidebar()),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 150,
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 5,
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFe2b661),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 170,
                          height: 125,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: 10,
                          top: 5,
                          left: 10,
                          right: 10,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFe2b661),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          width: MediaQuery.of(context).size.width - 170,
                          height: MediaQuery.of(context).size.height - 255,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Interface(
              artist: playback.artistName,
              songName: playback.songName,
              progress: playback.progress,
              isPlaying: playback.isPlaying,
              isMuted: playback.isMuted,
              currentSliderValue: playback.currentSliderValue,
              onSeek: (duration) {
                playback.setProgress(duration);
                player.seek(duration);
              },
              onPlayPauseToggle: () {
                playback.setIsPlaying(!playback.isPlaying);
                if (!playback.isPlaying) {
                  player.pause();
                } else {
                  player.play();
                }
              },
              onToggleVolume: () {
                playback.setIsMuted(!playback.isMuted);
                player.setVolume(
                  playback.isMuted ? 0 : playback.currentSliderValue / 100,
                );
              },
              onPrevious: () => debugPrint("Previous"),
              onForward: () => debugPrint("Forward"),
              onVolumeChange: (value) {
                playback.setCurrentSliderValue(value);
                player.setVolume(value / 100);
              },
              duration: playback.duration,
            ),
          ),
        ],
      ),
    );
  }
}
