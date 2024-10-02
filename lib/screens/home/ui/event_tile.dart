import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/auth_cubit.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/routing/routes.dart';

// ignore: must_be_immutable
class EventTile extends StatefulWidget {
  final UpperEvent upperEvent;
  final bool isAdmin;

  const EventTile({super.key, required this.upperEvent, required this.isAdmin});

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
      final imageData = await widget.upperEvent.getEventImage();
      if (imageData != null) {
        setState(() {
          image = Image.memory(imageData);
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

  Future<void> _joinEvent() async {
    await context.read<AuthCubit>().joinEvent(widget.upperEvent.id!);
  }

  Future<void> _editEvent() async {
    context.pushNamed(Routes.editEventScreen, arguments: widget.upperEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
        width: MediaQuery.sizeOf(context).width,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 3,
              offset: Offset(0, 0), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: image.image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Gap(30.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.upperEvent.title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.upperEvent.date,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: _joinEvent,
                            label: Icon(Icons.person_add_alt_1),
                          ),
                        ),
                        Gap(15.w),
                        Visibility(
                          visible: widget.isAdmin,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton.icon(
                              onPressed: _editEvent,
                              label: Icon(Icons.edit),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
