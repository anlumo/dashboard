// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dashboard/models/bloc/hass_bloc.dart' as _i4;
import 'package:dashboard/models/cubit/weather_cubit.dart' as _i5;
import 'package:dashboard/modules/config/config.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.singletonAsync<_i3.Config>(() => _i3.Config.create());
  gh.lazySingleton<_i4.HassBloc>(() => _i4.HassBloc());
  gh.singleton<_i5.WeatherCubit>(() => _i5.WeatherCubit());
  return getIt;
}
