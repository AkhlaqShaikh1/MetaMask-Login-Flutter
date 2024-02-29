import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class MetaMaskProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String? address;

  sendTransaction(W3MService service, amount) async {
    await service.launchConnectedWallet();
    try {
      var response = await service.web3App!.request(
        topic: service.session!.topic.toString(),
        chainId: 'eip155:11155111',
        request: SessionRequestParams(
          method: 'eth_sendTransaction',
          params: [
            {
              'from': service.session!.address,
              'to': '0x411a478644f00aA135E37D01109180aC49f6E3f3',
              'value': '0x' + etherToWei(amount).toRadixString(16),
            }
          ],
        ),
      );
      print(response);
      return "Transaction sent successfully!";
    } on JsonRpcError catch (e) {
      return e.toJson()['message'];
    } on Exception catch (e) {
      return e.toString();
    }
  }

  etherToWei(ether) {
    return BigInt.from((ether) * 1000000000000000000);
  }

  connect(W3MService service, context) async {
    if (service.isConnected) {
      _isConnected = true;
      address = service.session!.address;
      notifyListeners();
    } else {
      await service.openModal(context).whenComplete(() {
        if (service.isConnected) {
          _isConnected = true;
          address = service.session!.address;
          notifyListeners();
        }
      });
      // address = service.session!.address;
      notifyListeners();
    }
    // service.closeModal();
    notifyListeners();
  }

  disconnect(W3MService service) {
    _isConnected = false;
    service.disconnect();
    notifyListeners();
  }

  getMethods(W3MService service) {
    print(service.getApprovedMethods());
    // return service.getApprovedMethods();
  }

  signMessage(W3MService service) async {
    var messagePram = {
      "domain": {
        "chainId": 11155111,
        "name": "Commercio",
      },
      "message": {
        "content": "Test",
        "version": "1",
        "from": {
          "name": "Akhlaq shaikh",
          "address": service.session!.address.toString(),
        }
      }
    };
    print(messagePram);
    await service.launchConnectedWallet();
    try {
      var response = await service.web3App!.request(
        topic: service.session!.topic.toString(),
        chainId: 'eip155:11155111',
        request: SessionRequestParams(
          method: 'eth_signTypedData_v4',
          params: [service.session!.address, jsonEncode(messagePram)],
        ),
      );
      print(response);
      return response;
    } on JsonRpcError catch (e) {
      return e.toJson()['message'];
    } on Exception catch (e) {
      return e.toString();
    }
  }

  perSign(W3MService service) async {
    await service.launchConnectedWallet();
    var message = "Commercio";

    try {
      var response = await service.web3App!.request(
        topic: service.session!.topic.toString(),
        chainId: 'eip155:11155111',
        request: SessionRequestParams(
          method: 'personal_sign',
          params: [
            "Commercio",
            service.session!.address,
          ],
        ),
      );
      print(response);
      return "Signed";
    } on JsonRpcError catch (e) {
      return e.toJson()['message'];
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
