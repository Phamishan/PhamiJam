import 'package:flutter/material.dart';
import 'package:phamijam/result.dart';
import '../client.dart';

class SongTile extends StatelessWidget {
  final Map<String, dynamic> song;
  final String token;
  final Client client;

  const SongTile({
    super.key,
    required this.song,
    required this.token,
    required this.client,
  });

  Future<void> _showAddToPlaylistMenu(
    BuildContext context,
    Offset globalPosition,
  ) async {
    final playlistsResult = await client.getPlaylists(token);
    if (playlistsResult is Err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load playlists: ${(playlistsResult as Err).message}",
          ),
        ),
      );
      return;
    }
    final playlists = (playlistsResult as Ok<List<Map<String, dynamic>>>).data;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: [
        if (playlists.isEmpty)
          const PopupMenuItem<String>(value: '', child: Text('No playlists')),
        for (final p in playlists)
          PopupMenuItem<String>(
            value: p['id'].toString(),
            child: Text(p['title']?.toString() ?? 'Untitled'),
          ),
      ],
    );

    if (selected == null || selected.isEmpty) return;

    final res = await client.addSongToPlaylist(
      token,
      selected,
      song['id'].toString(),
    );
    if (res is Ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Song added to playlist')));
    } else {
      final err = (res as Err).message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add song: $err')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) {
        _showAddToPlaylistMenu(context, details.globalPosition);
      },
      child: ListTile(
        title: Text(song['title']?.toString() ?? 'Unknown'),
        subtitle: Text(song['artist']?.toString() ?? ''),
        // keep existing onTap / trailing actions as needed
      ),
    );
  }
}
