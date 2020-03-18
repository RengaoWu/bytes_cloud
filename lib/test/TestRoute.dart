import 'package:flutter/material.dart';

class A extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AState();
  }
}

class AState extends State<A> {
  @override
  void initState() {
    print('init A');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build A');
    return Scaffold(
        body: Center(
      child: InkWell(
        child: Text(
          'A',
          style: TextStyle(fontSize: 24),
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => B()));
        },
      ),
    ));
  }

  @override
  void deactivate() {
    super.deactivate();
    print('deactivate A');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose A');
  }
}

class B extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BState();
  }
}

class BState extends State<B> {
  @override
  void initState() {
    super.initState();
    print('init B');
  }

  @override
  Widget build(BuildContext context) {
    print('build B');
    return Scaffold(
        body: Center(
      child: Text(
        'B',
        style: TextStyle(fontSize: 24),
      ),
    ));
  }

  @override
  void deactivate() {
    super.deactivate();
    print('deactivate B');
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose B');
  }
}
