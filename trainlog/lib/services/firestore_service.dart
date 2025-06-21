import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _tripsCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser?.uid)
      .collection('trips');

  // Ajouter un trajet
  Future<void> addTrip(Trip trip) async {
    try {
      await _tripsCollection.add(trip.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du trajet: $e');
    }
  }

  // Mettre à jour un trajet
  Future<void> updateTrip(String tripId, Trip trip) async {
    try {
      await _tripsCollection.doc(tripId).update(trip.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du trajet: $e');
    }
  }

  // Supprimer un trajet
  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du trajet: $e');
    }
  }

  // Récupérer tous les trajets
  Stream<List<Trip>> getTrips() {
    return _tripsCollection
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Récupérer les trajets à venir
  Stream<List<Trip>> getUpcomingTrips() {
    final now = DateTime.now();
    return _tripsCollection
        .where('departureTime', isGreaterThanOrEqualTo: now)
        .orderBy('departureTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Récupérer les trajets passés
  Stream<List<Trip>> getPastTrips() {
    final now = DateTime.now();
    return _tripsCollection
        .where('departureTime', isLessThan: now)
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Toggle le statut favori d'un trajet
  Future<void> toggleFavorite(String tripId, bool isFavorite) async {
    try {
      await _tripsCollection.doc(tripId).update({'isFavorite': isFavorite});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du favori: $e');
    }
  }
}
