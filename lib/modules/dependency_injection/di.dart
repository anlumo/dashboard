import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: false, asExtension: false)
Future<GetIt> configureDependencyInjection() async => init(getIt);
