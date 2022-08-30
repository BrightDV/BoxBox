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
 * Copyright (c) 2022, BrightDV
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/msgpack_hub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRScreen extends StatefulWidget {
  const SignalRScreen({Key key}) : super(key: key);

  @override
  State<SignalRScreen> createState() => _SignalRScreenState();
}

class _SignalRScreenState extends State<SignalRScreen> {
  Future<String> connectToSignalR() async {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    final hubProtLogger = Logger("SignalR - hub");
    final transportProtLogger = Logger("SignalR - transport");
    final serverUrl =
        "web.archive.org/web/20220825170609/https://livetiming.formula1.com/signalr/";
    final defaultHeaders = MessageHeaders();
    defaultHeaders.setHeaderValue(
        "connectionData", "%5B%7B%22name%22%3A%22streaming%22%7D%5D");
    final httpOptions = new HttpConnectionOptions(
      transport: HttpTransportType.WebSockets,
      logger: transportProtLogger,
      headers: defaultHeaders,
      accessTokenFactory: () => Future.value('JWT_TOKEN'),
    );

    HubConnection hubConnection = HubConnectionBuilder()
        .withUrl(
          serverUrl,
          options: httpOptions,
        )
        .withHubProtocol(MessagePackHubProtocol())
        .withAutomaticReconnect()
        .configureLogging(hubProtLogger)
        .build();
    hubConnection.onclose(
      ({error}) {
        print(error);
      },
    );
    await hubConnection.start();
    return 'loool connection closed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('signalr client'),
      ),
      body: FutureBuilder(
        future: connectToSignalR(),
        builder: (context, snapshot) => snapshot.hasError
            ? Text(snapshot.error.toString())
            : snapshot.hasData
                ? Text(snapshot.data)
                : Text('looooooool faut attendre mdr'),
      ),
    );
  }
}
