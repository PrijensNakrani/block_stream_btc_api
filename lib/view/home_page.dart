import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../model/btc_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamController<Btc> _streamController = StreamController();

  Future<Btc?> getData() async {
    http.Response response = await http.get(
      Uri.parse(
          "https://api.nomics.com/v1/currencies/ticker?key=af3245a3779253e83eb0b927858696d78069eacd&ids=BTC"),
    );
    final databody = json.decode(response.body).first;

    Btc btc = Btc.fromJson(databody);

    _streamController.sink.add(btc);
  }

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      getData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<Btc>(
          stream: _streamController.stream,
          builder: (context, snapdata) {
            switch (snapdata.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapdata.hasError) {
                  return Text("plaease wait");
                } else {
                  return BuildBtcCell(snapdata.data!);
                }
            }
          },
        ),
      ),
    );
  }

  Widget BuildBtcCell(Btc btc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${btc.name}"),
          const SizedBox(
            height: 30,
          ),
          SvgPicture.network(
            "${btc.logoUrl}",
            height: 200,
            width: 200,
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            "${btc.price}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
