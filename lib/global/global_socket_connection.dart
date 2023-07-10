import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GlobalSocketConnection {
  IO.Socket connectSocket() {
    /*   IO.Socket _socket = IO.io(
        'https://mamaproject.developerconsole.xyz:3000',
        IO.OptionBuilder().setTransports(['websocket']).setQuery({
          'chatID': _userId,
        }).build());*/

    IO.Socket _socket = IO.io('https://py-zedor.developerconsole.xyz:5000',
        IO.OptionBuilder().setTransports(['websocket']).build());

    /*  IO.Socket _socket = IO.io(
      'https://py-zedor.developerconsole.xyz',
    );*/

/*    IO.Socket _socket = IO.io(
      ('https://py-zedor.developerconsole.xyz:5000'),
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false,
      },
    );*/

    _socket.connect();

    return _socket;
  }
}
