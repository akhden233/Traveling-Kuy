// /// Frontend Flutter code snippets for QRIS scanning, payment screenshot upload, and notifications
// /// These are suggestions for your review and integration.

// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class QrisScanScreen extends StatefulWidget {
//   final Function(String) onScanSuccess;

//   QrisScanScreen({required this.onScanSuccess});

//   @override
//   _QrisScanScreenState createState() => _QrisScanScreenState();
// }

// class _QrisScanScreenState extends State<QrisScanScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   bool scanned = false;

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       if (!scanned) {
//         scanned = true;
//         widget.onScanSuccess(scanData.code ?? '');
//         Navigator.of(context).pop();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan QRIS')),
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//       ),
//     );
//   }
// }

// class PaymentScreenshotUpload extends StatefulWidget {
//   final Function(File) onScreenshotSelected;

//   PaymentScreenshotUpload({required this.onScreenshotSelected});

//   @override
//   _PaymentScreenshotUploadState createState() => _PaymentScreenshotUploadState();
// }

// class _PaymentScreenshotUploadState extends State<PaymentScreenshotUpload> {
//   File? _imageFile;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//       widget.onScreenshotSelected(_imageFile!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _imageFile == null
//             ? Text('No screenshot selected.')
//             : Image.file(_imageFile!, height: 200),
//         ElevatedButton(
//           onPressed: _pickImage,
//           child: Text('Upload Payment Screenshot'),
//         ),
//       ],
//     );
//   }
// }

// void showPaymentStatusNotification(BuildContext context, String message, {bool success = true}) {
//   final color = success ? Colors.green : Colors.red;
//   final icon = success ? Icons.check_circle : Icons.error;

//   final snackBar = SnackBar(
//     content: Row(
//       children: [
//         Icon(icon, color: Colors.white),
//         SizedBox(width: 10),
//         Expanded(child: Text(message)),
//       ],
//     ),
//     backgroundColor: color,
//     duration: Duration(seconds: 3),
//   );

//   ScaffoldMessenger.of(context).showSnackBar(snackBar);
// }
