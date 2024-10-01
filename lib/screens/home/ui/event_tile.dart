import 'package:flutter/material.dart';
import 'package:upper/models/event.dart';

class EventTile extends StatelessWidget {
  UpperEvent upperEvent;

  EventTile({super.key, required this.upperEvent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).width / 1.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
            image: AssetImage("assets/images/upper.jpeg"), fit: BoxFit.cover),
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
                      upperEvent.date.split("/")[0],
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
                        months[int.parse(upperEvent.date.split("/")[1])],
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
                child:  Center(child: Icon(Icons.person_add_alt_1, color: Colors.black54,)),

              )

            ],
          ),
        ],
      ),
    );
  }
}

//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      margin: EdgeInsets.all(25),
//      decoration: BoxDecoration(
//        color: Colors.white,
//        borderRadius: BorderRadius.circular(20),
//      ),
//      child: Column(
//        children: [
//          ClipRRect(
//            borderRadius: BorderRadius.circular(12),
//            child: Image.asset('assets/images/no-internet.png'),
//          ),
//          SizedBox(height: 10),
//          Row(
//            children: [
//              SizedBox(width: 25,),
//              Column(
//                children: [
//                  Text(upperEvent.title,style: TextStyle(
//                    fontWeight: FontWeight.bold,
//                    fontSize: 25,
//                  ),),
//                  SizedBox(height: 3),
//                  Row(
//                    children: [
//                      SizedBox(width: 15),
//                      Icon(
//                        Icons.place_outlined,
//                        color: Colors.black54,
//                      ),
//                      Text(
//                        upperEvent.place,
//                        style: TextStyle(
//                          color: Colors.black54,
//                        ),
//                      ),
//                    ],
//                  ),
//                  Row(
//                    children: [
//                      SizedBox(width: 29),
//                      Icon(
//                        Icons.calendar_month,
//                        color: Colors.black54,
//                      ),
//                      Text(
//                        upperEvent.date,
//                        style: TextStyle(
//                          color: Colors.black54,
//                        ),
//                      ),
//                      SizedBox(width: 15),
//                      Text(
//                        upperEvent.time,
//                        style: TextStyle(
//                          color: Colors.black54,
//                        ),
//                      ),
//                    ],
//                  ),
//                ],
//              ),
//            ],
//          )
//        ],
//      ),
//    );
//  }
//}
