import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/song.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../utils/constants.dart';

class MusicApiService {
  final Dio _dio;
  final String baseUrl = AppConstants.apiBaseUrl;
  
  MusicApiService() : _dio = Dio() {
    // Add CORS headers to all requests
    _dio.options.headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type',
    };
  }
  
  Future<List<Song>> fetchSongs() async {
    try {
      final response = await _dio.get('$baseUrl/songs');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Future.wait(
          data.map((songData) async {
            // Get detailed song data including URL
            final song = Song.fromJson(songData);
            final details = await fetchSongDetails(song.id);
            return details ?? song;
          })
        );
      } else {
        throw Exception('Failed to fetch songs: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching songs: $e');
      }
      return [];
    }
  }
  
  Future<List<Album>> fetchAlbums() async {
    try {
      final response = await _dio.get('$baseUrl/albums');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return Future.wait(
          data.map((albumData) async {
            // Get detailed album data including cover URL and songs
            final album = Album.fromJson(albumData);
            final details = await fetchAlbumDetails(album.id);
            return details ?? album;
          })
        );
      } else {
        throw Exception('Failed to fetch albums: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching albums: $e');
      }
      return [];
    }
  }
  
  Future<List<Artist>> fetchArtists() async {
    try {
      final response = await _dio.get('$baseUrl/artists');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((artistData) => Artist.fromJson(artistData)).toList();
      } else {
        throw Exception('Failed to fetch artists: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching artists: $e');
      }
      return [];
    }
  }
  
  Future<Song?> fetchSongDetails(int id) async {
    try {
      final response = await _dio.get('$baseUrl/songs/$id');
      
      if (response.statusCode == 200) {
        return Song.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch song details: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching song details: $e');
      }
      return null;
    }
  }
  
  Future<Album?> fetchAlbumDetails(int id) async {
    try {
      final response = await _dio.get('$baseUrl/albums/$id');

      if (response.statusCode == 200) {
        return Album.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch album details: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching album details: $e');
      }
      return null;
    }
  }
  
  Future<Artist?> fetchArtistDetails(int id) async {
    try {
      final response = await _dio.get('$baseUrl/artists/$id');
      
      if (response.statusCode == 200) {
        return Artist.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch artist details: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching artist details: $e');
      }
      return null;
    }
  }
}