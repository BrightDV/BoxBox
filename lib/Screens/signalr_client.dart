// ignore_for_file: avoid_print

/*
 *  This file is part of BoxBox (https://github.com/BrightDV/BoxBox).
 * 
 * BoxBox is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BoxBox is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BoxBox.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2022-2023, BrightDV
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:signalr_flutter/signalr_api.dart';
import 'package:signalr_flutter/signalr_flutter.dart';

class SignalRClientScreen extends StatefulWidget {
  const SignalRClientScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignalRClientScreen> createState() => _SignalRClientScreenState();
}

class _SignalRClientScreenState extends State<SignalRClientScreen> {
  String signalRStatus = "disconnected";
  late SignalR signalR;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    signalR = SignalR(
      "https://livetiming.formula1.com/signalr",
      "Streaming",
      hubMethods: ["Subscribe"],
      statusChangeCallback: _onStatusChange,
      hubCallback: _onNewMessage,
      headers: {
        'User-agent': 'BestHTTP',
        'Accept-Encoding': 'gzip, identity',
        'Connection': 'keep-alive, Upgrade'
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SignalR Client"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Connection Status: $signalRStatus\n",
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: _buttonTapped,
                child: const Text("Subscribe to feed"),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cast_connected_outlined),
        onPressed: () async {
          final isConnected = await signalR.isConnected();
          if (!isConnected) {
            final connId = await signalR.connect();
            print("Connection ID: $connId");
          } else {
            signalR.stop();
          }
        },
      ),
    );
  }

  void _onStatusChange(ConnectionStatus? status) {
    if (mounted) {
      setState(() {
        signalRStatus = status?.name ?? ConnectionStatus.disconnected.name;
      });
    }
  }

  void _onNewMessage(String methodName, String message) {
    print("MethodName = $methodName, Message = $message");
  }

  void _buttonTapped() async {
    try {
      final result = await signalR.invokeMethod(
        "Subscribe",
        arguments: [
          "Heartbeat",
          "CarData.z",
          "Position.z",
          "ExtrapolatedClock",
          "TopThree",
          "RcmSeries",
          "TimingStats",
          "TimingAppData",
          "WeatherData",
          "TrackStatus",
          "DriverList",
          "RaceControlMessages",
          "SessionInfo",
          "SessionData",
          "LapCount",
          "TimingData"
        ],
      );
      print(result);
    } catch (e) {
      print(e);
    }
  }
}
