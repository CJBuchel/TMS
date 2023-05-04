import 'package:flutter/material.dart';

// Style constants
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

// Variable constants
const mdnsName = '_mdns-tms-server._udp.local';
const requestPort = 2121;
const wsPort = 2122;
const watchDogTime = Duration(seconds: 5);
const connectionRetries = 5;

const rsa_bit_size = 2048; // 2048
const rsa_bit_size_web = 1024; // 1024, the web is slower, lets be a tad lenient

// Local Storage Constants
const store_http_connection_state = "ServerHttpConnectionState";
const store_ws_connection_state = "ServerWSConnectionState";
const store_sec_state = "NetworkSecurityState";
const store_nt_connection_state = "ServerNetworkConnectionState";
const store_nt_serverIP = "ntServerIP";
const store_nt_uuid = "ntUuid";
const store_nt_publicKey = "ntPublicKey";
const store_nt_privateKey = "ntPrivateKey";
const store_nt_serverKey = "ntServerKey";
const store_nt_auto_configure = "ntAutoConf";
