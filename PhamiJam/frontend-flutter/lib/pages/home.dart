import 'package:flutter/material.dart';
import '../components/sidebar.dart';
import '../components/interface.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/models/playback_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 170,
                          height: 45,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(230),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(16, 217, 213, 207),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
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
                          height: MediaQuery.of(context).size.height - 175,
                          child: Text(
                            "TBD...",
                            style: TextStyle(color: Colors.white, fontSize: 48),
                            textAlign: TextAlign.center,
                          ),
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
              isPlaying: _isPlaying,
              progress: _progress,
              currentSliderValue: _currentSliderValue,
              onPlayPauseToggle: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onPrevious: () => debugPrint("Previous"),
              onForward: () => debugPrint("Forward"),
              onSeek: (newProgress) {
                setState(() {
                  _progress = newProgress;
                });
              },
              onVolumeChange: (newVolume) {
                setState(() {
                  _currentSliderValue = newVolume;
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
