import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashRouteState();
  }
}

class SplashRouteState extends State<SplashRoute> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _pwdShow = false;
  GlobalKey globalKey = new GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("login"),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          autovalidate: true,
          key: globalKey,
          child: Column(
            children: <Widget>[
              // ICON
              Image(
                image: AssetImage("images/logo.png"),
                width: 100,
                height: 100,
              ),

              // 账号
              TextFormField(
                autofocus: _nameAutoFocus,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "user name" ,
                  hintText: "phone number or e-mail",
                  prefixIcon: Icon(Icons.person)
                ),
                validator: (v) {
                  return v.trim().isNotEmpty ? null : v.trim();
                },
              ),
              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "password",
                  hintText: "password",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_pwdShow ? Icons.visibility : Icons.visibility_off),
                    onPressed: (){
                      setState(() {
                        _pwdShow = !_pwdShow;
                      });
                    },
                  ),
                ),
                obscureText: _pwdShow,
                validator: (v) {
                  return v.trim().isNotEmpty ? null : v.trim();
                },
              ), 
              // 登陆按钮
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: _onLogin,
                    textColor: Colors.white,
                    child: Text("Login"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onLogin() async {
    if((globalKey.currentState as FormState).validate()){
      print("login .....");
    }
  }
}
