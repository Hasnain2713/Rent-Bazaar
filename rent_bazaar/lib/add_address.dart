import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class AddAddress extends StatefulWidget {
  const AddAddress({super.key});

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  Completer<GoogleMapController> _controller = Completer();

  DraggableScrollableController scrollController =
      DraggableScrollableController();

  TextEditingController deliveryAddressController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController landmarkController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController labelController = TextEditingController();

  FocusNode labelFocus = FocusNode();

  String formattedPickup = "Fetching Location...";

  bool isLoadingLoc = false;

  CameraPosition position = CameraPosition(
    target: LatLng(24.874312, 67.039633),
    zoom: 14,
  );

  static const String googleSearchAPI =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?sessionroken=123456&components=country:in&key=$googleAPIKey&input=";

  static const String googleGeometryAPI =
      "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&address=";

  static const String googleReverseGeometryAPI =
      "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&latlng=";

  static const String googleAPIKey = "AIzaSyC749tC3NcTS04lWfcy-lIYfNCRUup_oAM";

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.874312, 67.039633),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<LatLng> convertAddressToCoords(String address) async {
    var responsePick = await http.get(
      Uri.parse(
        googleGeometryAPI + address,
      ),
    );
    var jsonResponsePick = json.decode(responsePick.body);
    print(jsonResponsePick);
    String _lat = jsonResponsePick['results'][0]['geometry']['location']['lat']
        .toString();
    String _lng = jsonResponsePick['results'][0]['geometry']['location']['lng']
        .toString();
    return LatLng(
      double.parse(
        _lat,
      ),
      double.parse(
        _lng,
      ),
    );
  }

  Future<String> convertCoordsToAddress(String latLng) async {
    print(
      googleReverseGeometryAPI + latLng,
    );
    var responseAddress = await http.get(
      Uri.parse(
        googleReverseGeometryAPI + latLng,
      ),
    );
    var jsonResponseAddress = json.decode(responseAddress.body);
    print(jsonResponseAddress['results'][0]['formatted_address']);
    String currentLocation =
        jsonResponseAddress['results'][0]['formatted_address'];
    return currentLocation;
  }

  getCurrentLocation() async {
    setState(() {
      isLoadingLoc = true;
    });
    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          isLoadingLoc = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      setState(() {
        isLoadingLoc = false;
      });
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          isLoadingLoc = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();
    String _formattedPickupAddress = await convertCoordsToAddress(
      _locationData.latitude.toString() +
          "," +
          _locationData.longitude.toString(),
    );

    setState(
      () {
        isLoadingLoc = false;
        formattedPickup = _formattedPickupAddress;
      },
    );

    final CameraPosition _currentLocation = CameraPosition(
      target: LatLng(_locationData.latitude!, _locationData.longitude!),
      zoom: 15,
    );
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _currentLocation,
      ),
    );
    Future.delayed(
      Duration(
        seconds: 1,
      ),
      () {
        setState(
          () {
            controller.showMarkerInfoWindow(
              MarkerId(
                "currentLocation",
              ),
            );
          },
        );
      },
    );
  }

  fetchAndShow() async {
    final returnedAddress = "";
    if (returnedAddress.toString().trim() != "") {
      LatLng searchedLoc =
          await convertAddressToCoords(returnedAddress.toString());
      setState(() async {
        formattedPickup = returnedAddress.toString();
        final GoogleMapController controller = await _controller.future;
        final CameraPosition _currentLocation = CameraPosition(
          target: searchedLoc,
          zoom: 15,
        );
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            _currentLocation,
          ),
        );
      });
    }
  }

  addMoreDetails(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (formattedPickup != "Fetching Location...") {
            ReturnerAddress returnerAddress = ReturnerAddress(
                address: formattedPickup,
                lat: position.target.latitude,
                lang: position.target.longitude);
            Navigator.pop(context, returnerAddress);
            return true;
          } else {
            Fluttertoast.showToast(msg: "Please wait for location to load");
            return false;
          }
        },
        child: new Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: formattedPickup != "Fetching Location..."
                ? Colors.red
                : Colors.grey,
            onPressed: () {
              if (formattedPickup != "Fetching Location...") {
                ReturnerAddress returnerAddress = ReturnerAddress(
                    address: formattedPickup,
                    lat: position.target.latitude,
                    lang: position.target.longitude);
                Navigator.pop(context, returnerAddress);
              }
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                formattedPickup != "Fetching Location..." ? "Continue " : "...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Positioned(
                      child: GoogleMap(
                        initialCameraPosition: _kGooglePlex,
                        onMapCreated: (GoogleMapController controller) async {
                          _controller.complete(controller);
                        },
                        onCameraMove: (_position) async {
                          setState(() {
                            formattedPickup = "Fetching Location...";
                          });
                          setState(() {
                            position = _position;
                          });
                        },
                        onCameraIdle: () async {
                          print("CAMERA HAS STOPPED MOVINGGGGG");
                          String _formattedPickupAddress =
                              await convertCoordsToAddress(
                            position.target.latitude.toString() +
                                "," +
                                position.target.longitude.toString(),
                          );
                          setState(() {
                            formattedPickup = _formattedPickupAddress;
                          });
                        },
                      ),
                    ),
                    Positioned(
                      //search input bar
                      top: 10,
                      left: 5,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var place = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: googleAPIKey,
                                mode: Mode.overlay,
                                logo: null,
                                types: [],
                                overlayBorderRadius: BorderRadius.circular(
                                  10,
                                ),
                                strictbounds: false,
                                components: [
                                  Component(Component.country, 'pk')
                                ],
                                //google_map_webservice package
                                onError: (err) {
                                  print(err);
                                },
                              );
                              if (place != null) {
                                setState(
                                  () {
                                    formattedPickup =
                                        place.description.toString();
                                  },
                                );

                                //form google_maps_webservice package
                                final plist = GoogleMapsPlaces(
                                  apiKey: googleAPIKey,
                                  apiHeaders:
                                      await GoogleApiHeaders().getHeaders(),
                                );
                                String placeid = place.placeId ?? "0";
                                final detail =
                                    await plist.getDetailsByPlaceId(placeid);
                                final geometry = detail.result.geometry!;
                                final lat = geometry.location.lat;
                                final lang = geometry.location.lng;
                                var newlatlang = LatLng(lat, lang);

                                final GoogleMapController controller =
                                    await _controller.future;
                                //move map camera to selected place with animation
                                controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: newlatlang,
                                      zoom: 17,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.82,
                                child: ListTile(
                                  title: Text(
                                    "Set delivery address...",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  leading: Icon(Icons.search),
                                  dense: true,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await getCurrentLocation();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.8),
                                      offset: Offset(-1, 3),
                                      blurRadius: 2.0,
                                      spreadRadius: -1,
                                    ),
                                  ],
                                  color: Colors.white,
                                  // color: Colors.black,
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: isLoadingLoc
                                      ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                            color: Colors.red,
                                          ),
                                        )
                                      : Icon(
                                          color: Colors.red,
                                          Icons.location_searching,
                                          size: 25,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (formattedPickup != "Fetching Location...")
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                  color: Colors.red,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    formattedPickup,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/pin.png",
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReturnerAddress {
  String address;
  double lat;
  double lang;
  ReturnerAddress(
      {required this.address, required this.lat, required this.lang});
}
