import 'package:flutter/material.dart';
import 'package:phamijam/components/interface.dart';
import 'package:phamijam/components/sidebar.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

final player = AudioPlayer();

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  double _currentSliderValue = 20.0;
  Duration _progress = Duration(seconds: 0);
  Duration? _duration;
  bool _isPlaying = false;

  List<String> artistName = [];
  List<String> songName = [];
  List<String> songPaths = [];
  int? _currentlyPlayingIndex;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _positionSubscription = player.positionStream.listen((position) {
      setState(() {
        _progress = position;
        debugPrint("Progress updated: $_progress");
      });
    });
    _playerStateSubscription = player.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });
    player.durationStream.listen((duration) {
      setState(() {
        _duration = duration;
        debugPrint("Duration updated: $_duration");
      });
    });
    _scanFilesPressed();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> _scanFilesPressed() async {
    Directory? musicDir;

    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        musicDir = Directory('$userProfile\\Music');
      }
    } else if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        musicDir = Directory('$home/Music');
      }
    } else if (Platform.isAndroid) {
      musicDir = Directory('/storage/emulated/0/Music');
    } else if (Platform.isIOS) {
      musicDir = await getApplicationDocumentsDirectory();
    }

    if (musicDir != null && await musicDir.exists()) {
      final mp3Files =
          musicDir
              .listSync(recursive: true)
              .where((f) => f is File && f.path.toLowerCase().endsWith('.mp3'))
              .toList();

      List<String> foundSongNames = [];
      List<String> foundArtistNames = [];
      List<String> foundSongPaths = [];

      for (var file in mp3Files) {
        foundSongNames.add(file.uri.pathSegments.last);
        foundArtistNames.add('Unknown Artist');
        foundSongPaths.add((file as File).path);
      }

      for (var i = 0; i < foundSongNames.length; i++) {
        final track = File(foundSongPaths[i]);
        final metadata = readMetadata(track, getImage: false);
        if (metadata.artist != null) {
          foundArtistNames[i] = metadata.artist!;
        }
        if (metadata.title != null) {
          foundSongNames[i] = metadata.title!;
        }
      }

      setState(() {
        songName = foundSongNames;
        artistName = foundArtistNames;
        songPaths = foundSongPaths;
      });

      debugPrint("Found ${songName.length} songs in local Music folder");
    } else {
      debugPrint("Music directory not found");
    }
  }

  Future<void> _play([int? index]) async {
    debugPrint("Play button pressed");
    int playIndex = index ?? 0;

    if (songPaths.isNotEmpty && playIndex < songPaths.length) {
      final songPath = songPaths[playIndex];
      final file = File(songPath);

      if (await file.exists()) {
        setState(() {
          _duration = Duration.zero;
        });
        await player.setUrl(file.path);
        debugPrint("Playing: $songPath");
        player.play();
        player.seek(Duration.zero);

        setState(() {
          _currentlyPlayingIndex = playIndex;
        });
      } else {
        debugPrint("File not found: $songPath");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "Username",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () => debugPrint("Previous"),
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _scanFilesPressed,
                                      icon: Icon(
                                        Icons.document_scanner,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => debugPrint("Previous"),
                                      icon: Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                          height: MediaQuery.of(context).size.height - 255,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Loaded songs:",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        artistName.isNotEmpty
                                            ? artistName.length
                                            : 0,
                                    itemBuilder: (context, index) {
                                      final artist =
                                          artistName.isNotEmpty
                                              ? artistName[index]
                                              : 'Artist ${index + 1}';
                                      final song =
                                          songName.isNotEmpty
                                              ? songName[index]
                                              : 'Song ${index + 1}';
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFdba43a),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              song,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              artist,
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            trailing: Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _isPlaying = true;
                                              });
                                              _play(index);
                                              player.play();
                                              player.setVolume(0.1);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
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
                  artistName.isNotEmpty
                      ? artistName[_currentlyPlayingIndex ?? 0]
                      : 'Unknown Artist',
              songName:
                  songName.isNotEmpty
                      ? songName[_currentlyPlayingIndex ?? 0]
                      : 'Unknown Song',
              progress: _progress,
              isPlaying: _isPlaying,
              currentSliderValue: _currentSliderValue,
              onSeek: (duration) {
                setState(() {
                  _progress = duration;
                  player.seek(duration);
                  debugPrint("Seek to: $duration");
                });
              },
              duration: _duration,
              onPlayPauseToggle: () {
                setState(() {
                  _isPlaying = !_isPlaying;

                  if (!_isPlaying) {
                    player.pause();
                  } else {
                    player.play();
                  }
                });
              },
              onPrevious: () => debugPrint("Previous"),
              onForward: () => debugPrint("Forward"),
              onVolumeChange: (value) {
                setState(() {
                  _currentSliderValue = value;
                  player.setVolume(0.1);
                  debugPrint("Volume2: ${_currentSliderValue / 100}");
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
