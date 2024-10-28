import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tms/network/network.dart';
import 'package:tms/providers/connection_provider.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/views/connection/floating_qr_button.dart';
import 'package:tms/widgets/app_bar/app_bar.dart';

// Connection widget, provides text input and buttons to connect and disconnect to the server
class Connection extends StatelessWidget {
  final GoRouterState state;
  final TextEditingController _ipTextController = TextEditingController();
  final TextEditingController _portTextController = TextEditingController();

  Connection({required this.state}) {
    _ipTextController.text = TmsLocalStorageProvider().serverIp;
    _portTextController.text = TmsLocalStorageProvider().serverPort.toString();
  }

  Widget _connectionStatus() {
    return Selector<ConnectionProvider, bool>(
      selector: (context, connectionProvider) => connectionProvider.isConnected,
      builder: (context, isConnected, child) {
        String ip = TmsLocalStorageProvider().serverIp;
        String port = TmsLocalStorageProvider().serverPort.toString();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Status: '),
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(color: isConnected ? Colors.green : Colors.red, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ip.isNotEmpty ? '${ip}:${port}' : 'N/A',
                  style: TextStyle(
                    color: isConnected ? null : Colors.red,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _ipController() {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25, top: 25),
        child: TextField(
          controller: _ipTextController,
          decoration: const InputDecoration(
            labelText: 'Server IP Address',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _portController() {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: TextField(
          controller: _portTextController,
          decoration: const InputDecoration(
            labelText: 'Server Port',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _connectButton() {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.link),
        onPressed: () {
          TmsLocalStorageProvider().serverIp = _ipTextController.text;
          TmsLocalStorageProvider().serverPort = int.parse(_portTextController.text);
          Network().connect();
        },
        label: const Text('Connect'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsAppBar(state: state),
      floatingActionButton: FloatingQrButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                _connectionStatus(),
                _ipController(),
                _portController(),
                _connectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
