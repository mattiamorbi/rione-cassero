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
  List<UpperEvent> upperEvent;
  final bool isAdmin;
  List<up.User> all_users;

  EventTile({super.key, required this.upperEvent, required this.isAdmin, required this.all_users});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  List<Image> image = [];
  late bool visible = false;
  up.User? _user;
  ParticipantData? _participantData;

  int _qrMode = 0;

  List<UpperEvent> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

  List<up.User>? eventParticipantData = [];
  List<up.User>? eventBookedData = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.upperEvent.length; i++) {
      image.add(Image(image: AssetImage("assets/images/loading.gif")));
    }

    for (int i = 0; i < widget.upperEvent.length; i++) {
      data.add(widget.upperEvent[i]);
      _loadImage(i);
    }

    _onItemFocus(0);
  }

  Future<void> _onItemFocus(int index) async {
    if (kDebugMode) {
      print(index);
    }
    //setState(() async {
    _participantData = await context.read<AppCubit>().getParticipantData(widget.upperEvent[index].id!, _user);
    //});
    eventParticipantData?.clear();
    eventParticipantData = await context.read<AppCubit>().getEventsParticipant(widget.upperEvent[index].id!, widget.all_users);

    eventBookedData?.clear();
    eventBookedData = await context.read<AppCubit>().getEventsBook(widget.upperEvent[index].id!, widget.all_users);

    setState(() {
      _qrMode = 0;
    });
  }

  void _enableQrMode() {
    setState(() {
      _qrMode = 1;
    });
  }

  Future<void> _toggleBookEvent(int index) async {
    if (_participantData!.booked) {
      await context.read<AppCubit>().unBookEvent(widget.upperEvent[index].id!, _user);
    } else {
      await context.read<AppCubit>().bookEvent(widget.upperEvent[index].id!, _user);
    }

    _participantData = await _getParticipantData(index);
    setState(() {
      _qrMode = 0;
    });
  }

  Future<ParticipantData> _getParticipantData(int index) async {
    return await context.read<AppCubit>().getParticipantData(widget.upperEvent[index].id!, _user);
  }

  Widget _buildItemDetail() {
    if (data.length > _focusedIndex) {
      return SizedBox(
        height: 150,
        child: Column(
          children: [
            Text(
              data[_focusedIndex].title,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              "${data[_focusedIndex].date} - ${data[_focusedIndex].time}",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              data[_focusedIndex].place,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Visibility(
              visible: widget.isAdmin,
              child: Text(
                "Prenotate  ${eventBookedData?.length}",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),
            Visibility(
              visible: widget.isAdmin,
              child: Text(
                "Entrate  ${eventParticipantData?.length}",
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
                    (_participantData?.booked ?? false) ? Icons.person_remove_alt_1 : Icons.person_add_alt_1,
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
        child: Image(image: image[index].image),
      ),
    );
  }

  Future<void> _acceptUser(int index) async {
    await context.read<AppCubit>().joinEvent(widget.upperEvent[index].id!, _user);
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
                _participantData = await _getParticipantData(_focusedIndex);
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
                  widget.upperEvent[_focusedIndex].title,
                  style: TextStyle(color: Colors.white),
                ),
                Gap(25.h),
                Visibility(
                  visible: _participantData == null ? false : _participantData!.presence,
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
                  visible: _participantData == null ? false : _participantData!.booked & !_participantData!.presence,
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
                      visible: _participantData == null ? false : _participantData!.presence,
                      child: SizedBox(
                        width: 10,
                      ),
                    ),
                    Visibility(
                      visible: _participantData == null ? false : _participantData!.presence,
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
      final imageData = await widget.upperEvent[index].getEventImage();
      if (imageData != null) {
        setState(() {
          image[index] = Image.memory(imageData);
          visible = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image: $e');
        visible = false;
      }
    }
  }

  Future<void> _editEvent(int index) async {
    context.pushNamed(Routes.editEventScreen, arguments: widget.upperEvent[index]);
  }
}
