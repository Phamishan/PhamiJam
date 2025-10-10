import 'package:flutter/material.dart';
import 'package:phamijam/components/interface.dart';
import 'package:phamijam/components/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:phamijam/models/playback_model.dart';
import 'package:phamijam/components/audio_player_singleton.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<String> playlistName = [];
  List<String> playlistDescription = [];
  List<String?> playlistCoverPaths = [];
  int? _currentlyPlayingIndex;

  bool get isDesktop {
    if (kIsWeb) return false;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }

  void _showCreatePlaylistDialog() {
    final _formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    String? coverImagePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Playlist'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        onChanged: (value) => title = value,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter a title'
                                    : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) => description = value,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          if (isDesktop)
                            ElevatedButton.icon(
                              icon: Icon(Icons.image),
                              label: Text('Upload Cover'),
                              onPressed: () async {
                                FilePickerResult? result = await FilePicker
                                    .platform
                                    .pickFiles(type: FileType.image);
                                if (result != null &&
                                    result.files.single.path != null) {
                                  setState(() {
                                    coverImagePath = result.files.single.path!;
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                      if (kIsWeb || Platform.isAndroid || Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Cover upload is only available on desktop.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Create'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    playlistName.add(title);
                    playlistDescription.add(description);
                    playlistCoverPaths.add(coverImagePath);
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = Provider.of<PlaybackModel>(context);
    final double sidebarWidth = 150;

    return Scaffold(
      backgroundColor: Color(0xFFdba43a),
      body: Stack(
        children: [
          Align(alignment: Alignment.topLeft, child: Sidebar()),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - sidebarWidth,
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 5,
                      top: 10,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search',
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
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        IconButton(
                          onPressed: _showCreatePlaylistDialog,
                          icon: Icon(
                            Icons.playlist_add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 7,
                      top: 5,
                      left: 10,
                      right: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFe2b661),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height - 175,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Playlists:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    playlistName.isNotEmpty
                                        ? playlistName.length
                                        : 0,
                                itemBuilder: (context, index) {
                                  final artist =
                                      playlistDescription.isNotEmpty
                                          ? playlistDescription[index]
                                          : 'Artist ${index + 1}';
                                  final song =
                                      playlistName.isNotEmpty
                                          ? playlistName[index]
                                          : 'Song ${index + 1}';
                                  final coverPath =
                                      playlistCoverPaths.length > index
                                          ? playlistCoverPaths[index]
                                          : null;
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: GestureDetector(
                                      onSecondaryTapDown: (details) async {
                                        final selected = await showMenu(
                                          context: context,
                                          position: RelativeRect.fromLTRB(
                                            details.globalPosition.dx,
                                            details.globalPosition.dy,
                                            details.globalPosition.dx,
                                            details.globalPosition.dy,
                                          ),
                                          items: [
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        );
                                        if (selected == 'delete') {
                                          setState(() {
                                            playlistName.removeAt(index);
                                            playlistDescription.removeAt(index);
                                            playlistCoverPaths.removeAt(index);
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 96,
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
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 16,
                                          ),
                                          leading:
                                              coverPath != null
                                                  ? Image.file(
                                                    File(coverPath),
                                                    width: 48,
                                                    height: 48,
                                                    fit: BoxFit.cover,
                                                  )
                                                  : Container(
                                                    width: 48,
                                                    height: 48,
                                                    color: Colors.grey[400],
                                                    child: Icon(
                                                      Icons.music_note,
                                                      color: Colors.white,
                                                    ),
                                                  ),
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
                                            // _play(index);
                                          },
                                        ),
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
