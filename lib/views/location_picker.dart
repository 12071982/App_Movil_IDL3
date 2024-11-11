import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;

  const LocationPicker({super.key, required this.initialLocation});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _controller;
  LatLng? _pickedLocation;
  String? _address;

  // Clave API para la Geocoding API
  final String apiKey = 'AIzaSyBWywz46qqKwpiFrbAhPEVbsW6_aizityQ';

  // Método para obtener la dirección a partir de coordenadas usando la API de Google Maps
  Future<String> getAddressFromLatLng(LatLng location) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'Dirección no encontrada';
      }
    } else {
      return 'Error en la geocodificación';
    }
  }

  // Cuando se hace clic en el mapa, se actualiza la ubicación
  void _onMapTap(LatLng location) async {
    setState(() {
      _pickedLocation = location;
      _address = "Obteniendo dirección...";
    });

    // Llamar a la función de geocodificación para obtener la dirección
    final address = await getAddressFromLatLng(location);
    setState(() {
      _address = address;
    });
  }

  // Confirmar la ubicación seleccionada y regresar a la vista anterior
  void _confirmLocation() {
    Navigator.pop(context, {
      'location': _pickedLocation,
      'address': _address,
      'latitude': _pickedLocation?.latitude,
      'longitude': _pickedLocation?.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona tu ubicación")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 15,
            ),
            onTap: _onMapTap,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _pickedLocation!,
                    )
                  }
                : {},
          ),
          if (_address != null)
            Positioned(
              bottom: 120,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Text(
                  _address!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: _pickedLocation == null ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Botón verde
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Seleccionar ubicación",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
