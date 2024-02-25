import 'dart:math';

import 'package:flutter/material.dart';
import 'package:metamask_wallet_app/metamask.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MetaMaskProvider())
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MetaMask(),
      ),
    );
  }
}

// class AddChainScreen extends StatefulWidget {
//   const AddChainScreen({Key? key}) : super(key: key);

//   @override
//   _AddChainScreenState createState() => _AddChainScreenState();
// }

// class _AddChainScreenState extends State<AddChainScreen> {
//   EarthoOne earthoOne = EarthoOne(
//     clientId: "Gh0dmSMHIPXO6J8WzQUt",
//     clientSecret:
//         "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5oPtuPQQDw8sNNg6s2on\n/nTnT/48fYPxQrNrK/PSIaVOCJU4ynNbzQL3LiTSRTVDk0miZ0+owq1ifNa/gq9a\n2cVt4AoKQUpLr05srH9aTQ/pMBfbwenqq/tfiFd2Oi4WHRpOafsMYTJk3roUddLx\nHsuPLxgyNncNq2p5/ILM7Ststc6RCXjrLSuaBN/oDWc2odWgTbAg6NoUD6G+pJZr\n6h0m0uKb8LfX+pXYIhl0ykliOBrT4gwKlevO6/VfIBj2w/IJbiH/offU/WwJF9H0\nltLRYE5qbhxBLfW0JgDwgj6fNYu1bWByzSdW+mwZsGlbL5FeiRMrDO0QFLVY1Tpr\nvwIDAQAB\n-----END PUBLIC KEY-----\n",
//     enabledProviders: ["metamask", "walletconnect"],
//   );
//   EarthoCredentials? _credentials;

//   @override
//   void initState() {
//     super.initState();
//     earthoOne.init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('MetaMask'),
//         centerTitle: true,
//         elevation: 10,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final credentials =
//                 await earthoOne.connectWithRedirect("3WqIrtGUPdhhtQ4rVWNU");
//             setState(() {
//               _credentials = credentials;
//               print(_credentials);
//             });
//           },
//           child: const Text("Login"),
//         ),
//       ),
//     );
//   }
// }

class MetaMask extends StatefulWidget {
  const MetaMask({super.key});

  @override
  State<MetaMask> createState() => _MetaMaskState();
}

class _MetaMaskState extends State<MetaMask> {
  late W3MService _w3mService;
  W3MChainInfo chainInfo = W3MChainInfo(
      chainName: "Ethereum Testnet Sepolia",
      chainId: "11155111",
      namespace: "eip155:11155111",
      tokenName: "SepoliaETH",
      rpcUrl: "https://eth-sepolia.g.alchemy.com/v2/demo");
  @override
  void initState() {
    _initializeW3MService();
    super.initState();
  }

  void _initializeW3MService() async {
    W3MChainPresets.chains.putIfAbsent('11155111', () => chainInfo);

    _w3mService = W3MService(
      projectId: '4c6e39b6c2fd47535a50f64418163076',
      metadata: const PairingMetadata(
        name: 'Akhlaq',
        description: 'Akhlaq',
        url: 'https://web3modal.com/',
        icons: ['https://web3modal.com/images/rpc-illustration.png'],
        redirect: Redirect(
          native: 'web3modalflutter://',
          universal: 'https://web3modal.com',
        ),
      ),
    );
    await _w3mService.init();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MetaMaskProvider>(context);

    // print(_w3mService.status.name);
    // String address = _w3mService.session?.address ?? "Not Connected";
    // print(_w3mService.session!.address);
    return MaterialApp(
      title: 'Web3Modal Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Web3Modal Demo'),
        ),
        backgroundColor: Web3ModalTheme.colorsOf(context).background300,
        body: Container(
          constraints: const BoxConstraints.expand(),
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            Container(
              child: GestureDetector(
                onTap: () {
                  context
                      .read<MetaMaskProvider>()
                      .connect(_w3mService, context);
                },
                child: Text("Connect"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // status = false;
                    provider.disconnect(_w3mService);
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Disconnected from wallet"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Disconnect Wallet'),
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              child: const Text('Test'),
              onPressed: () async {
                var message = await context
                    .read<MetaMaskProvider>()
                    .sendTransaction(_w3mService, 0.1);
                if (message == "Transaction sent successfully!" &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            provider.isConnected
                ? Text(
                    context.read<MetaMaskProvider>().address!,
                    style: const TextStyle(fontSize: 20),
                  )
                : const Text("Not Connected"),
            SizedBox(height: 12.0),
            provider.isConnected
                ? GestureDetector(
                    onTap: () {
                      context.read<MetaMaskProvider>().getMethods(_w3mService);
                    },
                    child: Text(
                      "Get Methods",
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : const Text("No Methods"),
          ]),
        ),
      ),
    );
  }
}
