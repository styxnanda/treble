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
        return data.map((songData) => Song.fromJson(songData)).toList();
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
        return data.map((albumData) => Album.fromJson(albumData)).toList();
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
  
  Future<Album?> fetchAlbumDetails(String name) async {
    try {
      final response = await _dio.get('$baseUrl/album/$name');
      
      if (response.statusCode == 200) {
        if (response.data == null) return null;
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
  
  Future<Artist?> fetchArtistDetails(String name) async {
    try {
      final response = await _dio.get('$baseUrl/artist/$name');
      
      if (response.statusCode == 200) {
        if (response.data == null) return null;
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
  
  Future<String?> getSongStreamUrl(String songPath) async {
    try {
      // Encode the path to make it URL-safe
      final encodedPath = Uri.encodeComponent(songPath);
      final response = await _dio.get('$baseUrl/song/$encodedPath');
      
      if (response.statusCode == 200) {
        // Extract the URL from the response data
        final responseData = response.data;
        if (responseData is Map && responseData.containsKey('url')) {
          return responseData['url'] as String;
        } else {
          throw Exception('Invalid response format: URL field not found');
        }
      } else {
        throw Exception('Failed to get song URL: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting song URL: $e');
      }
      return null;
    }
  }
}