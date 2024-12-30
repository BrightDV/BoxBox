import 'package:river_player/src/configuration/better_player_event_type.dart';

///Event that happens in player. It can be used to determine current player state
///on higher layer.
class BetterPlayerEvent {
  final BetterPlayerEventType betterPlayerEventType;
  final Map<String, dynamic>? parameters;

  BetterPlayerEvent(this.betterPlayerEventType, {this.parameters});
}
