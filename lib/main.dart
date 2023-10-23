import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(QRCodeScannerApp(camera: firstCamera));
}

class QRCodeScannerApp extends StatelessWidget {
  final CameraDescription camera;

  QRCodeScannerApp({required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRCodeScannerScreen(camera: camera),
    );
  }
}

class QRCodeScannerScreen extends StatefulWidget {
  final CameraDescription camera;

  QRCodeScannerScreen({required this.camera});

  @override
  State<StatefulWidget> createState() => _QRCodeScannerScreenState();
}

class _QRCodeScannerScreenState extends State<QRCodeScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isCameraOpen = false;
  String scannedData = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        title: Text('QR Code Scanner App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              isCameraOpen ? 'Scanning QR Code...' : 'Press button to open camera',
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20),
          isCameraOpen
              ? Container(
            height: 300,
                width: 400,
                child: Expanded(
            child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
            ),
          ),
              )
              : Container(),
          SizedBox(height: 20),
          Text(
            'Scanned Data: $scannedData',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            isCameraOpen = !isCameraOpen;
          });
          if (isCameraOpen) {
            controller?.resumeCamera();
          } else {
            controller?.pauseCamera();
          }
        },
        label: Icon(isCameraOpen ? Icons.camera_rear_outlined : Icons.camera),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        scannedData = scanData.code!;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
