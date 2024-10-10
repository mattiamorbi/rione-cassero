import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;
import 'package:upper/theming/colors.dart';

import '../../../routing/routes.dart';

// ignore: must_be_immutable
class EventPartecipantScreen extends StatefulWidget {
  UpperEvent? upperEvent;
  List<up.User>bookedUsers =[];
  List<up.User>partecipantsUsers =[];
  
  
  NewEventScreen({super.key, required this.upperEvent, required this.bookedUsers, required this.partecipantsUsers});

  @override
  State<NewEventScreen> createState() => _EventPartecipantScreenState();
}

class _EventPartecipantScreenState extends State<EventPartecipantScreen> {
  List<up.User> totalJoinEvent = [];
  List<up.User> filteredUsers = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    totalJoinEvent = _createJoinList();
    filteredUsers = totalJoinEvent;
  }

   List<up.User> _createJoinList() {
    // Creiamo una mappa per gestire l'unione
    Map<String, Utente> userMap = {};

    // Aggiungo prima i prenotati
  for (var us in bookedUsers) {
    userMap[us['uid']!] = up.User(
      uid: us['uid']!,
      nome: us['name']!,
      cognome: us['surname']!,
      state: 'booked',
    );
  }

  // Poi aggiungo i partecipanti, sovrascrivendo se già esiste
  for (var us in partecipantsUsers) {
    userMap[us['uid']!] = up.User(
      uid: us['uid']!,
      nome: us['name']!,
      cognome: us['surname']!,
      state: 'joined', // Sovrascrive lo stato se l'utente è già presente
    );
  }

  // Converto la mappa in una lista finale
  return userMap.values.toList();
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUtenti(String query) {
    List<up.User> filtered = users.where((utente) {
      String fullName =
          '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected ? _newEventScreen(context) : const BuildNoInternet();
        },
        child: Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: AppTextFormField(
                hint: "Cerca",
                validator: (value) {},
                controller: searchController,
                isObscureText: false,
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.black38,
                ),
                onChanged: (value) {
                  filterUtenti(value);
                },
              ),
            ),
          ),
          Text("Partecipanti: ${totalJoinEvent.length}"),
          Expanded(
            child: isUsersLoading
                ? Center(child: Text('Caricamento utenti in corso...'))
                : filteredUsers.isEmpty
                    ? Center(child: Text('Nessun utente trovato'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final utente = filteredUsers[index];
                          return ListTile(
                            tileColor: Colors.white,
                            textColor: Colors.black,
                            subtitleTextStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                            shape: RoundedRectangleBorder(
                              //<-- SEE HERE
                              side: BorderSide(width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Icon(
                              Icons.person_outline,
                              color: utente.status == 'booked' ?  Colors.orange : 
                              utente.status == 'joined' ? Colors.green : Colors.black,
                            ),
                            trailing: GestureDetector(
                              child: Icon(Icons.delete, color: Colors.red),
                              onTap: () {},
                            ),
                            title: Text('${utente.name} ${utente.surname}'),
                            subtitle: Text(
                                'Email: ${utente.email}\nData di nascita: ${utente.birthdate}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected ? _newEventScreen(context) : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(
            color: ColorsManager.mainBlue,
          ),
        ),
      ),
    );
  }

  Widget genericField(TextEditingController controller, String placeholder,
      String errorMessage) {
    return AppTextFormField(
      hint: placeholder,
      validator: (value) {
        String enteredValue = (value ?? '').trim();
        controller.text = enteredValue;
        if (enteredValue.isEmpty) {
          return errorMessage;
        }
      },
      controller: controller,
    );
  }

  Future<void> _loadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _pickedImage = image;
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
      });
    } else {
      if (kDebugMode) {
        print("Immagine non selezionata");
      }
    }
  }

  Future<void> _uploadToFirebase() async {
    //this.build(context);
    context.pushNamed(Routes.homeScreen);
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("images/${_pickedImage!.name}");

    try {
      await imageRef.putData(_webImage);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Errore durante il caricamento dell'immagine! $e");
      }
    }
    var events = FirebaseFirestore.instance.collection('events');
    var upperEvent = UpperEvent(
        title: titleController.text,
        description: descriptionController.text,
        date: dateController.text,
        time: timeController.text,
        place: placeController.text,
        imagePath: _pickedImage == null
            ? widget.upperEvent!.imagePath
            : "images/${_pickedImage!.name}");

    try {
      if (widget.upperEvent != null) {
        var id = widget.upperEvent!.id;
        widget.upperEvent = upperEvent;
        await events.doc(id).set(widget.upperEvent!.toJson());
      } else {
        await events.doc().set(upperEvent.toJson());
      }
      //context.pushNamed(Routes.homeScreen);
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error while saving event! $e");
      }
    }
  }

  Widget _newEventScreen(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("UPPER - Nuovo evento"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Aggiungi un nuovo evento")),
              Gap(20.w),
              genericField(
                  titleController, "Titolo", "Inserisci un titolo valido"),
              Gap(20.w),
              genericField(descriptionController, "Descrizione",
                  "Inserisci una descrizione valida"),
              Gap(20.w),
              genericField(dateController, "Data", "Inserisci una data valida"),
              Gap(20.w),
              genericField(
                  timeController, "Orario", "Inserisci un orario valido"),
              Gap(20.w),
              genericField(
                  placeController, "Luogo", "Inserisci un luogo valido"),
              Gap(20.w),
              Visibility(
                visible: _webImage.length > 1,
                child: Image.memory(
                  _webImage,
                  fit: BoxFit.fill,
                ),
              ),
              Row(
                children: [
                  SizedBox(width: MediaQuery.sizeOf(context).width / 2),
                  FloatingActionButton(
                    onPressed: _loadImage,
                    child: Icon(
                      Icons.image,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  FloatingActionButton(
                    onPressed: _uploadToFirebase,
                    child: Icon(
                      Icons.save,
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    placeController.dispose();
  }
}
