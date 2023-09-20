import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(true);

// Style constants (dark)
const primaryColorDark = Color(0xFF2697FF);
const secondaryColorDark = Color(0xFF2A2D3E);
const bgColorDark = Color(0xFF212332);
const bgSecondaryColorDark = Color(0xFF2A2D3E);

// Style constants (light)
const primaryColorLight = Color(0xFF2697FF);
const secondaryColorLight = Color(0xFF2A2D3E);
const bgColorLight = Color(0xFFFFFFFF);
const bgSecondaryColorLight = Color(0xFFEEEEEE);

class AppTheme {
  static final ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier<bool>(true);
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static bool get isDarkTheme {
    _localStorage.then((value) {
      isDarkThemeNotifier.value = value.getBool(storeDarkTheme) ?? true;
    });
    return isDarkThemeNotifier.value;
  }

  static set setDarkTheme(bool dark) {
    _localStorage.then((value) => value.setBool(storeDarkTheme, dark));
    isDarkThemeNotifier.value = dark;
  }
}

Color get primaryColor => AppTheme.isDarkThemeNotifier.value ? primaryColorDark : primaryColorLight;
Color get secondaryColor => AppTheme.isDarkThemeNotifier.value ? secondaryColorDark : secondaryColorLight;
Color get bgColor => AppTheme.isDarkThemeNotifier.value ? bgColorDark : bgColorLight;
Color get bgSecondaryColor => AppTheme.isDarkThemeNotifier.value ? bgSecondaryColorDark : bgSecondaryColorLight;
Color get textColor => AppTheme.isDarkThemeNotifier.value ? Colors.white : Colors.black;
Brightness get brightness => AppTheme.isDarkThemeNotifier.value ? Brightness.dark : Brightness.light;

class ChallengeRuleBook {
  static const String fll2019 =
      "https://www.first-lego-league.org/files/inhalt/fll_en/fll/fll_2018_19/FLL_2018_19_Robot_Game_Rules_Setup_Missions.pdf";
  static const String fll2020 = "https://firstinspiresst01.blob.core.windows.net/fll/2020/city-shaper-game-guide-pdf.pdf";
  static const String fll2021 =
      "https://firstinspiresst01.blob.core.windows.net/first-forward/fll-challenge/fll-challenge-cargo-connect-robot-game-rulebook.pdf";
  static const String fll2022 =
      "https://firstinspiresst01.blob.core.windows.net/first-energize/fll-challenge/fll-challenge-superpowered-robot-game-rulebook.pdf";
  static const String fll2023 =
      "https://firstinspiresst01.blob.core.windows.net/first-in-show-masterpiece/fll-challenge/fll-challenge-masterpiece-rgr-en.pdf";

  static String getRules(String season) {
    switch (season) {
      case "2019":
        return fll2019;
      case "2020":
        return fll2020;
      case "2021":
        return fll2021;
      case "2022":
        return fll2022;
      case "2023":
        return fll2023;

      // default
      default:
        return fll2023;
    }
  }
}

const defaultPadding = 16.0;
const defaultFontFamily = "MontserratLight";
const defaultFontFamilyBold = "MontserratBold";

// Variable constants
const mdnsName = '_mdns-tms-server._udp.local';
const requestPort = 2121; // 2121
const watchDogTime = Duration(seconds: 5);
const connectionRetries = 5;

const rsaBitSize = 2048; // 2048
const rsaBitSizeWeb = 1024; // 1024, the web is slower, lets be a tad lenient

// Local Storage Constants
const storeHttpConnectionState = "ServerHttpConnectionState";
const storeWsConnectionState = "ServerWSConnectionState";
const storeWsConnectUrl = "ServerWSConnectUrl";
const storeSecState = "NetworkSecurityState";
const storeNtConnectionState = "ServerNetworkConnectionState";
const storeNtServerIP = "ntServerIP";
const storeNtServerVersion = "ntServerVersion";
const storeNtUuid = "ntUuid";
const storeNtPublicKey = "ntPublicKey";
const storeNtPrivateKey = "ntPrivateKey";
const storeNtServerKey = "ntServerKey";
const storeNtAutoConfigure = "ntAutoConf";
const storeNtAuthUser = "ntAuthUser";
const storeDarkTheme = "isDarkTheme";
const storeRefereeTable = "refereeTable";
const storeRefereeName = "refereeName";

// Local database storage constants
const storeDbEvent = "dbEvent";
const storeDbGame = "dbGame";
const storeDbTeams = "dbTeams";
const storeDbMatches = "dbMatches";
const storeDbJudgingSessions = "dbJudgingSessions";
