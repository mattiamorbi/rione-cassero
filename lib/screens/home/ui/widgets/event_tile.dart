import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:gap/gap.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';
import 'package:upper/models/participant_data.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/routing/routes.dart';

import 'package:upper/helpers/aes_helper.dart';
import 'package:upper/models/user.dart' as up;

// ignore: must_be_immutable
class EventTile extends StatefulWidget {
  List<UpperEvent> upperEvents;
  final bool isAdmin;
  final List<up.User> allUsers;
  final up.User loggedUser;

  EventTile({super.key, required this.upperEvents, required this.isAdmin, required this.loggedUser, required this.allUsers});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  final List<Image> _image = [];
  up.User? _user;

  //late up.User _loggedUser;
  ParticipantData _participantData = ParticipantData(booked: false, presence: false);
  ParticipantData _scannedParticipantData = ParticipantData(booked: false, presence: false);

  int _qrMode = 0;

  List<UpperEvent> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  List<up.User>? _participantUsers = [];
  List<up.User>? _bookedUsers = [];
  bool _loading = true;

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

    _onItemFocus(0);
  }

  //void _loadLoggedUser() async {
  //  _loggedUser = await context.read<AppCubit>().getUser();
  //}

  Future<void> _onItemFocus(int index) async {
    if (kDebugMode) {
      print(index);
    }

    setState(() {
      _loading = true;
      _qrMode = 0;
    });

    //print(_loggedUser.name);
    _participantData = await context.read<AppCubit>().getParticipantData(widget.upperEvents[index].id!, widget.loggedUser);
    if (kDebugMode) {
      print(_participantData.booked);
      print(_participantData.presence);
    }
    _participantUsers?.clear();
    _bookedUsers?.clear();

    if (widget.isAdmin == true) {
      _participantUsers = await context.read<AppCubit>().getEventsParticipant(widget.upperEvents[index].id!, widget.allUsers);
      _bookedUsers = await context.read<AppCubit>().getEventsBook(widget.upperEvents[index].id!, widget.allUsers);
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

  Future<void> _toggleBookEvent(int index) async {
    //print(_loggedUser.uid);
    print(_participantData.booked);

    setState(() {
      _participantData.booked = !_participantData.booked;
      _qrMode = 0;
    });

    if (!_participantData.booked) {
      await context.read<AppCubit>().unBookEvent(widget.upperEvents[index].id!, widget.loggedUser);
    } else {
      await context.read<AppCubit>().bookEvent(widget.upperEvents[index].id!, widget.loggedUser);
    }

    var participantData = await _getParticipantData(index);

    if (kDebugMode) {
      print("ho riletto ${participantData.booked}");
      print(_bookedUsers);
    }
    if (participantData.booked) {
      _bookedUsers?.add(widget.loggedUser);
    } else {
      for (int i = 0; i < _bookedUsers!.length; i++) {
        if (_bookedUsers![i].uid == widget.loggedUser.uid) _bookedUsers?.remove(_bookedUsers?.elementAt(i));
      }
    }
    //print("ho riletto ${participantDatatemp.booked}");
    setState(() {
      _qrMode = 0;
      _participantData = participantData;
    });
  }

  Future<ParticipantData> _getParticipantData(int index) async {
    return await context.read<AppCubit>().getParticipantData(widget.upperEvents[index].id!, widget.loggedUser);
  }

  Widget _buildItemDetail() {
    if (data.length > _focusedIndex) {
      var currentEvent = data[_focusedIndex];
      return SizedBox(
        height: 150,
        child: Column(
          children: [
            Text(
              currentEvent.title,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "${currentEvent.date} - ${currentEvent.time}",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              currentEvent.place,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Visibility(
              visible: widget.isAdmin & !_loading,
              child: Text(
                "Prenotate  ${_bookedUsers?.length}",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            Visibility(
              visible: widget.isAdmin & !_loading,
              child: Text(
                "Entrate  ${_participantUsers?.length}",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Icon(
                    (_participantData.booked) ? Icons.person_remove_alt_1 : Icons.person_add_alt_1,
                    color: Colors.white,
                  ),
                  onTap: () => _toggleBookEvent(_focusedIndex),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: GestureDetector(
                    child: Icon(
                      Icons.edit,
                      color: Colors.orange,
                    ),
                    onTap: () => _editEvent(_focusedIndex),
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: widget.isAdmin,
                  child: GestureDetector(
                    onTap: _enableQrMode,
                    child: Icon(
                      Icons.qr_code,
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
                  visible: widget.isAdmin,
                  child: GestureDetector(
                    onTap: () => _viewParticipants(_focusedIndex),
                    child: Icon(
                      Icons.menu,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 350,
        height: 350,
      );
    }
  }

  Widget _buildListItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: 400,
      height: 400,
      child: InkWell(
        onTap: () {
          sslKey.currentState!.focusToItem(index);
        },
        child: Image(image: _image[index].image),
      ),
    );
  }

  Future<void> _acceptUser(int index) async {
    await context.read<AppCubit>().joinEvent(widget.upperEvents[index].id!, _user);
    setState(() {
      _qrMode = 1;
    });
  }

  Widget _joinEventButton(double bWidth, double bHeight, String text, Icon? icon, Color color, VoidCallback onPressed) {
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
                var decryptedData = AesHelper.decrypt(result);
                var json = jsonDecode(decryptedData);
                _user = up.User.fromJson(json);
                _scannedParticipantData = await _getParticipantData(_focusedIndex);
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
                backgroundColor: Color.fromRGBO(17, 17, 17, 1),
                onPressed: () {
                  //setState(() {
                  //  _qrMode = 0;
                  //});
                  _onItemFocus(_focusedIndex);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
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
                  style: TextStyle(color: Colors.white),
                ),
                Gap(25.h),
                Visibility(
                  visible: _scannedParticipantData.presence ? false : _scannedParticipantData.presence,
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
                  visible: _scannedParticipantData.booked ? false : _scannedParticipantData.booked & !_scannedParticipantData.presence,
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
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                Gap(25.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "DATA DI NASCITA  ",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "${_user?.birthdate}",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
                Gap(25.h),
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
                      style: TextStyle(color: (_user?.getAge() ?? 0) < 18 ? Colors.red : Colors.white, fontSize: 24),
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
                      visible: _participantData.presence ? false : _participantData.presence,
                      child: SizedBox(
                        width: 10,
                      ),
                    ),
                    Visibility(
                      visible: _participantData.presence ? false : _participantData.presence,
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
    if (_qrMode == 0) {
      return Column(
        children: <Widget>[
          Expanded(
            child: ScrollSnapList(
              dynamicItemSize: true,
              margin: EdgeInsets.symmetric(vertical: 10),
              onItemFocus: (index) {
                setState(() {
                  _focusedIndex = index;
                });
                _onItemFocus(index);
              },
              //
              // },
              itemSize: 410,
              itemBuilder: _buildListItem,
              itemCount: data.length,
              key: sslKey,
              initialIndex: _focusedIndex as double,
              background: Colors.white,
              padding: EdgeInsets.all(8.0),
              //dynamicItemOpacity: 0.2,
              //listViewPadding: EdgeInsets.all(8.0),
            ),
          ),
          _buildItemDetail(),
        ],
      );
    } else {
      return Container(
        height: 400,
        padding: EdgeInsets.only(bottom: 20),
        width: MediaQuery.of(context).size.width - 20,
        child: _qrCodeReaderWidget(),
      );
    }
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
    context.pushNamed(Routes.editEventScreen, arguments: widget.upperEvents[index]);
  }

  Future<void> _viewParticipants(int index) async {
    context.pushNamed(
      Routes.viewParticipantsScreen,
      arguments: {
        'upperEvent': widget.upperEvents[index],
        'bookedUsers': _bookedUsers,
        'participantsUsers': _participantUsers,
      },
    );
  }
}
