import 'package:flutter/material.dart';
import 'package:phamijam/components/interface.dart';
import 'package:phamijam/components/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/models/playback_model.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  double _currentSliderValue = 20.0;
  Duration _progress = Duration(seconds: 0);
  bool _isPlaying = false;

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
              artist:
                  playback.artistName.isNotEmpty
                      ? playback.artistName
                      : 'Unknown Artist',
              songName:
                  playback.songName.isNotEmpty
                      ? playback.songName
                      : 'Unknown Song',
              progress: _progress,
              isPlaying: _isPlaying,
              currentSliderValue: _currentSliderValue,
              onSeek: (duration) {
                setState(() {
                  _progress = duration;
                });
              },
              onPlayPauseToggle: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onPrevious: () => debugPrint("Previous"),
              onForward: () => debugPrint("Forward"),
              onVolumeChange: (value) {
                setState(() {
                  _currentSliderValue = value;
                  debugPrint("Volume: $_currentSliderValue");
                });
              },
              duration: null,
            ),
          ),
        ],
      ),
    );
  }
}
