import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginRouteState();
  }
}

class LoginRouteState extends State<LoginRoute> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  SharedPreferences sp;
  bool _pwdVisible = false;
  GlobalKey globalKey = new GlobalKey<FormState>();
  bool _isSavePw = true;
  bool _isAutoLogin = true;

  String _user = "";
  String _pwd = "";

  @override
  void initState() {
    super.initState();
    initData();
    autoLogin();
  }

  initData() {
    _isSavePw = SPUtil.getBool('_isSavePw', true);
    _isAutoLogin = SPUtil.getBool('_isAutoLogin', true);
    _user = SPUtil.getString('_user', "");
    _pwd = SPUtil.getString('_pwd', "");
    setState(() {
      _nameController.text = _user;
      _passwordController.text = _pwd;
    });
  }

  autoLogin() {
    if (_isAutoLogin) _onLogin();
  }

  @override
  Widget build(BuildContext context) {
    print(_user);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 128, 16, 16),
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
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: "用户名",
                    hintText: "手机号/邮箱",
                    prefixIcon: Icon(Icons.person)),
                validator: (v) {
                  return v.trim().isNotEmpty ? null : v.trim();
                },
              ),
              // 密码
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "密码",
                  hintText: "密码",
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _pwdVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _pwdVisible = !_pwdVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_pwdVisible,
                validator: (v) {
                  return v.trim().isNotEmpty ? null : v.trim();
                },
              ),
              // 登陆按钮
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isSavePw,
                          activeColor: Colors.blue,
                          onChanged: (bool val) {
                            setState(() {
                              _isSavePw = !_isSavePw;
                            });
                          },
                        ),
                        Text('保存密码')
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          value: _isAutoLogin,
                          activeColor: Colors.blue,
                          onChanged: (bool val) {
                            setState(() {
                              _isAutoLogin = !_isAutoLogin;
                              if (_isAutoLogin && _isSavePw == false)
                                _isSavePw = true;
                            });
                          },
                        ),
                        Text('自动登陆')
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints.expand(height: 55),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: _onLogin,
                    textColor: Colors.white,
                    child: Text("登陆"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 登陆
  void _onLogin() async {
    if (!(globalKey.currentState as FormState).validate()) return;
    SPUtil.setBool("_isSavePw", _isSavePw);
    SPUtil.setBool("_isAutoLogin", _isAutoLogin);

    if (_isSavePw) {
      SPUtil.setString("_user", _nameController.value.text);
      SPUtil.setString("_pwd", _passwordController.value.text);
    }

    // login
    UI.showProgressDialog(
        context: context,
        future: getToken(),
        title: '登陆',
        successCall: saveToken,
        failCall: (String errMsg) {
          print('token fail $errMsg');
        });
  }

  getToken() async {
    return Future.delayed(Duration(seconds: 2), () {
      //return Future.error('error');
      return "123456";
    }).catchError((onError) {
      return Future.error('error');
    });
  }

  saveToken(String token) {
    print("token succ $token");
  }
}
