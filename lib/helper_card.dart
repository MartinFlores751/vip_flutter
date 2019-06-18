import 'package:flutter/material.dart';

import 'package:vip_flutter/states/user_state_container.dart';
import 'package:vip_flutter/db_crud.dart';

// Note: This could be a stateless widget, but we can change that later...

class HelperCard extends StatefulWidget {
  final String username;
  final dynamic mapValue;
  HelperCard({this.username, this.mapValue});

  @override
  _HelperCardState createState() => _HelperCardState();
}

class _HelperCardState extends State<HelperCard> {
  // Builds color for what?
  _buildColor(int i) {
    if (i == 0) {
      return Colors.greenAccent[100];
    } else if (i == 1) {
      return Colors.yellowAccent[100];
    } else {
      return Colors.grey[300];
    }
  }

  Decoration get helperForegroundOnline {
    if (widget.mapValue['online'])
      return null;
    else
      return BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      );
  }

  Decoration get helperOnline {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
      ),
      color: widget.mapValue['away'] ? _buildColor(1) : _buildColor(0),
    );
  }

  Decoration get helperOffline {
    return BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
        ),
        color: _buildColor(2));
  }

  // Helper Cards
  Widget get _buildIt {
    var con = Container(
        height: 180,
        child: Column(
          children: <Widget>[
            Text("${widget.username}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold)),
            Divider(
              color: Colors.black,
            ),
            widget.mapValue['away']
                ? Text("Status: Away", style: TextStyle(fontSize: 20.0))
                : (widget.mapValue['online']
                    ? Text("Status: Available",
                        style: TextStyle(fontSize: 20.0))
                    : Text("Status: Offline",
                        style: TextStyle(fontSize: 20.0))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 75,
                  color: Colors.purple,
                  icon: Icon(Icons.person_add),
                  onPressed: () {
                    debugPrint('Adding to favorites!');
                    addFavorite(widget.username);
                  },
                ),
                IconButton(
                  iconSize: 75,
                  color: Colors.blue,
                  icon: Icon(Icons.videocam),
                  onPressed: () {
                    UserContainer.of(context).callUser(widget.username);
                  },
                ),
                IconButton(
                  iconSize: 75,
                  color: Colors.red,
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ));

    return Container(
      foregroundDecoration: helperForegroundOnline,
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: widget.mapValue['online'] ? helperOnline : helperOffline,
      child: ListTile(
        title: Icon(Icons.account_circle, color: Colors.blue, size: 75),
        subtitle: con,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildIt;
  }
}
