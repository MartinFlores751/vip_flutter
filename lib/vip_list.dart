import 'package:flutter/material.dart';

import 'package:vip_flutter/vip_card.dart';

//TODO: Sort VIPs in order of those Online, Away, then Offline
class VIPList extends StatelessWidget {
  final Map<String, dynamic> vips;
  VIPList({this.vips});

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  ListView _buildList(context) {
    return ListView.builder(
      itemCount: vips.length,
      itemBuilder: (context, index) {
        //Usernames are keys to the map of collective login statuses
        String userName = vips.keys.elementAt(index);
        return Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15,),
              VIPCard(userName: userName, loginStatusMap: vips[userName])
            ],
          )
        );
      },
    );
  }
}
