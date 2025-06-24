import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/trip.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tripsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Utilisateur non authentifié');
    }
    return _firestore.collection('users').doc(userId).collection('trips');
  }

  // Méthodes CRUD avec gestion d'erreur améliorée
  Future<void> addTrip(Trip trip) async {
    try {
      await _tripsCollection.add(trip.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'ajout du trajet');
    } catch (e) {
      throw Exception('Erreur inattendue lors de l\'ajout du trajet: $e');
    }
  }

  Future<void> updateTrip(String tripId, Trip trip) async {
    try {
      await _tripsCollection.doc(tripId).update(trip.toMap());
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'mise à jour du trajet');
    } catch (e) {
      throw Exception('Erreur inattendue lors de la mise à jour du trajet: $e');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      await _tripsCollection.doc(tripId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'suppression du trajet');
    } catch (e) {
      throw Exception('Erreur inattendue lors de la suppression du trajet: $e');
    }
  }

  Stream<List<Trip>> getTrips() {
    return _tripsCollection
        .orderBy('departureTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              // Log l'erreur mais continue avec les autres documents
              debugPrint('Erreur lors du parsing du document ${doc.id}: $e');
              return null;
            }
          })
          .where((trip) => trip != null)
          .cast<Trip>()
          .toList();
    }).handleError((error) {
      throw _handleFirebaseError(error, 'récupération des trajets');
    });
  }

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
    }).handleError((error) {
      throw _handleFirebaseError(error, 'récupération des trajets à venir');
    });
  }

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
    }).handleError((error) {
      throw _handleFirebaseError(error, 'récupération des trajets passés');
    });
  }

  Future<void> toggleFavorite(String tripId, bool isFavorite) async {
    try {
      await _tripsCollection.doc(tripId).update({'isFavorite': isFavorite});
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'mise à jour du favori');
    } catch (e) {
      throw Exception('Erreur inattendue lors de la mise à jour du favori: $e');
    }
  }

  // Méthodes utilitaires
  Future<List<Trip>> getTripsByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _tripsCollection
          .where('departureTime', isGreaterThanOrEqualTo: start)
          .where('departureTime', isLessThanOrEqualTo: end)
          .orderBy('departureTime')
          .get();

      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'récupération des trajets par date');
    } catch (e) {
      throw Exception(
          'Erreur inattendue lors de la récupération des trajets: $e');
    }
  }

  Future<List<Trip>> getFavoriteTrips() async {
    try {
      final snapshot = await _tripsCollection
          .where('isFavorite', isEqualTo: true)
          .orderBy('departureTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseError(e, 'récupération des trajets favoris');
    } catch (e) {
      throw Exception(
          'Erreur inattendue lors de la récupération des favoris: $e');
    }
  }

  // Gestion d'erreur centralisée
  Exception _handleFirebaseError(dynamic error, String operation) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('Accès refusé lors du $operation');
        case 'not-found':
          return Exception('Document non trouvé lors du $operation');
        case 'already-exists':
          return Exception('Le document existe déjà lors du $operation');
        case 'resource-exhausted':
          return Exception('Limite de requêtes atteinte lors du $operation');
        case 'failed-precondition':
          return Exception(
              'Condition préalable non remplie lors du $operation');
        case 'aborted':
          return Exception('Opération annulée lors du $operation');
        case 'out-of-range':
          return Exception('Valeur hors limites lors du $operation');
        case 'unimplemented':
          return Exception('Fonctionnalité non implémentée lors du $operation');
        case 'internal':
          return Exception('Erreur interne lors du $operation');
        case 'unavailable':
          return Exception('Service indisponible lors du $operation');
        case 'data-loss':
          return Exception('Perte de données lors du $operation');
        case 'unauthenticated':
          return Exception('Utilisateur non authentifié lors du $operation');
        default:
          return Exception(
              'Erreur Firebase lors du $operation: ${error.message}');
      }
    }
    return Exception('Erreur lors du $operation: $error');
  }
}
