import 'dart:ui';

import 'package:bytes_cloud/core/manager/UserManager.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/pages/HomeRout.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class LoginRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginRouteState();
  }
}

class LoginRouteState extends State<LoginRoute> {
  int currentPage = 0; // 0 登陆 1 注册
  PageController controller = PageController(initialPage: 0);
  bool _pwdInVisible = true;

  // 登陆
  String _user = "";
  String _pwd = "";
  TextEditingController _loginUserController = TextEditingController();
  TextEditingController _loginPasswordController = TextEditingController();
  GlobalKey _loginKey = new GlobalKey<FormState>();

  // 注册
  TextEditingController _registerUserController = TextEditingController();
  TextEditingController _registerPasswordController1 = TextEditingController();
  TextEditingController _registerPasswordController2 = TextEditingController();
  GlobalKey _registerKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() {
    _user = SPUtil.getString('_user', "");
    _pwd = SPUtil.getString('_pwd', "");
    _loginUserController.text = _user;
    _loginPasswordController.text = _pwd;
  }

  avatorIcon() {
    return ClipOval(
      child: Image.asset(
        Constants.AVATOR,
        color: Colors.white60,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_user);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.only(top: 100),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: AssetImage(Constants.LOGIN_BG))),
          child: PageView(
            children: <Widget>[
              loginView(),
              registerView(),
            ],
            controller: controller,
            onPageChanged: (int index) {
              currentPage = index;
            },
          ),
        ));
  }

  loginView() {
    return Column(children: [
      avatorIcon(),
      Padding(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Container(
          decoration: ShapeDecoration(
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)))),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: SizedBox(
              child: Form(
            key: _loginKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              inputBtn(
                  _loginUserController, '用户名', '邮箱/手机号', Icons.person_outline),
              Divider(
                indent: 48,
                endIndent: 16,
                height: 1,
              ),
              inputBtn(_loginPasswordController, '密码', '', Icons.lock_outline,
                  suffix: obscureTextSwitch(_pwdInVisible),
                  obscureText: _pwdInVisible),
            ]),
          )),
        ),
      ),
      Row(children: [Expanded(child: btn('登陆', _onLogin))]),
      bottomHintText('没有账号', 1),
    ]);
  }

  registerView() {
    return Column(children: [
      avatorIcon(),
      Padding(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: Container(
          decoration: ShapeDecoration(
              color: Colors.white70,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)))),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: SizedBox(
              child: Form(
            key: _registerKey,
            autovalidate: true,
            child: Column(children: <Widget>[
              inputBtn(_registerUserController, '用户名', '邮箱/手机号',
                  Icons.person_outline),
              Divider(
                indent: 48,
                endIndent: 16,
                height: 1,
              ),
              inputBtn(
                  _registerPasswordController1, '密码', '', Icons.lock_outline,
                  suffix: obscureTextSwitch(_pwdInVisible),
                  obscureText: _pwdInVisible),
              inputBtn(
                  _registerPasswordController2, '确认密码', '', Icons.lock_outline,
                  suffix: obscureTextSwitch(_pwdInVisible),
                  obscureText: _pwdInVisible),
            ]),
          )),
        ),
      ),
      Row(children: [Expanded(child: btn('注册', _register))]),
      bottomHintText('已有账号？', 0),
    ]);
  }

  bottomHintText(String content, int targetPage) {
    return InkWell(
        onTap: () => controller.animateToPage(targetPage,
            duration: Duration(milliseconds: 500), curve: Curves.ease),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          alignment: Alignment.centerRight,
          child: Text(
            content,
            style: TextStyle(color: Colors.white),
          ),
        ));
  }

  inputBtn(TextEditingController controller, String label, String hint,
      IconData prefix,
      {Widget suffix, bool obscureText = false}) {
    return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefix),
          suffixIcon: suffix,
        ),
        obscureText: obscureText,
        validator: (v) {
          return null;
        });
  }

  Widget obscureTextSwitch(bool b) => IconButton(
        icon: Icon(b ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _pwdInVisible = !_pwdInVisible;
          });
        },
      );

  btn(String msg, Function call, {double left = 16, double right = 16}) {
    return Builder(
        builder: (BuildContext context) => Container(
              padding: EdgeInsets.only(left: left, right: right),
              child: RaisedButton(
                color: Colors.white70,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: call,
                textColor: Colors.black,
                child: Text(
                  msg,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ));
  }

  void _register() async {
    if (!(_registerKey.currentState as FormState).validate()) return;

    UI.showProgressDialog<bool>(
      context: context,
    );
    bool success = await UserManager.register(
        _registerUserController.text, _registerPasswordController1.text);
    Navigator.pop(context);
    if (success) {
      UI.showMsgDialog(context, '', '注册成功');
    } else {
      UI.showMsgDialog(context, '', '注册失败');
    }
  }

  /// 登陆
  void _onLogin() async {
    if (!(_loginKey.currentState as FormState).validate()) return;
    UI.showProgressDialog<bool>(
      context: context,
    );
    bool success = await UserManager.login(
        _loginUserController.text, _loginPasswordController.text);
    print('_onLogin ${success}');
    if (success) {
      UI.newPage(context, HomeRoute());
      UI.showMsgDialog(context, '', '注册成功');
    } else {
      Navigator.pop(context);
      UI.showMsgDialog(context, '', '登陆失败');
    }
  }

  saveToken(String token) {
    print("token succ $token");
  }
}
