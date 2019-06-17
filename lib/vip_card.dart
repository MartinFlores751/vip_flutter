import 'package:flutter/material.dart';

//VIP card returns a Card widget that displays a
//VIP's name, and logon status (indicated by color)
//Contains buttons for Helper to access additional resources
//TODO: Refactor card code
class VIPCard extends StatefulWidget {
  final String userName;
  final dynamic loginStatusMap;
  VIPCard({this.userName, this.loginStatusMap});

  @override
  _VIPCardState createState() => _VIPCardState();
}

class _VIPCardState extends State<VIPCard> {

  Decoration get offlineSaturate {
    if (widget.loginStatusMap['online'])
      return null;
    else
      return BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
        bottomRight: Radius.circular(25.0),
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                color: Colors.blue,
                height: MediaQuery.of(context).size.height * .08,
                width: MediaQuery.of(context).size.width * .8,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        child: Text("${widget.userName}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), ),
                        padding:  EdgeInsets.fromLTRB(0, 0, 0, 10),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  )
                ),
                foregroundDecoration: offlineSaturate
              ),
              Container(
                color: widget.loginStatusMap['online'] ? Colors.greenAccent : Colors.grey[300],
                height: MediaQuery.of(context).size.height * .15,
                width: MediaQuery.of(context).size.width * .8,
                child: Center(
                  child: Row(
                    children: <Widget>[
                      //TODO: Add button functionality
                      IconButton(icon: Icon(Icons.videocam, size: 50, color: Colors.blueAccent,), onPressed: () {},),
                      IconButton(icon: Icon(Icons.remove_circle, size: 50, color: Colors.redAccent), onPressed: () {},),
                      IconButton(icon: Icon(Icons.person_add, size: 50, color: Colors.purpleAccent), onPressed: () {},),
                    ],
                    mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
                  )
                ),
                foregroundDecoration: offlineSaturate,
              )
            ],
          ),                
          Container(
            child: Icon(Icons.account_circle, color: Colors.blue, size: 70,),
            decoration: BoxDecoration(
              color: widget.loginStatusMap['online'] ? Colors.greenAccent : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            transform: Matrix4.translationValues(15, 15, 0),
            foregroundDecoration: offlineSaturate,
          ),
        ],
      )
    );
  }
}
