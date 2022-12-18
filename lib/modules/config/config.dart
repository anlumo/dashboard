import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:yaml/yaml.dart';

@singleton
class Config {
  @factoryMethod
  static Future<Config> create() async {
    final str = await rootBundle.loadString("assets/config.yaml");
    final config = loadYaml(str);

    return Config._(data: config);
  }

  Config._({required this.data});

  YamlMap data;
}
