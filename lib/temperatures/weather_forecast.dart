import 'package:dashboard/models/cubit/weather_cubit.dart';
import 'package:dashboard/modules/dependency_injection/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:weather/weather.dart';

class WeatherForecast extends StatelessWidget {
  const WeatherForecast({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, List<Weather>>(
      bloc: getIt.get<WeatherCubit>()..load(),
      builder: (context, state) {
        final theme = Theme.of(context);
        // print('weather forecast: ${state.take(8).toList(growable: false)}');
        return Row(
          children: state.take(8).map((weather) {
            final date = weather.date;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LayoutGrid(
                        areas: '''
                                time
                                icon
                                temp
                                wind
                                .
                                  ''',
                        columnSizes: [1.fr],
                        rowSizes: [auto, auto, auto, auto, 1.fr],
                        rowGap: 4,
                        children: [
                          Center(
                            child: Text(
                              '${date?.hour.toString()} Uhr',
                              style: theme.textTheme.labelLarge?.copyWith(fontSize: 24),
                            ),
                          ).inGridArea('time'),
                          Center(
                            child: Image.asset(
                              'assets/weather_icons/${weather.weatherIcon}@2x.png',
                            ),
                          ).inGridArea('icon'),
                          Center(
                            child: Text(
                              '${weather.temperature?.celsius?.toStringAsFixed(1)}°C',
                              style: theme.textTheme.displaySmall,
                            ),
                          ).inGridArea('temp'),
                          Center(
                            child: Text('Wind: ${weather.windSpeed ?? 0 * 3.6} km/h'),
                          ).inGridArea('wind'),
                        ]),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}
