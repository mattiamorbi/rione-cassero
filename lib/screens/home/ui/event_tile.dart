import 'package:flutter/material.dart';
import 'package:upper/models/event.dart';

class EventTile extends StatelessWidget {
  UpperEvent upperEvent;

  EventTile({super.key, required this.upperEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/no-internet.png'),
          ),
          SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 5.0),
                child: Text(
                  upperEvent.title,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(

                      children: [
                        Row(
                          children: [
                            Icon(Icons.place),
                            Text(upperEvent.place),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_month),
                            Text(upperEvent.date),
                            Text('  '),
                            Text(upperEvent.time),
                          ],
                        ),
                      ],
                    ),
                    Padding(

                      padding: const EdgeInsets.only(left: 30.0),
                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          )
        ]));
  }
}
