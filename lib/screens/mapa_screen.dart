import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const mapboxToken = 'INTRODUCE-TOKEN-PRIVADO-DE-MAPBOX-ACÁ';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? myPosition;
  List<LatLng> parkingLocations = [
    LatLng(-12.0464, -77.0428),
    LatLng(-12.0453, -77.0342),
    LatLng(-12.0505, -77.0293),
    LatLng(-9.987003, -76.24248),
    LatLng(-9.9437003, -76.25248),
    LatLng(-9.957003, -76.22248)
  ];
  late final MapController mapController;
  bool mapReady = false;

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: SpinKitFadingCircle(
              color: Colors.blueAccent,
              size: 50.0,
            ),
          );
        },
      );
    });

    try {
      Position position = await determinePosition();
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
        print(myPosition);
        if (mapReady) {
          mapController.move(myPosition!, 18);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Mapa'),
          backgroundColor: Colors.blueAccent,
        ),
        body: myPosition == null
            ? Container(
                color: Colors.white,
              )
            : FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: myPosition!,
                  minZoom: 14,
                  maxZoom: 20,
                  initialZoom: 18,
                  onMapReady: () {
                    setState(() {
                      mapReady = true;
                      mapController.move(myPosition!, 18);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: const {
                      'accessToken': mapboxToken,
                      'id': 'mapbox/streets-v12'
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: myPosition!,
                        rotate: true,
                        child: const Icon(
                          Icons.person_pin,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                      ...parkingLocations.map((parkingLocation) => Marker(
                            point: parkingLocation,
                            rotate: true,
                            child: const Icon(
                              Icons.local_parking,
                              color: Colors.red,
                              size: 40,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: getCurrentLocation,
          child: const Icon(Icons.gps_fixed),
        ));
  }
}
