import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoreInfoPage extends StatelessWidget{
  CloudFileEntity entity;
  MoreInfoPage(this.entity);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(entity.fileName),
      ),
    );
  }

}