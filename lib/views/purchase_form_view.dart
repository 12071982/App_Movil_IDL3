import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'location_picker.dart';
import 'camera_page.dart';
import 'confirmation_screen.dart';

class PurchaseFormView extends StatefulWidget {
  const PurchaseFormView({super.key});

  @override
  _PurchaseFormViewState createState() => _PurchaseFormViewState();
}

class _PurchaseFormViewState extends State<PurchaseFormView> {
  String address = "Selecciona tu ubicación en el mapa";
  LatLng? selectedLocation;
  Uint8List? _capturedImage;
  double? latitude;
  double? longitude;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? paymentMethod;

  final LatLng defaultLocation = const LatLng(-12.0464, -77.0428);

  Future<void> selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          initialLocation: selectedLocation ?? defaultLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result['location'];
        address = result['address'];
        latitude = result['latitude'];
        longitude = result['longitude'];
      });
    }
  }

  Future<void> _openCamera() async {
    final cameras = await availableCameras();
    final image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(cameras: cameras),
      ),
    );

    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  Future<void> _submitOrder() async {
    // Verifica que los campos requeridos no estén vacíos
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        address == "Selecciona tu ubicación en el mapa" ||
        paymentMethod == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Faltan datos"),
          content: Text("Por favor, complete todos los campos antes de continuar."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse("https://shop-api-roan.vercel.app/order");
    final imageData = _capturedImage != null
        ? "data:image/jpeg;base64,${base64Encode(_capturedImage!)}"
        : "sin foto";  // Si no hay foto, envía "sin foto"

    final orderData = {
      "paymentMethod": paymentMethod,
      "userName": _nameController.text,
      "userPhone": _phoneController.text,
      "userAddress": address,
      "userLat": latitude,
      "userLng": longitude,
      "userPhoto": imageData,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(orderData),
      );

      bool isSuccess = response.statusCode == 200;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(isSuccess: isSuccess),
        ),
      );
    } catch (e) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(isSuccess: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de compra'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Datos de compra',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Método de pago',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: <String>['cash', 'credit-card', 'debit-card'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                paymentMethod = newValue;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: address),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Dirección de entrega',
                suffixIcon: IconButton(
                  icon: Image.asset(
                    'assets/images/location.png',
                    width: 64,
                    height: 64,
                  ),
                  onPressed: selectLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Latitud: ${latitude ?? 'N/A'}"),
                    Text("Longitud: ${longitude ?? 'N/A'}"),
                    Text("Dirección: $address"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto de la fachada',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: _capturedImage != null
                        ? Image.memory(_capturedImage!, height: 150, width: double.infinity, fit: BoxFit.cover)
                        : IconButton(
                            icon: Image.asset(
                              'assets/images/camera.png',
                              width: 80,
                              height: 80,
                            ),
                            onPressed: _openCamera,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Comprar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
