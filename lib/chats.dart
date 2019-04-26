import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

String parentUserId, parentUserName,childUserName, childUserUid;

class ChatPage extends StatefulWidget {
  ChatPage({String currUserUid, String currUserName, String userName, String userUid}) {
    parentUserId = currUserUid;
    childUserName = userName;
    childUserUid = userUid;
    parentUserName=currUserName;
  }

  @override
  _ChatPageState createState() => new _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    DatabaseReference userChatRef=FirebaseDatabase.instance.reference().child("chats/$parentUserId");
    userChatRef.keepSynced(true);
    var chatView =  new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Flexible(
                    
                    child: new FirebaseAnimatedList(
                      query: userChatRef.child(childUserUid),
                      reverse: true,
                      sort: (a, b) => b.key.compareTo(a.key),
                      itemBuilder:
                          (context, DataSnapshot snapshot, animation, val) {
                        if (snapshot != null) {
                          MessageClass messageClass = new MessageClass(
                              snapshot.value['message'],
                              snapshot.value['name'],
                              snapshot.value['sender'],
                              int.parse(snapshot.key)
                            );
                          return new ChatMessage(
                            message: messageClass.message,
                            sender: messageClass.sender,
                            name: messageClass.name,
                            time: DateTime.fromMillisecondsSinceEpoch(messageClass._time),
                          );
                        }
                      },
                      defaultChild: new Center(child: new Text("No Messages")),
                      
                    ),
                  ),
                  new Divider(),
                  _buildTextComposer(userChatRef)
                ],
              );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(childUserName),
      ),
      body: chatView,
    );
  }

  Widget _buildTextComposer(DatabaseReference userChatRef) {
    TextEditingController _textController = new TextEditingController();
    return new Container(
      padding: const EdgeInsets.only(left: 10.0),
      child: new Row(
        children: <Widget>[
          new Flexible(
            child: new TextField(
              
              onSubmitted: (String message){String name = parentUserName;
                bool sender = true;
                String time = DateTime.now().millisecondsSinceEpoch.toString();
                userChatRef
                    .child(childUserUid)
                    .child(time)
                    .set({"name": name, "message": message, "sender": sender});
                userChatRef
                    .parent()
                    .child(childUserUid)
                    .child(parentUserId)
                    .child(time)
                    .set({"name": name, "message": message, "sender": !sender});
                _textController.clear();
              }
,
              controller: _textController,
            ),
          ),
          new Container(
            child: new IconButton(
              icon: new Icon(Icons.send),
              onPressed: () {
                String name = parentUserName;
                String message = _textController.text;
                bool sender = true;
                String time = DateTime.now().millisecondsSinceEpoch.toString();
                userChatRef
                    .child(childUserUid)
                    .child(time)
                    .set({"name": name, "message": message, "sender": sender});
                userChatRef
                    .parent()
                    .child(childUserUid)
                    .child(parentUserId)
                    .child(time)
                    .set({"name": name, "message": message, "sender": !sender});
                _textController.clear();
              },
            ),
          )
        ],
      ),
    );
  }
}

class MessageClass{
  String _message,_name;
  bool _sender;
  int _time;
  MessageClass(this._message,this._name,this._sender,this._time);
  set message(message)=>this.message=message;
  set name(name)=>this.name=name;
  set sender(sender)=>this.sender=sender;
  set time(time)=>this.time=time;
  String get message=>_message;
  bool get sender=>_sender;
  String get name=>_name;

}
class ChatMessage extends StatelessWidget {
  final String message,name;
  final bool sender;
  final DateTime time;
  ChatMessage({this.message,this.name,this.sender,this.time});
  @override
  Widget build(BuildContext context) {
    return new Container(
//      padding: EdgeInsets.all(4.0),
//      margin: const EdgeInsets.all(8.0),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: !sender?MainAxisAlignment.start:MainAxisAlignment.end,
                
        children:<Widget>[
          new Container(
            margin: const EdgeInsets.only(right:8.0),
            child:  new CircleAvatar(
              child: new Text(name[0].toUpperCase()),
            )
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(name,style: Theme.of(context).textTheme.body2,),
              new Text(message),
              new Text("${time.day}-${time.month} ${time.hour}:${time.minute} ",style: new TextStyle(fontSize: 10.0),)
            ],
          ),

        ]
      ),
    );
  }
}

