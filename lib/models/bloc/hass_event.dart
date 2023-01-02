part of 'hass_bloc.dart';

abstract class HassEvent extends Equatable {
  const HassEvent();

  @override
  List<Object> get props => [];
}

class HassStartConnecting extends HassEvent {
  const HassStartConnecting();
}

class HassConnect extends HassEvent {
  const HassConnect();
}

class HassConnectionOpen extends HassEvent {
  final Hass hass;
  const HassConnectionOpen(this.hass);
}

class HassConnectionClosed extends HassEvent {
  const HassConnectionClosed();
}

class HassConnectionError extends HassEvent {
  final Object error;
  const HassConnectionError(this.error);
}
