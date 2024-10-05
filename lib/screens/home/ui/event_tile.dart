import 'dart:convert';

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

  bool _qrMode = false;

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
      _qrMode = true;
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
              height: 10,
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

  Widget _qrCodeReaderWidget() {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Expanded(
          child: FlutterWebQrcodeScanner(
              cameraDirection: CameraDirection.back,
              stopOnFirstResult: true,

              //set false if you don't want to stop video preview on getting first result
              onGetResult: (result) {
                var decryptedData = AesHelper.decrypt(result);
                var json = jsonDecode(decryptedData);
                var user = up.User.fromJson(json);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${user.name} ${user.surname}")));
              },
              width: 100,
              height: 100 //MediaQuery.sizeOf(context).width - 20,
              ),
        ),
        FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 10), content: Text("DEBUG")));
          },
          child: Icon(Icons.add),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_qrMode) {
      return Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ScrollSnapList(
                dynamicItemSize: true,
                margin: EdgeInsets.symmetric(vertical: 10),
                onItemFocus: _onItemFocus,
                itemSize: 400,
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
        width: 400,
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
