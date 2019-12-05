import 'package:flutter/material.dart';

import 'package:vip_flutter/helper_card.dart';

class HelperList extends StatelessWidget {
  final Map<String, dynamic> helpers;
  final VoidCallback frost;
  HelperList({this.helpers, this.frost});

  @override
  Widget build(BuildContext context) {
    return _buildList(context);
  }

  ListView _buildList(context) {
    return ListView.builder(
      itemCount: helpers.length,
      itemBuilder: (context, index) {
        String mapKey = helpers.keys.elementAt(index);
        return HelperCard(username: mapKey, mapValue: helpers[mapKey], frost: frost);
      },
    );
  }
}
