import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noti me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Noti me'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class NotifyLink {
  String url;
  int status;

  NotifyLink(String url) {
    this.url = url;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<NotifyLink> notifyUrls = [
    NotifyLink("https://www.twitch.tv/skogsloparn")
  ];
  final _formKey = GlobalKey<FormState>();
  TextEditingController linkController = TextEditingController();

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = createTimer();
  }

  Timer createTimer() {
    print('Creating timer');
    Timer.periodic(Duration(seconds: 3), (timer) async {
      print('verifying links...');
      for (var i = 0; i < this.notifyUrls.length; i++) {
        try {
          if (this.notifyUrls[i].status == 200) {
            continue;
          }
          var response = await http.get(this.notifyUrls[i].url);
          this.setState(() {
            this.notifyUrls[i].status = response.statusCode;
          });
        } catch (err) {
          print(err);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: AddNotifyLinkWidget()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return buildItem(
                    index, notifyUrls[index].url, notifyUrls[index].status);
              },
              childCount: notifyUrls.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(int index, String title, int status) {
    return Card(
        child: Column(children: <Widget>[
      ListTile(
        leading: status == 200
            ? Icon(
                Icons.check,
                color: Colors.green,
              )
            : CircularProgressIndicator(),
        title: Text(title),
      )
    ]));
  }

  Widget AddNotifyLinkWidget() {
    return Form(
        key: _formKey,
        child: Center(
            child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(children: <Widget>[
                  TextFormField(
                      controller: linkController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'invalid url';
                        }

                        print('yoyo');
                        var res = Uri.parse(value);
                        print('yolo');
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter a link',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: newLinkPressed,
                        ),
                      ))
                ]))));
  }

  newLinkPressed() {
    if (_formKey.currentState != null && _formKey.currentState.validate()) {
      //ScaffoldMessenger.of(context)
      //    .showSnackBar(SnackBar(content: Text(linkController.text)));
      this.setState(() {
        notifyUrls.add(NotifyLink(linkController.text));
      });
      linkController.text = "";
    }
  }
}
