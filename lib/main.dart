import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'utils/PresetSharedPreferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PresetSharedPreferences.init();

  runApp(const ProviderScope(child: MyApp()));
}
