import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upper/models/participant_data.dart';
import 'package:upper/models/role.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
    url: 'https://upperclubx.web.app', // URL di reindirizzamento
    handleCodeInApp: true, // Gestisci il codice nell'app
  );

  User? getLoggedUser() => _auth.currentUser;

  AppCubit() : super(AuthInitial());

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(ResetPasswordSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await _auth.setPersistence(Persistence.LOCAL);
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user!.emailVerified) {
        emit(UserSignIn());
      } else {
        await _auth.signOut();
        emit(AuthError('Email non verificata. Controlla la tua email.'));
        emit(UserNotVerified());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _auth.signOut();
    emit(UserSignedOut());
  }



  Future<void> signUpWithEmail(up.User user, String password) async {
    emit(AuthLoading());
    try {
      await _auth.createUserWithEmailAndPassword(
          email: user.email, password: password);
      await _auth.currentUser!
          .updateDisplayName("${user.name} ${user.surname}");
      await _auth.currentUser!.sendEmailVerification(actionCodeSettings);
      user.uid = _auth.currentUser!.uid;
      await updateUserInfo(user);
      await _auth.signOut();
      emit(UserSignupButNotVerified());
    } catch (e) {
      print(e.toString());
      emit(AuthError(e.toString()));
    }
  }

  // Funzione per ottenere un nuovo indice incrementale
  Future<int> getNewIndex() async {
    final DocumentReference counterDoc = firebase.collection('cardsNumber').doc('index');

    return firebase.runTransaction((transaction) async {
      // Recupera il contatore attuale
      DocumentSnapshot snapshot = await transaction.get(counterDoc);

      int newIndex;
      if (snapshot.exists) {
        // Se il contatore esiste, lo incrementa
        int currentIndex = snapshot['value'];
        newIndex = currentIndex + 1;
        transaction.update(counterDoc, {'value': newIndex});
      } else {
        // Se non esiste, lo crea e lo imposta a 1
        newIndex = 1000; // start from 1000
        transaction.set(counterDoc, {'value': newIndex});
      }

      return newIndex;
    });
  }

  Future<String> getUserID(User user) async {
    return _auth.currentUser!.uid.toString();
  }

  Future<void> updateUserInfo(up.User user) async {
    var users = firebase.collection('users');
    await users.doc(user.uid).set(user.toJson());
  }

  Future<void> bookEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants
        .doc(_auth.currentUser!.uid)
        .set({'booked': true, 'presence': tempData.presence});
  }

  Future<void> unBookEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants
        .doc(_auth.currentUser!.uid)
        .set({'booked': false, 'presence': tempData.presence});
  }

  Future<void> joinEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants
        .doc(user!.uid)
        .set({'booked': tempData.booked, 'presence': true});
  }

  Future<void> unJoinEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants
        .doc(_auth.currentUser!.uid)
        .set({'booked': tempData.booked, 'presence': false});
  }

  Future<ParticipantData> getParticipantData(
      String eventId, up.User? user) async {
    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    var doc = await eventsParticipants.doc(user?.uid!).get();
    return ParticipantData.fromJson(doc.data()) ??
        ParticipantData(booked: false, presence: false);
  }

  Future<up.User> getUser() async {
    var users = firebase.collection('users');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    if (kDebugMode) {
      print(doc.data());
    }
    return up.User.fromJson(doc.data()!);
  }

  Future<up.User> getUserFromUser(up.User user) async {
    var users = firebase.collection('users');
    var doc = await users.doc(user.uid).get();
    if (kDebugMode) {
      print(doc.data());
    }
    return up.User.fromJson(doc.data()!);
  }

  Future<String> getWhatsappLink() async {
    var users = firebase.collection('social');
    var doc = await users.doc('whatsapp').get();
    if (kDebugMode) {
      print(doc.data());
    }
    return doc.data()?['link'];
  }

  Future<String> getUserLevel() async {
    var users = firebase.collection('roles');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    var data = doc.data();
    return data == null ? "user" : Role.fromJson(data).name;
  }

  Future<String> getUserLevelFromUser(up.User _user) async {
    var users = firebase.collection('roles');
    var doc = await users.doc(_user.uid).get();
    var data = doc.data();
    if (kDebugMode) {
      print("Livello letto per ${_user.name} : ${data}");
    }
    return data == null ? "user" : Role.fromJson(data).name;
  }

  Future<void> setUserLevel(up.User _user, String role) async {
    var users = firebase.collection('roles');
    await users.doc(_user.uid!).set({'name': role});
  }

  Stream<int> watchCardNumber() {
    // Accede al documento tramite l'ID `uid` e controlla il campo `cardNumber`
    return FirebaseFirestore.instance
        .collection(
            'users') // sostituisci 'your_collection' con il nome della tua collezione
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      // Controlla che il documento esista e che `cardNumber` sia diverso da 0
      if (snapshot.exists) {
        int cardNumber = snapshot.get('cardNumber');
        return cardNumber;
      } else {
        return 0;
      }
    });
  }

  Future<List<UpperEvent>> getUpperEvents() async {
    List<UpperEvent> events = [];

    var eventsCollection = firebase.collection("events");
    await eventsCollection.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          var event = UpperEvent.fromJson(doc.data());
          event.id = doc.id;
          //print(doc.id);
          events.add(event);
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );

    return events;
  }

  Future<List<up.User>> getUsersOnce() async {
    List<up.User> users = [];

    var usersCollection = firebase.collection("users");
    await usersCollection.get().then(
      (querySnapshot) async {
        for (var doc in querySnapshot.docs) {
          if (kDebugMode) {
            print(doc.data());
          }
          var user = up.User.fromJson(doc.data());
          user.id = doc.id;
          var user_level = await getUserLevelFromUser(user);
          if (user_level.contains("admin"))
            user.isAdmin = true;
          else
            user.isAdmin = false;
          users.add(user);
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );

    return users;
  }

  Stream<List<up.User>> getUsers() async* {
    final snapshotStream =
        FirebaseFirestore.instance.collection('users').snapshots();

    await for (final snapshot in snapshotStream) {
      List<up.User> userList = [];

      for (var doc in snapshot.docs) {
        final roleDoc = await FirebaseFirestore.instance
            .collection('roles')
            .doc(doc.id)
            .get();
        if (roleDoc.exists)
          userList.add(up.User.fromJson(doc.data(),
              parUid: doc.id, parIsAdmin: roleDoc['name'] == 'admin'));
        else
          userList.add(up.User.fromJson(doc.data(), parUid: doc.id));
      }

      // Controlla se è il primo caricamento
      //if (!initialLoadComplete) {
      //  initialLoadComplete = true;  // Imposta il flag per indicare che il primo caricamento è completo
      //  print("Caricamento iniziale completato con ${userList.length} utenti.");
      //}

      yield userList; // Emette la lista degli utenti caricati
    }
  }

  Future<List<up.User>?> getEventsParticipant(
      String eventId, List<up.User> allUsers) async {
    List<up.User> participantList = [];

    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          var data = ParticipantData.fromJson(doc.data());
          if (data?.presence == true) {
            for (var us in allUsers) {
              if (us.id == doc.id) participantList.add(us);
            }
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );

    return participantList;
  }

  Stream<List<up.User>?> getEventsParticipantStream(
      String eventId, List<up.User> allUsers) async* {
    final snapshotStream = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection("participants")
        .snapshots();

    await for (final snapshot in snapshotStream) {
      List<up.User> participantList = [];

      for (var doc in snapshot.docs) {
        var data = ParticipantData.fromJson(doc.data());
        if (data?.presence == true) {
          for (var us in allUsers) {
            if (us.id == doc.id) participantList.add(us);
          }
        }
      }
      yield participantList;
    }
  }

  Stream<List<up.User>?> getEventsBookStream(
      String eventId, List<up.User> allUsers) async* {
    final snapshotStream = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection("participants")
        .snapshots();

    await for (final snapshot in snapshotStream) {
      List<up.User> bookedList = [];

      for (var doc in snapshot.docs) {
        var data = ParticipantData.fromJson(doc.data());
        if (data?.booked == true) {
          for (var us in allUsers) {
            if (us.id == doc.id) bookedList.add(us);
          }
        }
      }
      yield bookedList;
    }
  }

  Future<List<up.User>?> getEventsBook(
      String eventId, List<up.User> all_users) async {
    List<up.User> participantList = [];

    var eventsParticipants =
        firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          var data = ParticipantData.fromJson(doc.data());
          if (data?.booked == true) {
            for (var us in all_users) {
              if (us.id == doc.id) participantList.add(us);
            }
          }
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );

    return participantList;
  }
}
