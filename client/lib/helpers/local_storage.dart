import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferencesWithCache _ls;

Future<void> initializeLocalStorage() async {
  _ls = await SharedPreferencesWithCache.create(
    cacheOptions: SharedPreferencesWithCacheOptions(),
  );
}

SharedPreferencesWithCache get localStorage => _ls;
