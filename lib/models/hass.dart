import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dashboard/models/bloc/hass_bloc.dart';
import 'package:dashboard/modules/config/config.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:flutter/material.dart';

@immutable
class SubscriptionError {
  final Map<String, dynamic> response;

  const SubscriptionError(this.response);
}

class Hass {
  final WebSocket channel;
  int messageId = 1;
  final Map<int, Completer<Map<String, dynamic>>> _requests = {};
  final Map<int, StreamController<Map<String, dynamic>>> _subscriptions = {};

  late final Stream<Map<String, dynamic>> stateChangedStream;

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

    queue.rest.listen(instance._messageReceived,
        onDone: () => bloc.add(const HassConnectionClosed()),
        onError: (error) => bloc.add(HassConnectionError(error)),
        cancelOnError: true);

    instance.stateChangedStream = instance.subscribeEvents('state_changed', broadcast: true);
    bloc.add(HassConnectionOpen(instance));
  }

  void _cancelAllRequests() {
    final error = CanceledError();
    for (final completer in _requests.values) {
      completer.completeError(error);
    }
    _requests.clear();
  }

  Future<void> close() async {
    _cancelAllRequests();
    await channel.close(WebSocketStatus.goingAway);
  }

  void _handleMessage(Map<String, dynamic> message) {
    final id = message['id'];
    if (id is int) {
      final completer = _requests.remove(id);
      if (completer != null) {
        completer.complete(message);
      } else {
        _subscriptions[id]?.add(message['event']);
      }
    }
  }

  void _messageReceived(dynamic event) {
    if (event is String) {
      final parsedEvent = jsonDecode(event);
      if (parsedEvent is List) {
        for (final message in parsedEvent) {
          if (message is Map<String, dynamic>) {
            _handleMessage(message);
          }
        }
      } else if (parsedEvent is Map<String, dynamic>) {
        _handleMessage(parsedEvent);
      } else {
        print('Unknown event received!');
      }
    }

    // todo
  }

  Future<Map<String, dynamic>> request(String type, {Map<String, dynamic>? data}) async {
    final id = messageId++;
    final completer = Completer<Map<String, dynamic>>();
    _requests[id] = completer;
    channel.add(jsonEncode({
      "id": id,
      "type": type,
      ...?data,
    }));
    return completer.future;
  }

  Stream<Map<String, dynamic>> _subscribe(String type, {Map<String, dynamic>? data, bool broadcast = false}) {
    final subscriptionId = messageId;
    onCancel() async {
      _subscriptions.remove(subscriptionId);
      await request('unsubscribe_$type', data: {'subscription': subscriptionId});
    }

    final controller = broadcast
        ? StreamController<Map<String, dynamic>>.broadcast(
            onCancel: onCancel,
          )
        : StreamController<Map<String, dynamic>>(
            onCancel: onCancel,
          );
    request('subscribe_$type', data: data).then((response) {
      if (response['success'] == true) {
        _subscriptions[subscriptionId] = controller;
      } else {
        controller.addError(SubscriptionError(response));
      }
    });
    return controller.stream;
  }

  Stream<Map<String, dynamic>> subscribeEvents(String? eventType, {bool broadcast = false}) {
    return eventType != null
        ? _subscribe('events', data: {'event_type': eventType}, broadcast: broadcast)
        : _subscribe('events');
  }

  Stream<Map<String, dynamic>> subscribeTrigger(dynamic trigger, {bool broadcast = false}) {
    return _subscribe('trigger', data: {'trigger': trigger}, broadcast: broadcast);
  }

  Future<void> ping() async {
    await request("ping");
  }
}
