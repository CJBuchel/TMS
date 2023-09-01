import 'package:flutter/material.dart';

// Style constants
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

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
const storeNtUuid = "ntUuid";
const storeNtPublicKey = "ntPublicKey";
const storeNtPrivateKey = "ntPrivateKey";
const storeNtServerKey = "ntServerKey";
const storeNtAutoConfigure = "ntAutoConf";
const storeNtAuthUser = "ntAuthUser";
