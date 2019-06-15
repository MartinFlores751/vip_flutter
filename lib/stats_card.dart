import 'package:flutter/material.dart';

import 'package:vip_flutter/firestore_stuff.dart';

//  To use this card, supply a title, titleColor, 
//  and tell whether to display all, only VIP, or only Helper.
//  See firestore_stuff.dart for streamsForOnlineBlocks
//  
//  callback is optional. Used to chain animations back to back.
//  See logged_acc.dart for example
class StatsCard extends StatefulWidget {
  StatsCard({@required this.title, @required this.titleColor, @required this.whoToShow, this.callBack});
  final String title;
  final Color titleColor;
  final String whoToShow;
  final Function callBack;

  @override
  _StatsCardState createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard> with TickerProviderStateMixin{
  AnimationController controller;
  Animation<double> animation, slideAnim;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500 ), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.callBack() != null) widget.callBack();
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    //Most of the styling of the card is here
    Widget customCard = ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.0),
        topRight: Radius.circular(25.0),
        bottomRight: Radius.circular(25.0),
      ),
      child: Column(
        children: <Widget>[
          Container(
            color: widget.titleColor,
            height: MediaQuery.of(context).size.height * .08,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: Text("${widget.title}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
            )
          ),
          Container(
            color: Colors.grey[300],
            height: MediaQuery.of(context).size.height * .15,
            width: MediaQuery.of(context).size.width * .8,
            child: Center(
              child: streamsForOnlineBlocks(false, widget.whoToShow, 60)
            )
          )
        ]
      )
    );

    //customCard is wrapped in a SlideTransition and FadeTransition
    Widget slideIn = SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -.5),
        end: Offset.zero
      ).animate(animation),
      child: customCard
    );

    Widget fadeIn = Container(
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[slideIn],
        )
      )
    );

    return  fadeIn;    
  }

}