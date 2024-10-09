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
      await _auth.createUserWithEmailAndPassword(email: user.email, password: password);
      await _auth.currentUser!.updateDisplayName("${user.name} ${user.surname}");
      await _auth.currentUser!.sendEmailVerification();
      await updateUserInfo(user);
      await _auth.signOut();
      emit(UserSignupButNotVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<String> getUserID(User user) async {
    return _auth.currentUser!.uid.toString();
  }

  Future<void> updateUserInfo(up.User user) async {
    var users = firebase.collection('users');
    await users.doc(_auth.currentUser!.uid).set(user.toJson());
  }

  Future<void> bookEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants = firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set({'booked': true, 'presence': tempData.presence});
  }

  Future<void> unBookEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants = firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set({'booked': false, 'presence': tempData.presence});
  }

  Future<void> joinEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants = firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set({'booked': tempData.booked, 'presence': true});
  }

  Future<void> unJoinEvent(String eventId, up.User? user) async {
    var tempData = await getParticipantData(eventId, user);
    var eventsParticipants = firebase.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set({'booked': tempData.booked, 'presence': false});
  }

  Future<ParticipantData> getParticipantData(String eventId, up.User? user) async {
    var eventsParticipants = firebase.collection('events').doc(eventId).collection("participants");
    var doc = await eventsParticipants.doc(_auth.currentUser!.uid).get();
    return ParticipantData.fromJson(doc.data()) ?? ParticipantData(booked: false, presence: false);
  }

  Future<up.User> getUser() async {
    var users = firebase.collection('users');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    return up.User.fromJson(doc.data()!);
  }

  Future<String> getUserLevel() async {
    var users = firebase.collection('roles');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    var data = doc.data();
    return data == null ? "user" : Role.fromJson(data).name;
  }

  Future<List<UpperEvent>> getUpperEvents() async {
    List<UpperEvent> events = [];

    var eventsCollection = firebase.collection("events");
    await eventsCollection.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          var event = UpperEvent.fromJson(doc.data());
          event.id = doc.id;
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

    Future<List<up.User>> getUsers() async {
    List<up.User> upper_users = [];

    var usersCollection = firebase.collection("users");
    await usersCollection.get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          var upper_user = up.User.fromJson(doc.data());
          upper_user.id = doc.id;
          upper_users.add(upper_user);
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );

    return upper_users;
  }
}
