import 'package:cloud_firestore/cloud_firestore.dart';
import '../QuizModel.dart';

class FirebaseMultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available rooms
  Stream<List<MultiplayerRoom>> getAvailableRooms() {
    return _firestore
        .collection('multiplayer_rooms')
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MultiplayerRoom.fromFirestore(doc))
          .toList(),
    );
  }

  // Create a new room
  Future<String?> createRoom({
    required String quizId,
    required String hostId,
    required String hostName,
    int maxPlayers = 10,
  }) async {
    try {
      MultiplayerRoom room = MultiplayerRoom(
        id: '',
        quizId: quizId,
        hostId: hostId,
        hostName: hostName,
        playerIds: [hostId],
        playerNames: [hostName],
        maxPlayers: maxPlayers,
        status: 'waiting',
        createdAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore.collection('multiplayer_rooms').add(room.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  // Join a room
  Future<bool> joinRoom({
    required String roomId,
    required String playerId,
    required String playerName,
  }) async {
    try {
      DocumentReference roomRef = _firestore.collection('multiplayer_rooms').doc(roomId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot roomSnapshot = await transaction.get(roomRef);

        if (!roomSnapshot.exists) {
          throw Exception('Room does not exist');
        }

        MultiplayerRoom room = MultiplayerRoom.fromFirestore(roomSnapshot);

        if (room.currentPlayers >= room.maxPlayers) {
          throw Exception('Room is full');
        }

        if (room.playerIds.contains(playerId)) {
          throw Exception('Already in room');
        }

        List<String> newPlayerIds = List.from(room.playerIds)..add(playerId);
        List<String> newPlayerNames = List.from(room.playerNames)..add(playerName);

        transaction.update(roomRef, {
          'playerIds': newPlayerIds,
          'playerNames': newPlayerNames,
        });
      });

      return true;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  // Leave a room
  Future<bool> leaveRoom({
    required String roomId,
    required String playerId,
  }) async {
    try {
      DocumentReference roomRef = _firestore.collection('multiplayer_rooms').doc(roomId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot roomSnapshot = await transaction.get(roomRef);

        if (!roomSnapshot.exists) {
          throw Exception('Room does not exist');
        }

        MultiplayerRoom room = MultiplayerRoom.fromFirestore(roomSnapshot);

        List<String> newPlayerIds = List.from(room.playerIds)..remove(playerId);
        int playerIndex = room.playerIds.indexOf(playerId);
        List<String> newPlayerNames = List.from(room.playerNames)..removeAt(playerIndex);

        if (newPlayerIds.isEmpty) {
          // Delete room if no players left
          transaction.delete(roomRef);
        } else {
          transaction.update(roomRef, {
            'playerIds': newPlayerIds,
            'playerNames': newPlayerNames,
          });
        }
      });

      return true;
    } catch (e) {
      print('Error leaving room: $e');
      return false;
    }
  }

  // Get room details (real-time)
  Stream<MultiplayerRoom?> getRoomStream(String roomId) {
    return _firestore
        .collection('multiplayer_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return MultiplayerRoom.fromFirestore(doc);
      }
      return null;
    });
  }

  // Start game
  Future<bool> startGame(String roomId) async {
    try {
      await _firestore.collection('multiplayer_rooms').doc(roomId).update({
        'status': 'playing',
      });
      return true;
    } catch (e) {
      print('Error starting game: $e');
      return false;
    }
  }

  // End game
  Future<bool> endGame(String roomId) async {
    try {
      await _firestore.collection('multiplayer_rooms').doc(roomId).update({
        'status': 'finished',
      });
      return true;
    } catch (e) {
      print('Error ending game: $e');
      return false;
    }
  }
}
