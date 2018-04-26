import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => new _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: FirebaseAuth.instance.currentUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        FirebaseUser user = snapshot.data;
        if (user != null) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text("${user.displayName.toUpperCase()}'s Profile"),
            ),
            body: new Container(
              margin: const EdgeInsets.only(top: 32.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new CircleAvatar(
                    child: new Text("${user.displayName[0].toUpperCase()}",style: new TextStyle(fontSize: 50.0),),
                    radius: 50.0,
                  ),
                  new Container(
                    margin: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 0.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text("Username:  ",style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0),),
                        new Text("  ${user.displayName}  ",style: new TextStyle(fontSize: 14.0),),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.fromLTRB(15.0, 15.0, 0.0, 0.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text("Email Address:  ",style: new TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0),),
                        new Text("  ${user.email}  ",softWrap: true,style: new TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return new Center(child: new Text("Error"));
        }
      },
    );
  }
}
