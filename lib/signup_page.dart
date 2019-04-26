import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main.dart';
import 'home_page.dart';

class Signup extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new SignupState();
  }
  
}
class SignupState extends State<Signup> with SingleTickerProviderStateMixin{
  final _emailIdController=new TextEditingController();
  final _passwordController=new TextEditingController();
  final _usernameController=new TextEditingController();
  bool _autovalidate=false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _validatingField(String val){
    if(val.isEmpty)
      return "Fill The Details";
    return null;
  }

  TextFormField textBox({String hintText,TextInputType type,bool password=false,IconData icon,TextEditingController controller}){
    return new TextFormField(
      validator: _validatingField,
      maxLines: 1,
      decoration: new InputDecoration(
        filled: true,
        labelText: hintText,
        labelStyle: new TextStyle(
          color: Colors.white,
        ),
        icon: new Icon(icon,color: Colors.white)
      ),
      style: new TextStyle(
        color: Colors.white,
        fontSize: 16.0
        
      ),
      controller: controller,
      keyboardType: type,
      obscureText: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body  : new Container(
        padding : EdgeInsets.symmetric(horizontal:  40.0),
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage("assets/background_image.jpg"),
            fit: BoxFit.cover
          )
        ),
        child:  new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            new FlutterLogo(
              size: 100.0,
            ),
            new Form(
              key: formKey,
              autovalidate: _autovalidate,
              child: new Column(
                children: <Widget>[
                  textBox(hintText: "Enter Username",type: TextInputType.text,icon: Icons.account_box,controller: _usernameController),
                  textBox(hintText: "Enter Email id",type: TextInputType.emailAddress,icon: Icons.email,controller: _emailIdController)
                  ,
                  textBox(hintText: "Enter Password",type: TextInputType.text,password: true,icon:Icons.lock,controller: _passwordController),
                  new Container(
                    margin: EdgeInsets.only(top:32.0),
                    child: new RaisedButton(
                      onPressed:()=>onPressLogin(),
                      child: new Text("Sign Up"),
                      splashColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal:54.0),
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10.0)))                      
                      //minWidth: 500.0,
                    ),
                  ),
                  new Container(
                    margin: EdgeInsets.only(top:32.0),
                    child: new RaisedButton(
                      onPressed:()=>onPressNavigate(),
                      child: new Text("Already have an account?Login"),
                      padding: EdgeInsets.all(12.0),
                      splashColor: Colors.blueGrey,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10.0)))                      
                    ),
                  ),


                ],
              ),
            )

          ],
        ),
      )
    );

  }

  onPressLogin(){
    final FormState form=formKey.currentState;
    if(!form.validate()){
      _autovalidate=true;
      showSnackbar("Enter email id and password");
      return;
    }else{
      FirebaseAuth auth=FirebaseAuth.instance;
      auth.createUserWithEmailAndPassword(email: _emailIdController.text.trim(),
      password: _passwordController.text.trim())
      .then((onValue){
        if(onValue!=null){
          UserUpdateInfo userUpdateInfo=new UserUpdateInfo();
          userUpdateInfo.displayName=_usernameController.text.trim();
          FirebaseDatabase.instance.reference().child("users").child(onValue.uid).set(_usernameController.text.trim()).then((onValue){
          auth.currentUser().then((user){
            user.updateProfile(userUpdateInfo).then((onValue){
              Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>new HomePage()));
            });

          });

          });
        }else{
          showSnackbar(onValue.toString());
        }
      }).catchError((onError){
         showSnackbar(onError.message); 
      });
    }
  }
  void showSnackbar(String val){
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(val)));
  }
  onPressNavigate(){
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>new LoginPage()));
  }


}