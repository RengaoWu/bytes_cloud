import 'package:bytes_cloud/utils/CommonUtil.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FaceBackPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FaceBackPageState();
  }
}

class FaceBackPageState extends State<FaceBackPage> {
  String subject = 'ByteCloud 反馈邮件';
  String email = Constants.MY_EMAIL_LOCATION;
  String content;
  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          FocusScope.of(context).requestFocus(FocusNode());  // 关闭软键盘，否则个人中心页面会存在溢出
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(),
            title: Text('反馈'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  launch(CommonUtil.launchEmail(email, subject, content));
                },
              )
            ],
          ),
          body: ListView(
            children: <Widget>[
              listTitleWrapper('收件人', Constants.MY_EMAIL_LOCATION),
              UI.divider(padding: 16),
              listTitleWrapper('主题', subject),
              UI.divider(padding: 16),
              Padding(
                child: TextField(
                  decoration: InputDecoration(border: null),
                  minLines: 50,
                  onChanged: (text) => content = text,
                  maxLines: 100,
                  autofocus: true,
                  controller: controller,
                ),
                padding: EdgeInsets.all(16),
              )
            ],
          ),
        ));
  }

  listTitleWrapper(String title, String content) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: <Widget>[boldText('${title}：'), Text('$content')],
      ),
    );
  }
}
