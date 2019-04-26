import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'chats.dart';
import 'main.dart';
import 'account.dart';

FirebaseUser user;
DatabaseReference userRef =
    FirebaseDatabase.instance.reference().child("users");
DatabaseReference chatsRef;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print('Token Is' + token);
    });
  }

  @override
  Widget build(BuildContext context) {
    userRef.keepSynced(true);
    return new FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            user = snapshot.data;
            _firebaseMessaging.getToken().then((token) {
              FirebaseDatabase.instance
                  .reference()
                  .child("tokens/" + user.uid)
                  .set(token);
            });
            chatsRef = FirebaseDatabase.instance
                .reference()
                .child("chats/" + user.uid);
            chatsRef.keepSynced(true);
            if (user == null)
              Navigator.pushReplacement(context,
                  new MaterialPageRoute(builder: (context) => new LoginPage()));
            else
              return new DefaultTabController(
                length: 2,
                child: new Scaffold(
                    appBar: new AppBar(
                      title: new Text("Realtime Chat App"),
                      actions: <Widget>[
                        new IconButton(
                            tooltip: "Log Out",
                            icon: new Icon(Icons.power_settings_new),
                            onPressed: () {
                              FirebaseAuth.instance.signOut().then((onValue) {
                                Navigator.pushReplacement(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new LoginPage()));
                              });
                            }),
                        new IconButton(
                          tooltip: "${user.displayName}",
                          icon: new Icon(Icons.account_circle),
                          onPressed: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => new AccountPage()));
                          },
                        )
                      ],
                      bottom: new TabBar(
                        tabs: <Widget>[
                          new Tab(
                            icon: new Icon(Icons.chat),
                            text: "Chats",
                          ),
                          new Tab(
                            icon: new Icon(Icons.people),
                            text: "All Users",
                          )
                        ],
                      ),
                    ),
                    body: new TabBarView(
                      children: <Widget>[
                        chatsUI(),
                        allUsersUI(),
                      ],
                    )),
              );
          } else {
            return new AlertDialog(
              content: new Text("Signing In...."),
            );
          }
        });
  }

  DefaultTabController ui() {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
          appBar: new AppBar(
            title: new Text("Realtime Chat App"),
            actions: <Widget>[
              new IconButton(
                  tooltip: "Log Out",
                  icon: new Icon(Icons.power_settings_new),
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((onValue) {
                      Navigator.pushReplacement(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new LoginPage()));
                    });
                  })
            ],
            bottom: new TabBar(
              tabs: <Widget>[
                new Tab(
                  icon: new Icon(Icons.chat),
                  text: "Chats",
                ),
                new Tab(
                  icon: new Icon(Icons.people),
                  text: "All Users",
                )
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              chatsUI(),
              allUsersUI(),
            ],
          )),
    );
  }

  Widget chatsUI() {
    return new FirebaseAnimatedList(
      query: chatsRef,
      padding: EdgeInsets.all(5.0),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int i) {
        return new FutureBuilder(
          future: FirebaseDatabase.instance
              .reference()
              .child("users/" + snapshot.key)
              .once(),
          builder: (BuildContext context, AsyncSnapshot asnapshot) {
            if (asnapshot.connectionState == ConnectionState.done) {
              DataSnapshot snap = asnapshot.data;
              return list(uid: snapshot.key, name: snap.value);
            } else
              return new Container();
          },
        );
      },
      defaultChild: new AlertDialog(
        title: Text("Getting Recent Contacts..."),
        content: Text("Loading"),
      ),
    );
  }

  Widget allUsersUI() {
    return new FirebaseAnimatedList(
      query: userRef.orderByKey(),
      padding: EdgeInsets.all(5.0),
      reverse: false,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int i) {
        return list(uid: snapshot.key, name: snapshot.value);
      },
      defaultChild: new AlertDialog(
        title: Text("Getting Contacts..."),
        content: Text("Loading"),
      ),
    );
  }

  Widget list({String uid, String name}) {
    return new ListTile(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new ChatPage(
                      currUserUid: user.uid,
                      currUserName: user.displayName,
                      userUid: uid,
                      userName: name,
                    )));
      },
      leading: new CircleAvatar(
        child: new Text(name.substring(0, 1).toUpperCase()),
      ),
      title: new Container(
          padding: EdgeInsets.only(left: 5.0),
          child: new Text(name.substring(0, 1).toUpperCase() +
              name.substring(1).toLowerCase())),
    );
  }
}
