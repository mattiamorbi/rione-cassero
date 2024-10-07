import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upper/models/participant_data.dart';
import 'package:upper/models/role.dart';
import 'package:upper/models/user.dart' as up;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

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

  Future<void> updateUserInfo(up.User user) async {
    var users = FirebaseFirestore.instance.collection('users');
    await users.doc(_auth.currentUser!.uid).set(user.toJson());
  }

  Future<void> bookEvent(String eventId, up.User? user) async {
    ParticipantData? temp_data = await getParticipantData(eventId, user);
    var eventsParticipants = FirebaseFirestore.instance.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set(
        {'booked': true, 'presence': temp_data?.presence});
  }

  Future<void> unbookEvent(String eventId, up.User? user) async {
    ParticipantData? temp_data = await getParticipantData(eventId, user);
    var eventsParticipants = FirebaseFirestore.instance.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set(
        {'booked': false, 'presence': temp_data?.presence});
  }



  Future<void> joinEvent(String eventId, up.User? user) async {
    ParticipantData? temp_data = await getParticipantData(eventId, user);
    var eventsParticipants = FirebaseFirestore.instance.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set(
        {'booked': temp_data?.booked, 'presence': true});
  }

  Future<void> unJoinEvent(String eventId, up.User? user) async {
    ParticipantData? temp_data = await getParticipantData(eventId, user);
    var eventsParticipants = FirebaseFirestore.instance.collection('events').doc(eventId).collection("participants");
    await eventsParticipants.doc(_auth.currentUser!.uid).set(
        {'booked': temp_data?.booked, 'presence': false});
  }

  Future<ParticipantData> getParticipantData(String eventId, up.User? user) async {
    var eventsParticipants = FirebaseFirestore.instance.collection('events').doc(eventId).collection("participants");
    var doc = await eventsParticipants.doc(_auth.currentUser!.uid).get();
    print(doc.data());
    ParticipantData? temp = ParticipantData.fromJson(doc.data());
    temp ??= ParticipantData(booked: false, presence: false);
    return temp;
  }

  Future<up.User> getUser() async {
    var users = FirebaseFirestore.instance.collection('users');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    return up.User.fromJson(doc.data()!);
  }

  Future<String> getUserID(User user) async {
    return _auth.currentUser!.uid.toString();
  }

  Future<String> getUserLevel() async {
    var users = FirebaseFirestore.instance.collection('roles');
    var doc = await users.doc(_auth.currentUser!.uid).get();
    var data = doc.data();
    return data == null ? "user" : Role.fromJson(data).name;
  }
}
