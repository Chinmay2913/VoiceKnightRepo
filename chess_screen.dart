import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'game_service.dart';
import 'gemini_service.dart';
import 'nlp_util.dart';

class ChessScreen extends StatefulWidget {
  @override
  _ChessScreenState createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  final ChessBoardController controller = ChessBoardController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _command = '';
  final GameService gameService = GameService();
  final GeminiService geminiService = GeminiService();
  final String gameId = 'sample_game_id'; // Example game ID

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognizer();
    // _loadGameState();
  }

  void _initializeSpeechRecognizer() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {});
    }
  }
 void _initializeSpeechRecognizer() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {});
    }
 }

  void _loadGameState() {
    gameService.getGameStream(gameId).listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        List<String> moves = List<String>.from(snapshot.get('moves'));
        controller.loadMovesFromPGN(moves.join(' '));
      }
    });
  }

  void _startListening() {
    if (!_isListening) {
      _speech.listen(onResult: (result) {
        _command = result.recognizedWords;
        if (result.finalResult) {
          _processCommand(_command);
          _isListening = false;
          _speech.stop();
        }
      });
      setState(() {
        _isListening = true;
      });
    }
  }

  void _processCommand(String command) async {
    String move = NLPUtil.parseCommand(command);
    if (move.isNotEmpty ) {//&& controller.isMoveValid(move)
      try {
        controller.makeMove(move);
        gameService.saveMove(gameId, move);
        geminiService.sendCommand(command);

         // Get and make the opponent's move
         String pgn = controller.getPGN();
        String opponentMove = await geminiService.getOpponentMove(pgn);
        controller.makeMove(opponentMove);
        gameService.saveMove(gameId, opponentMove);
      } catch (e) {
        // Handle invalid moves
        print("Invalid move: $move");
        _showErrorDialog("Invalid move: $command");
      }
    } else {
      print("Invalid command: $command");
      _showErrorDialog("Could not understand the command: $command");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Controlled Chess'),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _startListening,
          ),
        ],
      ),
      body: Center(
        child: ChessBoard(
          controller: controller,
          boardColor: BoardColor.brown,
          boardOrientation: PlayerColor.white,
        ),
      ),
    );
  }
}
