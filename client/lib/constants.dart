import 'package:flutter/material.dart';

ValueNotifier<bool> isDarkTheme = ValueNotifier<bool>(true);

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

Color get primaryColor => isDarkTheme.value ? primaryColorDark : primaryColorLight;
Color get secondaryColor => isDarkTheme.value ? secondaryColorDark : secondaryColorLight;
Color get bgColor => isDarkTheme.value ? bgColorDark : bgColorLight;
Color get bgSecondaryColor => isDarkTheme.value ? bgSecondaryColorDark : bgSecondaryColorLight;
Color get textColor => isDarkTheme.value ? Colors.white : Colors.black;
Brightness get brightness => isDarkTheme.value ? Brightness.dark : Brightness.light;

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
