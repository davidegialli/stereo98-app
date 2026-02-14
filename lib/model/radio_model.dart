// To parse this JSON data, do
//
//     final radioModel = radioModelFromJson(jsonString);

import 'dart:convert';

RadioModel radioModelFromJson(String str) =>
    RadioModel.fromJson(json.decode(str));

String radioModelToJson(RadioModel data) => json.encode(data.toJson());

class RadioModel {
  RadioModel({
    this.station,
    this.listeners,
    this.live,
    this.nowPlaying,
    this.playingNext,
    this.songHistory,
    this.isOnline,
    this.cache,
  });

  Station? station;
  Listeners? listeners;
  Live? live;
  NowPlaying? nowPlaying;
  PlayingNext? playingNext;
  List<NowPlaying>? songHistory;
  bool? isOnline;
  dynamic cache;

  factory RadioModel.fromJson(Map<String, dynamic> json) => RadioModel(
        station: Station.fromJson(json["station"]),
        listeners: Listeners.fromJson(json["listeners"]),
        live: Live.fromJson(json["live"]),
        nowPlaying: NowPlaying.fromJson(json["now_playing"]),
        playingNext: PlayingNext.fromJson(json["playing_next"]),
        songHistory: List<NowPlaying>.from(
            json["song_history"].map((x) => NowPlaying.fromJson(x))),
        isOnline: json["is_online"],
        cache: json["cache"],
      );

  Map<String, dynamic> toJson() => {
        "station": station!.toJson(),
        "listeners": listeners?.toJson(),
        "live": live!.toJson(),
        "now_playing": nowPlaying!.toJson(),
        "playing_next": playingNext!.toJson(),
        "song_history": List<dynamic>.from(songHistory!.map((x) => x.toJson())),
        "is_online": isOnline,
        "cache": cache,
      };
}

class Listeners {
  Listeners({
    this.total,
    this.unique,
    this.current,
  });

  int? total;
  int? unique;
  int? current;

  factory Listeners.fromJson(Map<String, dynamic> json) => Listeners(
        total: json["total"],
        unique: json["unique"],
        current: json["current"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "unique": unique,
        "current": current,
      };
}

class Live {
  Live({
    this.isLive,
    this.streamerName,
    this.broadcastStart,
    this.art,
  });

  bool? isLive;
  String? streamerName;
  dynamic broadcastStart;
  dynamic art;

  factory Live.fromJson(Map<String, dynamic> json) => Live(
        isLive: json["is_live"],
        streamerName: json["streamer_name"],
        broadcastStart: json["broadcast_start"],
        art: json["art"],
      );

  Map<String, dynamic> toJson() => {
        "is_live": isLive,
        "streamer_name": streamerName,
        "broadcast_start": broadcastStart,
        "art": art,
      };
}

class NowPlaying {
  NowPlaying({
    this.shId,
    this.playedAt,
    this.duration,
    this.playlist,
    this.streamer,
    this.isRequest,
    this.song,
    this.elapsed,
    this.remaining,
  });

  int? shId;
  int? playedAt;
  int? duration;
  Playlist? playlist;
  String? streamer;
  bool? isRequest;
  Song? song;
  int? elapsed;
  int? remaining;

  factory NowPlaying.fromJson(Map<String, dynamic> json) => NowPlaying(
        shId: json["sh_id"],
        playedAt: json["played_at"],
        duration: json["duration"],
        playlist: playlistValues.map![json["playlist"]],
        streamer: json["streamer"],
        isRequest: json["is_request"],
        song: Song.fromJson(json["song"]),
        elapsed: json["elapsed"] ?? "",
        remaining: json["remaining"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "sh_id": shId,
        "played_at": playedAt,
        "duration": duration,
        "playlist": playlistValues.reverse![playlist],
        "streamer": streamer,
        "is_request": isRequest,
        "song": song!.toJson(),
        "elapsed": elapsed,
        "remaining": remaining,
      };
}

// ignore: constant_identifier_names
enum Playlist { A_RAVE_LINK_C_LIST, A_RAVE_LINK_A_LIST, A_RAVE_LINK_B_LIST }

final playlistValues = EnumValues({
  "A-RaveLink - A  List": Playlist.A_RAVE_LINK_A_LIST,
  "A-RaveLink - B List": Playlist.A_RAVE_LINK_B_LIST,
  "A-RaveLink - C List": Playlist.A_RAVE_LINK_C_LIST
});

class Song {
  Song({
    this.id,
    this.text,
    required this.artist,
    required this.title,
    this.album,
    this.genre,
    this.isrc,
    this.lyrics,
    this.art,
    this.customFields,
  });

  String? id;
  String? text;
  String artist;
  String title;
  String? album;
  String? genre;
  String? isrc;
  String? lyrics;
  String? art;
  CustomFields? customFields;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json["id"],
        text: json["text"],
        artist: json["artist"] ?? 'Artist',
        title: json["title"] ?? 'Title',
        album: json["album"],
        genre: json["genre"],
        isrc: json["isrc"],
        lyrics: json["lyrics"],
        art: json["art"],
        customFields: CustomFields.fromJson(json["custom_fields"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "artist": artist,
        "title": title,
        "album": album,
        "genre": genre,
        "isrc": isrc,
        "lyrics": lyrics,
        "art": art,
        "custom_fields": customFields!.toJson(),
      };
}

class CustomFields {
  CustomFields({
    this.twitteruser,
  });

  dynamic twitteruser;

  factory CustomFields.fromJson(Map<String, dynamic> json) => CustomFields(
        twitteruser: json["twitteruser"],
      );

  Map<String, dynamic> toJson() => {
        "twitteruser": twitteruser,
      };
}

class PlayingNext {
  PlayingNext({
    this.cuedAt,
    this.playedAt,
    this.duration,
    this.playlist,
    this.isRequest,
    this.song,
  });

  int? cuedAt;
  int? playedAt;
  int? duration;
  Playlist? playlist;
  bool? isRequest;
  Song? song;

  factory PlayingNext.fromJson(Map<String, dynamic> json) => PlayingNext(
        cuedAt: json["cued_at"],
        playedAt: json["played_at"],
        duration: json["duration"],
        playlist: playlistValues.map![json["playlist"]],
        isRequest: json["is_request"],
        song: Song.fromJson(json["song"]),
      );

  Map<String, dynamic> toJson() => {
        "cued_at": cuedAt,
        "played_at": playedAt,
        "duration": duration,
        "playlist": playlistValues.reverse![playlist],
        "is_request": isRequest,
        "song": song!.toJson(),
      };
}

class Station {
  Station({
    this.id,
    this.name,
    this.shortcode,
    this.description,
    this.frontend,
    this.backend,
    this.listenUrl,
    this.url,
    this.publicPlayerUrl,
    this.playlistPlsUrl,
    this.playlistM3UUrl,
    this.isPublic,
    this.mounts,
    this.remotes,
    this.hlsEnabled,
    this.hlsUrl,
  });

  int? id;
  String? name;
  String? shortcode;
  String? description;
  String? frontend;
  String? backend;
  String? listenUrl;
  String? url;
  String? publicPlayerUrl;
  String? playlistPlsUrl;
  String? playlistM3UUrl;
  bool? isPublic;
  List<Mount>? mounts;
  List<dynamic>? remotes;
  bool? hlsEnabled;
  String? hlsUrl;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        id: json["id"],
        name: json["name"],
        shortcode: json["shortcode"],
        description: json["description"],
        frontend: json["frontend"],
        backend: json["backend"],
        listenUrl: json["listen_url"],
        url: json["url"],
        publicPlayerUrl: json["public_player_url"],
        playlistPlsUrl: json["playlist_pls_url"],
        playlistM3UUrl: json["playlist_m3u_url"],
        isPublic: json["is_public"],
        mounts: List<Mount>.from(json["mounts"].map((x) => Mount.fromJson(x))),
        remotes: List<dynamic>.from(json["remotes"].map((x) => x)),
        hlsEnabled: json["hls_enabled"],
        hlsUrl: json["hls_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "shortcode": shortcode,
        "description": description,
        "frontend": frontend,
        "backend": backend,
        "listen_url": listenUrl,
        "url": url,
        "public_player_url": publicPlayerUrl,
        "playlist_pls_url": playlistPlsUrl,
        "playlist_m3u_url": playlistM3UUrl,
        "is_public": isPublic,
        "mounts": List<dynamic>.from(mounts!.map((x) => x.toJson())),
        "remotes": List<dynamic>.from(remotes!.map((x) => x)),
        "hls_enabled": hlsEnabled,
        "hls_url": hlsUrl,
      };
}

class Mount {
  Mount({
    this.id,
    this.name,
    this.url,
    this.bitrate,
    this.format,
    this.listeners,
    this.path,
    this.isDefault,
  });

  int? id;
  String? name;
  String? url;
  int? bitrate;
  String? format;
  Listeners? listeners;
  String? path;
  bool? isDefault;

  factory Mount.fromJson(Map<String, dynamic> json) => Mount(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        bitrate: json["bitrate"],
        format: json["format"],
        listeners: Listeners.fromJson(json["listeners"]),
        path: json["path"],
        isDefault: json["is_default"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "url": url,
        "bitrate": bitrate,
        "format": format,
        "listeners": listeners?.toJson(),
        "path": path,
        "is_default": isDefault,
      };
}

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    reverseMap ??= map!.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
