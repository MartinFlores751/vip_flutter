import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vip_flutter/helper_list.dart';

//function that sets online status
//vipOrHelper should be either 'allVip' or 'allHelpers'
void firestoreUpdateVIP(
    String userName, bool away, bool online, String vipOrHelper) {
  Map<String, dynamic> bodyCha = {
    "$userName": {
      "away": away,
      "online": online,
    }
  };
  Firestore.instance
      .collection('Users')
      .document('allUsers')
      .updateData(bodyCha);
  Firestore.instance
      .collection('Users')
      .document(vipOrHelper)
      .updateData(bodyCha);
}

//function that adds or subtracts to the total online if someone logs in or logs out
//vipOrHelper should be either 'VipOnline' or 'HelpersOnline'
void firestoreRunTransaction(int addOrSub, String vipOrHelper) {
  final DocumentReference postRef =
      Firestore.instance.collection("Users").document('OnlineCount');
  Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(postRef);
    if (postSnapshot.exists) {
      await tx.update(postRef, <String, dynamic>{
        'TotalOnline': postSnapshot.data['TotalOnline'] + addOrSub
      });
      await tx.update(postRef, <String, dynamic>{
        vipOrHelper: postSnapshot.data[vipOrHelper] + addOrSub
      });
    }
  });
}

//whoToChange has to be 1 of 3: 'HelpersOnline', 'VipOnline', or 'TotalOnline'
//the variable 'total' checks if TotalOnline is the one that will change
//fonSize is the fontSize for the Online Blocks
Widget streamsForOnlineBlocks(bool total, String whoToChange, double fonSize) {
  return StreamBuilder<DocumentSnapshot>(
    stream: Firestore.instance
        .collection('Users')
        .document('OnlineCount')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return CircularProgressIndicator();
        default:
          var a = snapshot.data;
          return Center(
            child: total
                ? Text(
                    "Total Online: ${a[whoToChange]}",
                    style: TextStyle(fontSize: fonSize),
                  )
                : Text(
                    "${a[whoToChange]}",
                    style: TextStyle(fontSize: fonSize),
                  ),
          );
      }
    },
  );
}

Widget streamForUsersOnline() {
  return StreamBuilder<DocumentSnapshot>(
    stream: Firestore.instance
        .collection('Users')
        .document('allHelpers')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Center(
            child: CircularProgressIndicator(),
          );
        default:
          var a = snapshot.data.data;
          return Container(
            child: HelperList(helpers: a),
          );
      }
    },
  );
}
