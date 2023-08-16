import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String name;

  MapScreen(
      {required this.latitude, required this.longitude, required this.name});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    LatLng position = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.name}\'s Location',
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.red),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: position, zoom: 15),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        markers: Set<Marker>.of([
          Marker(
            markerId: MarkerId('location'),
            position: position,
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openInMaps,
        child: Icon(Icons.directions),
      ),
    );
  }

  void _openInMaps() async {
    String url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
