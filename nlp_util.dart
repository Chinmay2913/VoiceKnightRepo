import 'package:flutter_chess_board/flutter_chess_board.dart'; // Import the chess board library if not imported already
import 'package:collection/collection.dart';

enum PlayerColor { white, black }
enum PieceType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final PlayerColor color;
  final PieceType type;
  String position;

  ChessPiece({required this.color, required this.type, required this.position});
}


class NLPUtil {
    static final Map<String, String> pieceMap = {
    'pawn': 'P',
    'knight': 'N',
    'bishop': 'B',
    'rook': 'R',
    'queen': 'Q',
    'king': 'K',
  };
  

      // Store the current board state dynamically
  static List<ChessPiece> _currentBoardState = [];

  // Initialize the board state with an initial setup
  static void initializeBoard() {
    _currentBoardState.clear(); // Clear existing state if any
    _currentBoardState.addAll([
    // White pieces
    ChessPiece(color: PlayerColor.white, type: PieceType.pawn, position: 'c2'),
    ChessPiece(color: PlayerColor.white, type: PieceType.pawn, position: 'e2'),
    ChessPiece(color: PlayerColor.white, type: PieceType.knight, position: 'g1'),
    ChessPiece(color: PlayerColor.white, type: PieceType.knight, position: 'b1'),
    ChessPiece(color: PlayerColor.white, type: PieceType.rook, position: 'h1'),

    // Black pieces
    ChessPiece(color: PlayerColor.black, type: PieceType.pawn, position: 'c7'),
    ChessPiece(color: PlayerColor.black, type: PieceType.pawn, position: 'e7'),
    ChessPiece(color: PlayerColor.black, type: PieceType.knight, position: 'g8'),
    ChessPiece(color: PlayerColor.black, type: PieceType.knight, position: 'b8'),
      ChessPiece(color: PlayerColor.black, type: PieceType.rook, position: 'h8'),

    // Ambiguities
    ChessPiece(color: PlayerColor.white, type: PieceType.rook, position: 'd1'), // White rook on d1
    ChessPiece(color: PlayerColor.white, type: PieceType.rook, position: 'a1'), // White rook on a1
    ChessPiece(color: PlayerColor.black, type: PieceType.rook, position: 'd8'), // Black rook on d8
    ChessPiece(color: PlayerColor.black, type: PieceType.rook, position: 'a8'), // Black rook on a8

    ChessPiece(color: PlayerColor.white, type: PieceType.queen, position: 'd2'), // White queen on d2
    ChessPiece(color: PlayerColor.white, type: PieceType.queen, position: 'a1'), // White queen on a1
    ChessPiece(color: PlayerColor.black, type: PieceType.queen, position: 'd8'), // Black queen on d8
    ChessPiece(color: PlayerColor.black, type: PieceType.queen, position: 'a8'), // Black queen on a8

    ChessPiece(color: PlayerColor.white, type: PieceType.bishop, position: 'c1'), // White bishop on c1
    ChessPiece(color: PlayerColor.white, type: PieceType.bishop, position: 'f1'), // White bishop on f1
    ChessPiece(color: PlayerColor.black, type: PieceType.bishop, position: 'c8'), // Black bishop on c8
    ChessPiece(color: PlayerColor.black, type: PieceType.bishop, position: 'f8'), // Black bishop on f8
 
    ]);
  }

  // Update the board state after a move
 static void updateBoardState(String move) {
  if (move.length != 4) {
    throw FormatException('Invalid move format. Expected format: "e2e4"');
  }

  String fromSquare = move.substring(0, 2); // Start position
  String toSquare = move.substring(2, 4);   // End position

  // Find the piece that moved from 'fromSquare'
  ChessPiece? movedPiece = _currentBoardState.firstWhereOrNull((piece) => piece.position == fromSquare);

  if (movedPiece != null) {
    // Check if there is a piece already occupying 'toSquare'
    ChessPiece? capturedPiece = _currentBoardState.firstWhereOrNull((piece) => piece.position == toSquare);

    if (capturedPiece != null && capturedPiece.color != movedPiece.color) {
      // Remove the captured piece from the board state
      _currentBoardState.remove(capturedPiece);
    }

    // Update the position of the moved piece
    movedPiece.position = toSquare;
  } else {
    throw StateError('No piece found at position $fromSquare');
  }
}

  static String parseCommand(String command) {
  // Normalize the command string
  command = command.toLowerCase().trim();

  // Regular expressions to find move patterns
  final movePattern = RegExp(r'^([a-h][1-8])\s*to\s*([a-h][1-8])$');
  final pieceMovePattern = RegExp(r'^(\w+)\s*to\s*([a-h][1-8])$');
  final castlingPattern = RegExp(r'^castle\s*(kingside|queenside)$');
  final promotionPattern = RegExp(r'^pawn\s*to\s*([a-h][1-8])\s*and\s*promote\s*to\s*(\w+)$');

  // Attempt to match the command to known patterns
  if (movePattern.hasMatch(command)) {
    final match = movePattern.firstMatch(command);
    if (match != null) {
      return '${match.group(1)}${match.group(2)}';
    }
  } else if (pieceMovePattern.hasMatch(command)) {
    final match = pieceMovePattern.firstMatch(command);
    if (match != null) {
      final piece = match.group(1);
      final target = match.group(2);
      final pieceType = pieceMap.entries.firstWhereOrNull((entry) => entry.value == piece)?.key;
      if (pieceType != null) {
        return _resolveAmbiguity(pieceType, target!);
      }
    }
  } else if (castlingPattern.hasMatch(command)) {
    final match = castlingPattern.firstMatch(command);
    if (match != null) {
      final side = match.group(1) == 'kingside' ? 'O-O' : 'O-O-O';
      return side;
    }
  } else if (promotionPattern.hasMatch(command)) {
    final match = promotionPattern.firstMatch(command);
    if (match != null) {
      final target = match.group(1);
      final promotionPiece = pieceMap.entries.firstWhereOrNull((entry) => entry.value == match.group(2))?.value;
      if (promotionPiece != null) {
        return '${target}=${promotionPiece}';
      }
    }
  }

  // If no valid move pattern matched, return an empty string
  return '';
}


 static String _resolveAmbiguity(PieceType pieceType, String targetSquare) {
  // Find all pieces of the specified type that can move to the target square
  List<ChessPiece> matchingPieces = _currentBoardState.where((piece) {
    return piece.type == pieceType &&
           _canPieceMoveTo(piece, targetSquare);
  }).toList();

  // If there's exactly one matching piece, return its move
  if (matchingPieces.length == 1) {
    return '${pieceMap[pieceType]}${targetSquare}';
  }
  // If there are multiple matching pieces, further disambiguation is needed
  else if (matchingPieces.length > 1) {
    // Sort matching pieces by their position for clarity
    matchingPieces.sort((a, b) => a.position.compareTo(b.position));
    // Choose the first piece as a simple disambiguation example
    return '${pieceMap[pieceType]}${matchingPieces.first.position}'; // Example: Knight at g1 or b1 can move to targetSquare
  }
  // No matching pieces found
  else {
    return ''; // Could not resolve ambiguity
  }
}

  static bool _canPieceMoveTo(ChessPiece piece, String targetSquare) {
    // Extract the file (column) and rank (row) from the target square
    int targetFile = targetSquare.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int targetRank = int.parse(targetSquare.substring(1)) - 1;

    // Get the current position of the piece
    int currentFile = piece.position.codeUnitAt(0) - 'a'.codeUnitAt(0);
    int currentRank = int.parse(piece.position.substring(1)) - 1;

    // Check if the target square is within the piece's range of movement
    switch (piece.type) {
      case PieceType.pawn:
        // Pawn movement: can move one square forward, two squares on first move, capture diagonally
        int forwardDirection = piece.color == PlayerColor.white ? 1 : -1;
        // Regular move
        if (targetFile == currentFile && targetRank == currentRank + forwardDirection) {
          return true;
        }
        // Double move from starting position
        if (targetFile == currentFile && currentRank == (piece.color == PlayerColor.white ? 1 : 6) &&
            targetRank == currentRank + 2 * forwardDirection) {
          return true;
        }
        // Capture diagonally
        if ((targetFile == currentFile + 1 || targetFile == currentFile - 1) &&
            targetRank == currentRank + forwardDirection) {
          return true;
        }
        return false;
      case PieceType.knight:
        // Knight moves in an L-shape: 2 squares in one direction and then 1 square perpendicular
        int fileDiff = (targetFile - currentFile).abs();
        int rankDiff = (targetRank - currentRank).abs();
        return (fileDiff == 1 && rankDiff == 2) || (fileDiff == 2 && rankDiff == 1);
      case PieceType.bishop:
        // Bishop moves diagonally any number of squares
        return (targetFile - currentFile).abs() == (targetRank - currentRank).abs();
      case PieceType.rook:
        // Rook moves horizontally or vertically any number of squares
        return targetFile == currentFile || targetRank == currentRank;
      case PieceType.queen:
        // Queen moves like a rook or a bishop: horizontally, vertically, or diagonally
        return (targetFile == currentFile || targetRank == currentRank) ||
               ((targetFile - currentFile).abs() == (targetRank - currentRank).abs());
      case PieceType.king:
        // King moves one square in any direction
        int fileDiff = (targetFile - currentFile).abs();
        int rankDiff = (targetRank - currentRank).abs();
        return fileDiff <= 1 && rankDiff <= 1;
      default:
        return false;
    }
  }
}
