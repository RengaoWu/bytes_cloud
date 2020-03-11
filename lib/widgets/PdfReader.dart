import 'dart:async';

import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fullpdfview/flutter_fullpdfview.dart';

class PDFScreen extends StatefulWidget {
  final String path;
  PDFScreen({Key key, this.path}) : super(key: key);
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      if (orientation == Orientation.portrait) {
        final Completer<PDFViewController> _controller =
            Completer<PDFViewController>();
        return Scaffold(
          appBar: AppBar(
            title: Text(FileUtil.getFileName(widget.path)),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: <Widget>[
//              pages == 0
//                  ? Container()
//                  : LinearProgressIndicator(
//                      value: currentPage / pages,
//                    ),
              Expanded(
                  child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    child: PDFView(
                      filePath: widget.path,
                      fitEachPage: true,
                      dualPageMode: false,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: false,
                      pageFling: true,
                      defaultPage: 8,
                      pageSnap: true,
                      backgroundColor: bgcolors.BLACK,
                      onRender: (_pages) {
                        print("OK RENDERED!!!!!");
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                        print(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                        print('$page: ${error.toString()}');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                      onPageChanged: (int page, int total) {
                        currentPage = page;
                        print('page change: $page/$total');
                      },
                    ),
                  ),
                  errorMessage.isEmpty
                      ? !isReady
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                      : Center(child: Text(errorMessage))
                ],
              )),
            ],
          ),
          floatingActionButton: FutureBuilder<PDFViewController>(
            future: _controller.future,
            builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
              if (snapshot.hasData) {
                return FloatingActionButton.extended(
                  label: Text("Go to ${pages ~/ 2}"),
                  onPressed: () async {
                    await snapshot.data.setPage(pages ~/ 2);
                  },
                );
              }
              return Container();
            },
          ),
        );
      } else {
        final Completer<PDFViewController> _controller =
            Completer<PDFViewController>();
        return PDFView(
          filePath: widget.path,
          fitEachPage: true,
          dualPageMode: true,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: true,
          defaultPage: 8,
          pageSnap: false,
          backgroundColor: bgcolors.BLACK,
          onRender: (_pages) {
            setState(() {
              pages = _pages;
              isReady = true;
            });
          },
          onError: (error) {
            setState(() {
              errorMessage = error.toString();
            });
            print(error.toString());
          },
          onPageError: (page, error) {
            setState(() {
              errorMessage = '$page: ${error.toString()}';
            });
            print('$page: ${error.toString()}');
          },
          onViewCreated: (PDFViewController pdfViewController) {
            _controller.complete(pdfViewController);
          },
          onPageChanged: (int page, int total) {
            print('page change: $page/$total');
            currentPage = page;
          },
        );
      }
    });
  }
}
