import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/routing/routes.dart';

import '../../../core/widgets/scroll_snap_list.dart';
import '../../../helpers/aes_helper.dart';
import '../../../models/user.dart' as up;

// ignore: must_be_immutable
class EventTile extends StatefulWidget {
  List<UpperEvent> upperEvent;
  final bool isAdmin;

  EventTile({super.key, required this.upperEvent, required this.isAdmin});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  List<Image> image =
      []; // = Image(image: AssetImage("assets/images/loading.gif"));
  late bool visible = false;

  int _qrMode = 0;

  List<UpperEvent> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();

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
  }

  void _onItemFocus(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  void _enableQrMode() {
    setState(() {
      _qrMode = 1;
    });
  }

  Future<void> _joinEvent(int index) async {
    await context.read<AuthCubit>().joinEvent(widget.upperEvent[index].id!);
  }

  Widget _buildItemDetail() {
    if (data.length > _focusedIndex) {
      return Container(
        height: 150,
        child: Column(
          children: [
            Text(
              data[_focusedIndex].title,
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              "${data[_focusedIndex].date} - ${data[_focusedIndex].time}",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            Text(
              data[_focusedIndex].place,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                  ),
                  onTap: () => _joinEvent(_focusedIndex),
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
                    child: Icon(
                      Icons.qr_code,
                      color: Colors.orange,
                    ),
                    onTap: _enableQrMode,
                  ),
                ),
              ],
//              children: [
//                ElevatedButton(
//                    onPressed: () => _joinEvent(_focusedIndex),
//                    child: Icon(Icons.person_add_alt_1)),
//                Visibility(
//                  visible: widget.isAdmin,
//                  child: SizedBox(
//                    width: 10,
//                  ),
//                ),
//                Visibility(
//                  visible: widget.isAdmin,
//                  child: Align(
//                    alignment: Alignment.bottomRight,
//                    child: ElevatedButton.icon(
//                      onPressed: () => _editEvent(_focusedIndex),
//                      label: Icon(Icons.edit),
//                    ),
//                  ),
//                ),
//                Visibility(
//                  visible: widget.isAdmin,
//                  child: SizedBox(
//                    width: 10,
//                  ),
//                ),
//                Visibility(
//                  visible: widget.isAdmin,
//                  child: Align(
//                    alignment: Alignment.bottomRight,
//                    child: ElevatedButton.icon(
//                      onPressed: _enableQrMode,
//                      label: Icon(Icons.qr_code),
//                    ),
//                  ),
//                ),
//              ],
            )
          ],
        ),
      );
    } else
      return SizedBox(
        width: 350,
        height: 350,
      );

    // return Container(
    //   height: 350,
    //   child: Text("No Data"),
    // );
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
//        child: Container(
//          decoration: BoxDecoration(
//            image: DecorationImage(
//                image: image[index].image, fit: BoxFit.fill),
//            borderRadius: BorderRadius.circular(20),
//
//          ),
//        ),
      ),
    );
  }

  int age_calc(String birth) {
    // La stringa della data di nascita
    String birthDateString = birth;

    // Converte la stringa in DateTime
    DateTime birthDate =
        DateTime.parse(birthDateString.split('/').reversed.join('-'));

    // Data corrente
    DateTime today = DateTime.now();

    // Calcola l'età in anni
    int age = today.year - birthDate.year;

    // Corregge l'età se il compleanno non è ancora passato quest'anno
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<void> _accepetUser(up.User user) async {

  }

  Widget joinEventButton(double bWidth, double bHeight, String text, Icon icon,
      Color color, VoidCallback onPressed) {
    int b = color.blue;
    int r = color.red;
    int g = color.green;
    return GestureDetector(
      child: Container(
        width: bWidth,
        height: bHeight,
        decoration: BoxDecoration(
          color: Color.fromRGBO(r, g, b, 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Visibility(
              visible: icon != null,
              child: Icon(
                icon?.icon ?? Icons.add,
                color: color,
              )),
          SizedBox(
            width: 15,
          ),
          Visibility(
            visible: text != "",
            child:
                Text(text ?? "", style: TextStyle(color: color, fontSize: 20)),
          ),
        ]),
      ),
      onTap: onPressed,
    );
  }

  Widget _qrCodeReaderWidget() {
    var user = up.User.new( // per debug
        name: "Mattia",
        surname: "Morbidelli",
        address: "Via degli Oppi, 134",
        birthdate: "15/07/2008",
        birthplace: "Arezzo",
        cap: "52043",
        cardNumber: 0,
        city: "Castglion Fiorentino",
        email: "mattia.morbidelli@gmail.com",
        telephone: "3496880713");
    //DateDuration age = AgeCalculator.age(DateTime(DateTime.parse(user.birthdate) as int));
    int age = age_calc(user.birthdate);
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
                stopOnFirstResult: true,

                //set false if you don't want to stop video preview on getting first result
                onGetResult: (result) {
                  var decryptedData = AesHelper.decrypt(result);
                  var json = jsonDecode(decryptedData);
                  user = up.User.fromJson(json);
                  //ScaffoldMessenger.of(context).showSnackBar(
                  //    SnackBar(content: Text("${user.name} ${user.surname}")));
                  setState(() {
                    _qrMode = 2;
                  });
                },
                width: 100,
                height: 100 //MediaQuery.sizeOf(context).width - 20,
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
                  setState(() {
                    _qrMode = 0;
                  });
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                backgroundColor: Color.fromRGBO(17, 17, 17, 1),
                onPressed: () {
                  setState(() {
                    _qrMode = 2;
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Visibility(
            visible: _qrMode == 2,
            child: Container(
              //padding: EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.upperEvent[_focusedIndex].title,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "NOME  ",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        "${user.name} ${user.surname}",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "DATA DI NASCITA  ",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        user.birthdate,
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
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
                        "${age} anni",
                        style: TextStyle(
                            color: age < 18 ? Colors.red : Colors.white,
                            fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      joinEventButton(
                        170,
                        50,
                        "Rifiuta",
                        Icon(Icons.close),
                        Colors.red,
                        () => setState(() {
                          _qrMode = 1;
                        }),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      joinEventButton(170, 50, "Accetta", Icon(Icons.add),
                          Colors.green, () => _accepetUser(user)),
                    ],
                  )
                ],
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_qrMode == 0) {
      return Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ScrollSnapList(
                dynamicItemSize: true,
                margin: EdgeInsets.symmetric(vertical: 10),
                onItemFocus: _onItemFocus,
                itemSize: 410,
                itemBuilder: _buildListItem,
                itemCount: data.length,
                key: sslKey,
                background: Colors.white,
                padding: EdgeInsets.all(8.0),
                //dynamicItemOpacity: 0.2,
                //listViewPadding: EdgeInsets.all(8.0),
              ),
            ),
            _buildItemDetail(),
          ],
        ),
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
    context.pushNamed(Routes.editEventScreen,
        arguments: widget.upperEvent[index]);
  }

//@override
//Widget build(BuildContext context) {
//  return Visibility(
//    visible: visible,
//    child: Container(
//      margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
//      width: MediaQuery.sizeOf(context).width,
//      height: 200,
//      decoration: BoxDecoration(
//        color: Colors.white,
//        borderRadius: BorderRadius.circular(10),
//        boxShadow: [
//          BoxShadow(
//            color: Colors.grey.withOpacity(0.5),
//            spreadRadius: 3,
//            blurRadius: 3,
//            offset: Offset(0, 0), // changes position of shadow
//          ),
//        ],
//      ),
//      child: Row(
//        children: [
//          Container(
//            margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
//            width: 200,
//            height: 200,
//            decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.circular(5),
//              image: DecorationImage(
//                image: image.image,
//                fit: BoxFit.fill,
//              ),
//            ),
//          ),
//          Gap(30.w),
//          Expanded(
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              children: [
//                Align(
//                  alignment: Alignment.centerLeft,
//                  child: Text(
//                    widget.upperEvent.title,
//                    style: TextStyle(
//                      fontSize: 25,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//                Align(
//                  alignment: Alignment.centerLeft,
//                  child: Text(
//                    widget.upperEvent.date,
//                    style: TextStyle(
//                      fontSize: 18,
//                      fontWeight: FontWeight.bold,
//                    ),
//                  ),
//                ),
//                Expanded(
//                  child: Row(
//                    children: [
//                      Align(
//                        alignment: Alignment.bottomRight,
//                        child: ElevatedButton.icon(
//                          onPressed: _joinEvent,
//                          label: Icon(Icons.person_add_alt_1),
//                        ),
//                      ),
//                      Gap(15.w),
//                      Visibility(
//                        visible: widget.isAdmin,
//                        child: Align(
//                          alignment: Alignment.bottomRight,
//                          child: ElevatedButton.icon(
//                            onPressed: _editEvent,
//                            label: Icon(Icons.edit),
//                          ),
//                        ),
//                      )
//                    ],
//                  ),
//                ),
//                SizedBox(
//                  height: 20,
//                ),
//              ],
//            ),
//          )
//        ],
//      ),
//    ),
//  );
//}

//@override
//idget build(BuildContext context) {
//  return Visibility(
//    visible: visible,
//    child: Container(
//
//    ),
//  );
//
//}
}
