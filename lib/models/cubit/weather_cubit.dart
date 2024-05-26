import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dashboard/modules/config/config.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:injectable/injectable.dart';
import 'package:weather/weather.dart';

@singleton
class WeatherCubit extends Cubit<List<Weather>> {
  WeatherCubit() : super(const []);

  bool _loaded = false;
  Timer? _timer;

  Future<void> load() async {
    if (!_loaded) {
      _loaded = true;
      final config = (await getIt.getAsync<Config>()).data['weather'];
      final latitude = config['latitude'];
      final longitude = config['longitude'];
      final wf = WeatherFactory(config['api_key']);
      emit(await wf.fiveDayForecastByLocation(latitude, longitude));
      _timer = Timer.periodic(const Duration(hours: 1), (timer) async {
        emit(await wf.fiveDayForecastByLocation(latitude, longitude));
      });
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
