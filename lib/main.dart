import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'package:flutter/services.dart';
void main()=>runApp(new TigdiKaApp());

FirebaseUser user;

class TigdiKaApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            if(snapshot.data==null)
              return new LoginPage();
            else
              return new HomePage();
          }else{
            return new AlertDialog(
              content: new Text("Loading App..."),
            );
          }

        },
      ),
      theme: new ThemeData(
        primaryColor: Colors.blue
      ),

    );

  }


}
class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new LoginPageState();
  }
  
}
class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{
  AnimationController _iconAnimationController;
  Animation _iconAnimation;
  final  _emailIdController=new TextEditingController();
  final  _passwordController=new TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  bool _autovalidate=false;
  final Key loginKey=new Key("loginButton");
  @override
  void initState(){
    super.initState();
    _iconAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(milliseconds: 500)
    );

    _iconAnimation = new CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.bounceIn
    );
   _iconAnimation.addListener(()=>this.setState((){}));
   _iconAnimationController.forward();
  }
  String _validatingField(String val){
    if(val.isEmpty)
      return "Fill the details";
    return null;
  }
  TextFormField textBox({String hintText,TextInputType type,bool password=false,IconData icon,TextEditingController controller}){
    return new TextFormField(
      validator: _validatingField,
      maxLines: 1,
      decoration: new InputDecoration(
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
        child: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,            
            children: <Widget>[
              
              new FlutterLogo(
                size: _iconAnimation.value*100,
              ),
              new Form(
                key: formKey,
                autovalidate: _autovalidate,
                child: new Column(
                  children: <Widget>[
                    textBox(hintText: "Enter Email id",type: TextInputType.emailAddress,icon: Icons.email,controller: _emailIdController)
                    ,
                    textBox(hintText: "Enter Password",type: TextInputType.text,password: true,icon:Icons.lock,controller: _passwordController),
                    new Container(
                      margin: EdgeInsets.only(top:32.0),
                      child: new RaisedButton(
                        key: loginKey,
                        onPressed:()=>onPressLogin(_emailIdController.text.trim(),_passwordController.text.trim()),
                        child: new Text("Login"),
                        padding: EdgeInsets.symmetric(horizontal:69.0),
                        splashColor: Colors.blue,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10.0)))                      
                        //minWidth: 500.0,
                      ),
                    ),
                    new Container(
                      margin: EdgeInsets.only(top:32.0),
                      child: new RaisedButton(
                        onPressed:()=>onPressNavigate(),
                        child: new Text("Dont't have an account? Sign Up"),
                        padding: EdgeInsets.all(12.0),
                        splashColor: Colors.blueGrey,
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10.0)))                      
                      ),
                    )


                  ],
                ),
              )

            ],
          ),
        ),
      )
    );

  }

  onPressLogin(String emailid,String password){
    FormState form=formKey.currentState;
    loginKey.hashCode;
    if(!form.validate()){
      _autovalidate=true;
      showSnackbar("Email id and password not filled");
      return;
    }else{
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailid,password: password).then((onValue){
        if(onValue!=null){
          Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>new HomePage()));
        }else{
          showSnackbar(onValue.toString());
        }
      }).catchError((onError){
        showSnackbar(onError.message);
      });

    }

  }
  void showSnackbar(String text){
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }
  onPressNavigate(){
//Navigator.push(context, new MaterialPageRoute(builder: (context)=>new Signup()));
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context)=>new Signup()));
  }


}