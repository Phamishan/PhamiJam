import 'package:flutter/material.dart';
import 'package:phamijam/components/interface.dart';
import 'package:phamijam/components/sidebar.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:phamijam/models/playback_model.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/components/audio_player_singleton.dart';
import 'package:phamijam/controllers/user.dart';
import 'package:phamijam/pages/login.dart';

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<String> artistName = [];
  List<String> songName = [];
  List<String> songPaths = [];
  int? _currentlyPlayingIndex;
  String? username;
  bool _loadingUsername = true;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    final playback = Provider.of<PlaybackModel>(context, listen: false);

    _positionSubscription = player.positionStream.listen((position) {
      playback.setProgress(position);
    });
    _playerStateSubscription = player.playerStateStream.listen((state) {
      playback.setIsPlaying(state.playing);
    });
    player.durationStream.listen((duration) {
      playback.setDuration(duration);
    });
    _fetchUserInfo();
    _scanFilesPressed();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _loadingUsername = true;
    });
    String? token;
    try {
      token = await _secureStorage.read(key: 'token');
    } catch (e) {
      debugPrint('Error reading token from secure storage: $e');
    }
    if (token == null) {
      setState(() {
        _loadingUsername = false;
      });
      return debugPrint('Error: No token found');
    }
    try {
      final response = await HttpClient().getUrl(
        Uri.parse('http://localhost:3333/getUserInfo'),
      );
      response.headers.set('Authorization', 'Bearer $token');
      final httpResponse = await response.close();
      if (httpResponse.statusCode == 200) {
        final contents = await httpResponse.transform(utf8.decoder).join();
        final Map<String, dynamic> json = jsonDecode(contents);
        if (json['ok'] == true &&
            json['user'] != null &&
            json['user']['username'] != null) {
          setState(() {
            username = json['user']['username'];
            _loadingUsername = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
    setState(() {
      _loadingUsername = false;
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  void _logoutPressed() {
    context.read<UserController>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
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
    final playback = Provider.of<PlaybackModel>(context, listen: false);
    int playIndex = index ?? 0;

    if (songPaths.isNotEmpty && playIndex < songPaths.length) {
      final songPath = songPaths[playIndex];
      final file = File(songPath);

      if (await file.exists()) {
        playback.setDuration(Duration.zero);
        await player.setUrl(file.path);
        player.play();
        player.seek(Duration.zero);

        setState(() {
          _currentlyPlayingIndex = playIndex;
        });

        playback.setArtist(
          artistName.isNotEmpty ? artistName[playIndex] : 'Unknown Artist',
        );
        playback.setSongName(
          songName.isNotEmpty ? songName[playIndex] : 'Unknown Song',
        );
        playback.setIsPlaying(true);
        playback.setIsMuted(false);
      } else {
        debugPrint("File not found: $songPath");
      }
    }
  }

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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child:
                                    _loadingUsername
                                        ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                        : Text(
                                          username ?? "Username",
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
                                      onPressed: () {
                                        _logoutPressed();
                                      },
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
                                            color:
                                                _currentlyPlayingIndex == index
                                                    ? Color(0xFFb5832e)
                                                    : Color(0xFFdba43a),
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
                                              _play(index);
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
              duration: playback.duration,
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
            ),
          ),
        ],
      ),
    );
  }
}
