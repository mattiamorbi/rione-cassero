import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upper/models/upper_event.dart';

// ignore: must_be_immutable
class EventTile extends StatefulWidget {
  UpperEvent upperEvent;

  EventTile({super.key, required this.upperEvent});

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  late Image image = Image(image: AssetImage("assets/images/loading.gif"));
  late bool visible = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final downloadUrl = await widget.upperEvent.getEventImage();
      setState(() {
        image = Image.network(downloadUrl);
        visible = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image: $e');
        visible = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).width / 1.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: image.image,
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                  width: MediaQuery.sizeOf(context).width / 6,
                  height: MediaQuery.sizeOf(context).width / 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.upperEvent.getDate().day.toString(),
                        //textHeightBehavior: ,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          fontSize: 45,
                          height: 1,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          months[widget.upperEvent.getDate().month],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  height: 40,
                  width: 40,
                  child: Center(
                      child: Icon(
                    Icons.person_add_alt_1,
                    color: Colors.black54,
                  )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
