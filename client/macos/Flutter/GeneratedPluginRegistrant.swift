//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import fast_rsa
import path_provider_foundation
import shared_preferences_foundation
import wakelock_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FastRsaPlugin.register(with: registry.registrar(forPlugin: "FastRsaPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
}