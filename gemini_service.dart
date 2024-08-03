import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  final String apiUrl = 'https://api.gemini.com/v1'; // Base URL for the API
  static const String apiKey = 'AIzaSyDm_jJUJB5Bq9x47yjtOLXHntz7KIFqUOA'; // Static API key for authentication

  /// Sends a voice command to the Gemini service and returns the corresponding chess move.
  Future<String> sendCommand(String command) async {
    final response = await http.post(
      Uri.parse('$apiUrl/send_command'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
      body: jsonEncode({'command': command}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['move'];
    } else {
      throw Exception('Failed to send command to Gemini');
    }
  }

  /// Gets the opponent's move based on the current game's PGN (Portable Game Notation).
  Future<String> getOpponentMove(String pgn) async {
    final response = await http.post(
      Uri.parse('$apiUrl/get_opponent_move'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
      body: jsonEncode({'pgn': pgn}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['move'];
    } else {
      throw Exception('Failed to get opponent move from Gemini');
    }
  }

  /// Retrieves the current game state given a game ID.
  Future<Map<String, dynamic>> getGameState(String gameId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/get_game_state/$gameId'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to get game state from Gemini');
    }
  }

  /// Saves a move to the Gemini service for a given game ID.
  Future<void> saveMove(String gameId, String move) async {
    final response = await http.post(
      Uri.parse('$apiUrl/save_move'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
      body: jsonEncode({'gameId': gameId, 'move': move}),
    );

    if (response.statusCode == 200) {
      // Move saved successfully
      print('Move saved successfully');
    } else {
      throw Exception('Failed to save move to Gemini');
    }
  }

  /// Ends the game for a given game ID.
  Future<void> endGame(String gameId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/end_game'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
      body: jsonEncode({'gameId': gameId}),
    );

    if (response.statusCode == 200) {
      // Game ended successfully
      print('Game ended successfully');
    } else {
      throw Exception('Failed to end game in Gemini');
    }
  }

  Future<List<dynamic>> getOrderBook(String symbol) async {
    final response = await http.get(
      Uri.parse('$apiUrl/book/$symbol'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bids']; // or data['asks'] for asks
    } else {
      throw Exception('Failed to get order book from Gemini: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getTicker(String symbol) async {
    final response = await http.get(
      Uri.parse('$apiUrl/pubticker/$symbol'),
      headers: {
        'Content-Type': 'application/json',
        'X-GEMINI-APIKEY': apiKey, // Include the API key in the headers
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to get ticker from Gemini: ${response.body}');
    }
  }
}
