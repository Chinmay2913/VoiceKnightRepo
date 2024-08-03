import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void saveMove(String gameId, String move) {
    _firestore.collection('games').doc(gameId).update({
      'moves': FieldValue.arrayUnion([move])
    });
  }

  Stream<DocumentSnapshot> getGameStream(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }
}
