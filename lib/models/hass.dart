import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/modules/config/config.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';

class Hass {
  final WebSocket channel;
  int messageId = 1;
  Map<int, Completer<Map<String, dynamic>>> requests = {};

  Hass._(this.channel);

  static Future<void> connect() async {
    final bloc = getIt.get<HassBloc>();
    final config = (await getIt.getAsync<Config>()).data['homeassistant'];

    print('connecting to ${config['url']}');

    bloc.add(const HassStartConnecting());
    final instance = Hass._(await WebSocket.connect(config['url']));
    print('connected to $instance');

    final queue = StreamQueue(instance.channel);

    final challengeStr = await queue.next;

    if (challengeStr is! String) {
      instance.channel.close(WebSocketStatus.protocolError);
      bloc.add(const HassConnectionClosed());
      return;
    }

    final challenge = jsonDecode(challengeStr);
    if (challenge['type'] != 'auth_required') {
      instance.channel.close(WebSocketStatus.protocolError);
      bloc.add(const HassConnectionClosed());
      return;
    }

    instance.channel.add(jsonEncode({
      "type": "auth",
      "access_token": config['token'],
    }));

    final authResponseStr = await queue.next;

    if (authResponseStr is! String) {
      instance.channel.close(WebSocketStatus.protocolError);
      bloc.add(const HassConnectionClosed());
      return;
    }

    final authResponse = jsonDecode(authResponseStr);
    if (authResponse['type'] != 'auth_ok') {
      print('WebSocket auth failed: $authResponse');
      instance.channel.close(WebSocketStatus.goingAway);
      bloc.add(const HassConnectionClosed());
      return;
    }

    bloc.add(HassConnectionOpen(instance));

    queue.rest.listen(instance._messageReceived,
        onDone: () => bloc.add(const HassConnectionClosed()),
        onError: (error) => bloc.add(HassConnectionError(error)),
        cancelOnError: true);
  }

  void _cancelAllRequests() {
    final error = CanceledError();
    for (final completer in requests.values) {
      completer.completeError(error);
    }
    requests.clear();
  }

  Future<void> close() async {
    _cancelAllRequests();
    await channel.close(WebSocketStatus.goingAway);
  }

  void _messageReceived(dynamic event) {
    if (event is String) {
      final parsedEvent = jsonDecode(event);
      print('received event: $parsedEvent');

      if (parsedEvent is Map<String, dynamic>) {
        final id = parsedEvent['id'];
        if (id is int) {
          requests.remove(id)?.complete(parsedEvent);
        }
      } else if (parsedEvent is List<Map<String, dynamic>>) {
        // todo: handle subscribed events
      } else {
        print('Unknown event received!');
      }
    }

    // todo
  }

  Future<Map<String, dynamic>> request(String type,
      {Map<String, dynamic>? data}) async {
    final id = messageId++;
    final completer = Completer<Map<String, dynamic>>();
    requests[id] = completer;
    channel.add(jsonEncode({
      "id": id,
      "type": type,
      ...?data,
    }));
    return completer.future;
  }

  Future<void> ping() async {
    await request("ping");
  }
}
