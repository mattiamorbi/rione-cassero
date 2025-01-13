import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/helpers/aes_helper.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/theming/colors.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

// ignore: must_be_immutable
class EventTile extends StatefulWidget {
  List<UpperEvent> upperEvents;
  final bool isAdmin;
  final List<up.User> allUsers;
  final up.User loggedUser;

  EventTile(
      {super.key,
      required this.upperEvents,
      required this.isAdmin,
      required this.loggedUser,
      required this.allUsers});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  final List<Image> _image = [];
  up.User? _user;

  //late up.User _loggedUser;
  ParticipantData _participantData =
      ParticipantData(booked: false, presence: false);
  ParticipantData _scannedParticipantData =
      ParticipantData(booked: false, presence: false);

  int _qrMode = 0;
  int _bookMode = 0;
  int _editBookNameMode = 0;
  String bookName = "";
  int bookNumber = 1;
  int childBookNumber = 0;

  List<UpperEvent> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  List<up.User>? _participantUsers = [];
  List<List<ParticipantDataCassero>> _currentEventBookData = [];
  List<up.User>? _bookedUsers = [];
  bool _loading = true;

  StreamSubscription<List<up.User>?>? _presenceSubscription;
  StreamSubscription<List<up.User>?>? _bookSubscription;

  List<StreamSubscription<List<ParticipantDataCassero>>?>
      _eventBookSubscription = [];
  late List<int> totalBookedPlaces = [];

  final TextEditingController _bookEventController = TextEditingController();

  bool _isEventDetailVisible = true;

  @override
  void dispose() {
    super.dispose();
    for (int i = 0; i < _eventBookSubscription.length; i++)
      _eventBookSubscription[i]!.cancel();
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.upperEvents.length; i++) {
      _image.add(Image(image: AssetImage("assets/images/loading.gif")));
    }

    //_loadLoggedUser();

    for (int i = 0; i < widget.upperEvents.length; i++) {
      data.add(widget.upperEvents[i]);
      _loadImage(i);
    }

    _loadEventsSubscription();

    //_onItemsLoad();
  }

  //void _loadLoggedUser() async {
  //  _loggedUser = await context.read<AppCubit>().getUser();
  //}

  Future<void> _loadEventsSubscription() async {
    setState(() {
      _loading = true;
      _qrMode = 0;
    });

    //totalBookedPlaces = 0;

    // Inizializza _currentEventBookData come una lista di liste vuote
    _currentEventBookData = List.generate(widget.upperEvents.length, (_) => []);
    totalBookedPlaces = List.generate(widget.upperEvents.length, (_) => 0);

    for (int i = 0; i < widget.upperEvents.length; i++) {
      // Ottieni lo stream per ogni evento
      final stream = context
          .read<AppCubit>()
          .getBookEventCasseroStream(widget.upperEvents[i].id!, widget.isAdmin);

      // Ascolta lo stream e gestisci i dati
      final subscription = stream.listen((snapshot) {
        setState(() {
          totalBookedPlaces[i] = 0;

          // Aggiorna i dati per l'amministratore o l'utente normale
          _currentEventBookData[i].clear();
          for (var item in snapshot) {
            if (widget.isAdmin || item.uid == widget.loggedUser.uid) {
              _currentEventBookData[i].add(item);
            }
            totalBookedPlaces[i] += item.number;
          }
        });
      });

      // Aggiungi la subscription alla lista
      _eventBookSubscription.add(subscription);
    }

    setState(() {
      _loading = false;
      _qrMode = 0;
    });
  }

  void _enableQrMode() {
    setState(() {
      _qrMode = 1;
    });
  }

  void _toggleBookMode(int index) {
    setState(() {
      _bookMode = 1;
      bookName = "${widget.loggedUser.name} ${widget.loggedUser.surname}";
      bookNumber = 1;
      _editBookNameMode = 0;
      _bookEventController.text =
          "${widget.loggedUser.name} ${widget.loggedUser.surname}";
      _focusedIndex = index;
    });
  }

  void _editBookName() {
    if (_editBookNameMode == 1) {
      setState(() {
        _editBookNameMode = 0;
        bookName = _bookEventController.text;
      });
    } else {
      setState(() {
        _editBookNameMode = 1;
        _bookEventController.text = bookName;
      });
    }
  }

  Future<void> _toggleBookEvent(int index) async {
    //print(_loggedUser.uid);
    if (kDebugMode) print(_participantData.booked);

    setState(() {
      _participantData.booked = !_participantData.booked;
      _qrMode = 0;
    });

    if (!_participantData.booked) {
      await context
          .read<AppCubit>()
          .unBookEvent(widget.upperEvents[index].id!, widget.loggedUser);
    } else {
      await context
          .read<AppCubit>()
          .bookEvent(widget.upperEvents[index].id!, widget.loggedUser);
    }

    setState(() {
      _qrMode = 0;
    });
  }

  Future<ParticipantData> _getParticipantData(int index, up.User user) async {
    return await context
        .read<AppCubit>()
        .getParticipantData(widget.upperEvents[index].id!, user);
  }

  Widget _buildItemDetail(int index) {
    if (data.length > index) {
      var currentEvent = data[index];
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currentEvent.title,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Text(
            "${currentEvent.date} - ${currentEvent.time}",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Text(
            currentEvent.place,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Gap(10.h),
          _currentEventBookData[index].isNotEmpty &&
                  index < _currentEventBookData.length &&
                  _loading == false
              ? Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "PRENOTATO x${getTotalBookPeople(_currentEventBookData[index])}",
                    style: TextStyle(
                        color: ColorsManager.gray17,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : SizedBox.shrink(),
          currentEvent.bookingLimit != null
              ? Visibility(
                  visible: currentEvent.bookingLimit != null &&
                      currentEvent.bookingLimit! > 0,
                  child: Text(
                    "Posti rimanenti ${currentEvent.bookingLimit! - totalBookedPlaces[index]}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          color: ColorsManager.gray17,
                        ),
                        Visibility(visible: !widget.isAdmin, child: Gap(5.w)),
                        Visibility(
                          visible: !widget.isAdmin,
                          child: Text(
                            "Aggiungi prenotazione",
                            style: TextStyle(
                                color: ColorsManager.gray17, fontSize: 18),
                          ),
                        )
                      ]),
                  onTap: () =>
                      _toggleBookMode(index), //_toggleBookEvent(_focusedIndex),
                ),
                Gap(10.h),
                GestureDetector(
                  child: Visibility(
                    visible: _currentEventBookData[index].isNotEmpty,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            color: ColorsManager.gray17,
                          ),
                          Gap(5.w),
                          Text(
                            "Gestisci prenotazioni",
                            style: TextStyle(
                                color: ColorsManager.gray17, fontSize: 18),
                          )
                        ]),
                  ),
                  onTap: () async {
                    if (_currentEventBookData[index].isNotEmpty) {
                      await context.pushNamed(
                        Routes.viewBookScreen,
                        arguments: {
                          'event': widget.upperEvents[index],
                          'bookData': _currentEventBookData[index],
                          'user': widget.loggedUser,
                          'image': _image[index],
                          //'bookedUsers': _bookedUsers,
                          //'participantsUsers': _participantUsers,
                        },
                      );
                    }
                  },
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin & !_loading,
                  child: GestureDetector(
                    child: Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
                    onTap: () => _editEvent(index),
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin &
                      !_loading &
                      (currentEvent.isToday! ||
                          (widget.loggedUser.name == 'Mattia' &&
                              widget.loggedUser.surname == 'Morbidelli')),
                  child: GestureDetector(
                    onTap: _enableQrMode,
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin &
                      !_loading &
                      (currentEvent.isToday! ||
                          (widget.loggedUser.name == 'Mattia' &&
                              widget.loggedUser.surname == 'Morbidelli')),
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin & !_loading,
                  child: GestureDetector(
                    onTap: () => _viewParticipants(index),
                    child: Icon(
                      Icons.menu,
                      color: Colors.orange,
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin & !_loading,
                  child: GestureDetector(
                    child: Icon(
                      Icons.add,
                      color: Colors.orange,
                    ),
                    onTap: () async {
                      await context.pushNamed(Routes.newEventScreen,
                          arguments: null);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox(
        width: 350,
        height: 350,
      );
    }
  }

  bool isMobileDevice() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final width = window.physicalSize.width / window.devicePixelRatio;

    // Usa user agent per la verifica primaria
    if (userAgent.contains('mobile') ||
        userAgent.contains('android') ||
        userAgent.contains('iphone')) {
      return true;
    }

    // Verifica secondaria con larghezza schermo
    return width < 600;
  }

  Widget _buildListItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async => {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: isMobileDevice() ? window.display.size.width - 30 : 400,
        height: isMobileDevice() ? window.display.size.width - 30 : 400,
        child: InkWell(
          onTap: () async {
            sslKey.currentState!.focusToItem(index);
            if (_currentEventBookData.isNotEmpty) {
              await context.pushNamed(
                Routes.viewBookScreen,
                arguments: {
                  'event': widget.upperEvents[index],
                  'bookData': _currentEventBookData,
                  'user': widget.loggedUser,
                  'image': _image[_focusedIndex],
                  //'bookedUsers': _bookedUsers,
                  //'participantsUsers': _participantUsers,
                },
              );
            }
          },
          child: Stack(children: [
            Center(child: Image(image: _image[index].image)),
            index < _currentEventBookData.length &&
                    index == _focusedIndex &&
                    _loading == false
                ? Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "PRENOTATO x${getTotalBookPeople(_currentEventBookData[index])}",
                      style: TextStyle(
                          color: ColorsManager.gray17,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ]),
        ),
      ),
    );
  }

  Future<void> _acceptUser(int index) async {
    await context
        .read<AppCubit>()
        .joinEvent(widget.upperEvents[index].id!, _user);
    setState(() {
      _qrMode = 1;
    });
  }

  Widget _joinEventButton(double bWidth, double bHeight, String text,
      Icon? icon, Color color, VoidCallback onPressed) {
    int b = color.blue;
    int r = color.red;
    int g = color.green;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: bWidth,
        height: bHeight,
        decoration: BoxDecoration(
          color: Color.fromRGBO(r, g, b, 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: icon != null,
              child: Icon(
                icon?.icon ?? Icons.add,
                color: color,
              ),
            ),
            Gap(15.w),
            Visibility(
              visible: text.isNotEmpty,
              child: Text(text, style: TextStyle(color: color, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCodeReaderWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 15,
        ),
        Visibility(
          visible: _qrMode == 1,
          child: Expanded(
            child: FlutterWebQrcodeScanner(
              cameraDirection: CameraDirection.back,
              stopOnFirstResult: false,
              onGetResult: (result) async {
                //SnackBar(content: Text(result), duration: Duration(seconds: 5));
                var decryptedData = AesHelper.decrypt(result);
                var json = jsonDecode(decryptedData);
                _user = up.User.fromJson(json);
                _scannedParticipantData =
                    await _getParticipantData(_focusedIndex, _user!);
                setState(() {
                  _qrMode = 2;
                });
              },
              width: 400,
              height: 400,
            ),
          ),
        ),
        Visibility(
          visible: _qrMode == 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: ColorsManager.background,
                onPressed: () {
                  //setState(() {
                  //  _qrMode = 0;
                  //});
                  //_onItemFocus(_focusedIndex);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: ColorsManager.gray17,
                ),
              ),
              //Gap(15.w),
            ],
          ),
        ),
        Visibility(
            visible: _qrMode == 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.upperEvents[_focusedIndex].title,
                  style: TextStyle(color: ColorsManager.gray17),
                ),
                Gap(25.h),
                Visibility(
                  visible: _scannedParticipantData.presence,
                  child: Column(
                    children: [
                      Text(
                        "Già entrato",
                        style: TextStyle(color: Colors.red, fontSize: 36),
                      ),
                      Gap(25.h),
                    ],
                  ),
                ),
                Visibility(
                  visible: _scannedParticipantData.booked &
                      !_scannedParticipantData.presence,
                  child: Column(
                    children: [
                      Text(
                        "Prenotazione effettuata",
                        style: TextStyle(color: Colors.green, fontSize: 36),
                      ),
                      Gap(25.h),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "NOME  ",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "${_user?.name} ${_user?.surname}",
                      style:
                          TextStyle(color: ColorsManager.gray17, fontSize: 24),
                    ),
                  ],
                ),
                Gap(25.h),
                //Row(
                //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //  children: [
                //    Text(
                //      "DATA DI NASCITA  ",
                //      style: TextStyle(color: Colors.grey, fontSize: 12),
                //    ),
                //    Text(
                //      "${_user?.birthdate}",
                //      style: TextStyle(color: ColorsManager.gray17, fontSize: 24),
                //    ),
                //  ],
                //),
                //Gap(25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "ETA'  ",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.start,
                      "${_user?.getAge()} anni",
                      style: TextStyle(
                          color: (_user?.getAge() ?? 0) < 18
                              ? Colors.red
                              : ColorsManager.gray17,
                          fontSize: 24),
                    ),
                  ],
                ),
                Gap(40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _joinEventButton(
                      170,
                      50,
                      "Rifiuta",
                      Icon(Icons.close),
                      Colors.red,
                      () => setState(() {
                        _qrMode = 1;
                      }),
                    ),
                    Visibility(
                      visible: !_scannedParticipantData.presence,
                      child: SizedBox(
                        width: 10,
                      ),
                    ),
                    Visibility(
                      visible: !_scannedParticipantData.presence,
                      child: _joinEventButton(
                        170,
                        50,
                        "Accetta",
                        Icon(Icons.add),
                        Colors.green,
                        () => _acceptUser(_focusedIndex),
                      ),
                    ),
                  ],
                )
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_bookMode == 0) {
      return PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        // Mostra l'80% di una card
        itemCount: widget.upperEvents.length,
        itemBuilder: (context, index) {
          return Container(
            height: 500,
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  _isEventDetailVisible =
                      !_isEventDetailVisible; // Nasconde il pannello quando si preme
                });
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: _image[index].image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Visibility(
                    visible: _isEventDetailVisible,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 300,
                            height: 230,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              // Bianco semi-trasparente
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _buildItemDetail(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      // lettore di codici a barre
      //return Container(
      //  height: 400,
      //  padding: EdgeInsets.only(bottom: 20),
      //  width: MediaQuery.of(context).size.width - 20,
      //  child: _qrCodeReaderWidget(),
      //);
      var currentEvent = data[_focusedIndex];
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image(
                        image: _image[_focusedIndex].image,
                        fit: BoxFit.fitWidth),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentEvent.title,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.gray17),
                      ),
                      Text(
                        "${currentEvent.date} - ${currentEvent.time}",
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.gray17),
                      ),
                      Text(
                        currentEvent.place,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorsManager.gray17),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Text(
                    "Aggiungi la tua prenotazione",
                    style: TextStyle(
                        color: Color.fromRGBO(50, 50, 50, 1), fontSize: 15),
                  )),
                  Gap(20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _editBookNameMode == 0
                          ? Text(
                              bookName,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            )
                          : Center(
                              child: Container(
                                width: window.physicalSize.width /
                                        window.devicePixelRatio -
                                    100,
                                child: AppTextFormField(
                                  textAlignment: TextAlign.center,
                                  hint: "",
                                  validator: (value) {
                                    String enteredValue = (value ?? '').trim();
                                    _bookEventController.text = enteredValue;
                                    if (enteredValue.isEmpty) {
                                      return "Il valore non può essere nullo";
                                    }
                                  },
                                  controller: _bookEventController,
                                ),
                              ),
                            ),
                      Visibility(
                          visible: _editBookNameMode == 0, child: Gap(10.w)),
                      Visibility(
                        visible: _editBookNameMode == 0,
                        child: GestureDetector(
                          child: Icon(Icons.edit, size: 20),
                          onTap: _editBookName,
                        ),
                      )
                    ],
                  ),
                  Gap(15.h),
                  Center(
                      child: Text(
                    "Adulti",
                    style: TextStyle(fontSize: 15),
                  )),
                  Gap(5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.remove,
                          size: 25,
                        ),
                        onTap: () => setState(() {
                          bookNumber--;
                          if (bookNumber <= 1) bookNumber = 1;
                        }),
                      ),
                      Text(
                        bookNumber.toString(),
                        style: TextStyle(fontSize: 30),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.add,
                          size: 25,
                        ),
                        onTap: () => setState(() {
                          bookNumber++;
                        }),
                      ),
                    ],
                  ),
                  Gap(15.h),
                  Center(
                      child: Text(
                    "Bambini",
                    style: TextStyle(fontSize: 15),
                  )),
                  Gap(5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.remove,
                          size: 25,
                        ),
                        onTap: () => setState(() {
                          childBookNumber--;
                          if (childBookNumber <= 0) childBookNumber = 0;
                        }),
                      ),
                      Text(
                        childBookNumber.toString(),
                        style: TextStyle(fontSize: 30),
                      ),
                      GestureDetector(
                        child: Icon(
                          Icons.add,
                          size: 25,
                        ),
                        onTap: () => setState(() {
                          childBookNumber++;
                        }),
                      ),
                    ],
                  ),
                  Gap(20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.undo,
                          size: 25,
                        ),
                        onTap: () => setState(() {
                          _bookMode = 0;
                        }),
                      ),
                      Gap(50.w),
                      GestureDetector(
                        child: Icon(Icons.save, size: 25),
                        onTap: _bookEventSave,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  int getTotalBookPeople(List<ParticipantDataCassero> list) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += book.number;
    }
    return sum;
  }

  Future<void> _bookEventSave() async {
    await context.read<AppCubit>().bookEventCassero(
        widget.upperEvents[_focusedIndex].id!,
        null,
        _bookEventController.text,
        bookNumber,
        childBookNumber);

    //_myEvents = await context
    //    .read<AppCubit>()
    //    .getBookEventCassero(widget.upperEvents[_focusedIndex].id!, widget.isAdmin);

    setState(() {
      _bookMode = 0;
    });
  }

  Future<void> _loadImage(int index) async {
    try {
      final imageData = await widget.upperEvents[index].getEventImage();
      if (imageData != null) {
        setState(() {
          _image[index] = Image.memory(imageData);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image: $e');
      }
    }
  }

  Future<void> _editEvent(int index) async {
    await context.pushNamed(Routes.editEventScreen,
        arguments: widget.upperEvents[index]);
    setState(() {});
  }

  Future<void> _viewParticipants(int index) async {
    context.pushNamed(
      Routes.viewParticipantsScreen,
      arguments: {
        'upperEvent': widget.upperEvents[index],
        'allUsers': widget.allUsers,
        //'bookedUsers': _bookedUsers,
        //'participantsUsers': _participantUsers,
      },
    );
  }
}
