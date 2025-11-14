import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/sidebar.dart';
import '../components/interface.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/models/playback_model.dart';
import 'package:phamijam/components/audio_player_singleton.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:just_audio/just_audio.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAndPlay(String query, PlaybackModel playback) async {
    if (query.trim().isEmpty) return;
    final yt = YoutubeExplode();
    try {
      final videos = await yt.search.getVideos(query);
      final video = videos.first;
      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      final url = audioStream.url.toString();

      playback.setArtist(video.author ?? 'YouTube');
      playback.setSongName(video.title);
      playback.setDuration(video.duration ?? Duration.zero);

      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await player.play();
      playback.setIsPlaying(true);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('decipher') || msg.contains('player')) {
        await _searchAndPlayViaBackend(query, playback);
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search/play failed: $e')));
    } finally {
      yt.close();
    }
  }

  Future<void> _searchAndPlayViaBackend(
    String query,
    PlaybackModel playback,
  ) async {
    try {
      final backendUrl = Uri.parse(
        'http://localhost:3333/yt-audio?query=${Uri.encodeComponent(query)}',
      );
      final httpResp = await http.get(backendUrl);
      if (httpResp.statusCode != 200)
        throw Exception('Backend failed: ${httpResp.statusCode}');
      final body = jsonDecode(httpResp.body) as Map<String, dynamic>;
      final url = body['url'] as String;
      playback.setArtist(body['author'] ?? 'YouTube');
      playback.setSongName(body['title'] ?? query);
      playback.setDuration(
        Duration(milliseconds: (body['duration_ms'] ?? 0) as int),
      );

      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await player.play();
      playback.setIsPlaying(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backend fallback failed: $e')));
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 170,
                          height: 45,
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (q) => _searchAndPlay(q, playback),
                            decoration: InputDecoration(
                              hintText: 'Search YouTube',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(16, 217, 213, 207),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white54,
                                  width: 1.0,
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search, color: Colors.white),
                                onPressed:
                                    () => _searchAndPlay(
                                      _searchController.text,
                                      playback,
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
