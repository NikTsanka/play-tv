import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/preferences.dart';
import 'channel.dart';
import 'storage/channel_repository.dart';
import 'storage/database.dart' as db;

/// The drift database (singleton, closed with the scope).
final appDatabaseProvider = Provider<db.AppDatabase>((ref) {
  final database = db.AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final channelRepositoryProvider = Provider<ChannelRepository>((ref) {
  return ChannelRepository(ref.watch(appDatabaseProvider));
});

/// All known playlists/sources.
final playlistsProvider = StreamProvider<List<db.Playlist>>((ref) {
  return ref.watch(channelRepositoryProvider).watchPlaylists();
});

/// The selected source id (persisted). Falls back to the first playlist.
class CurrentPlaylistController extends Notifier<int?> {
  @override
  int? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getInt(PrefKeys.currentPlaylist);

    // Auto-select the first available playlist when nothing valid is stored.
    final playlists = ref.watch(playlistsProvider).valueOrNull;
    if (playlists != null && playlists.isNotEmpty) {
      final ids = playlists.map((p) => p.id).toSet();
      if (stored != null && ids.contains(stored)) return stored;
      return playlists.first.id;
    }
    return stored;
  }

  Future<void> select(int id) async {
    state = id;
    await ref.read(sharedPreferencesProvider).setInt(PrefKeys.currentPlaylist, id);
  }
}

final currentPlaylistProvider =
    NotifierProvider<CurrentPlaylistController, int?>(CurrentPlaylistController.new);

/// Channels of the current playlist, ordered. Empty until a playlist exists.
final currentChannelsProvider = StreamProvider<List<Channel>>((ref) {
  final id = ref.watch(currentPlaylistProvider);
  if (id == null) return Stream<List<Channel>>.value(const <Channel>[]);
  return ref.watch(channelRepositoryProvider).watchChannels(id);
});

/// Flat ordered channel list used by the zapping controller.
final flatChannelsProvider = Provider<List<Channel>>((ref) {
  return ref.watch(currentChannelsProvider).valueOrNull ?? const <Channel>[];
});
