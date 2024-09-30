import 'package:flutter/material.dart';
import 'package:upper/models/event.dart';

class EventTile extends StatelessWidget {
  UpperEvent upperEvent;

  EventTile({super.key, required this.upperEvent});

//  @override
//  Widget build(BuildContext context) {
//    return Container(
//        margin: EdgeInsets.all(5),
//        decoration: BoxDecoration(
//          color: Colors.white,
//          borderRadius: BorderRadius.circular(20),
//        ),
//        child: Column(children: [
//          ClipRRect(
//            borderRadius: BorderRadius.circular(12),
//            child: Image.asset('assets/images/no-internet.png'),
//          ),
//          SizedBox(height: 10),
//          Column(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: [
//              Padding(
//                padding: const EdgeInsets.only(left: 30.0, bottom: 5.0),
//                child: Text(
//                  upperEvent.title,
//                  style: TextStyle(
//                      color: Colors.black,
//                      fontSize: 15,
//                      fontWeight: FontWeight.bold),
//                ),
//              ),
//              Padding(
//                padding: const EdgeInsets.only(left: 30.0),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    Column(
//
//                      children: [
//                        Row(
//                          children: [
//                            Icon(Icons.place),
//                            Text(upperEvent.place),
//                          ],
//                        ),
//                        Row(
//                          children: [
//                            Icon(Icons.calendar_month),
//                            Text(upperEvent.date),
//                            Text('  '),
//                            Text(upperEvent.time),
//                          ],
//                        ),
//                      ],
//                    ),
//                    Padding(
//
//                      padding: const EdgeInsets.only(left: 30.0),
//                      child: Row(
//                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                        children: [
//                          Icon(Icons.add),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//
//            ],
//          )
//        ]));
//  }
//}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/no-internet.png'),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 25,),
              Column(
                children: [
                  Text(upperEvent.title,style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      SizedBox(width: 15),
                      Icon(
                        Icons.place_outlined,
                        color: Colors.black54,
                      ),
                      Text(
                        upperEvent.place,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 29),
                      Icon(
                        Icons.calendar_month,
                        color: Colors.black54,
                      ),
                      Text(
                        upperEvent.date,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        upperEvent.time,
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
