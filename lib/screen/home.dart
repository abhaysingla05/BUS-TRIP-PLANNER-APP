import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RouteDetails> busRoutes = [];
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Transit Planner'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TextField(
                        controller: originController,
                        decoration: InputDecoration(
                          labelText: 'Origin',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0),
                IconButton(
                  onPressed: () {
                    String temp = originController.text;
                    originController.text = destinationController.text;
                    destinationController.text = temp;
                  },
                  icon: Icon(Icons.swap_horiz),
                  iconSize: 36.0,
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  busRoutes.clear();
                });
                fetchDirections();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Search',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),
            if (isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: busRoutes.length,
                  itemBuilder: (context, index) {
                    final route = busRoutes[index];
                    final duration = route.busDuration ?? '';

                    return Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                    title: Text(
                    'Route ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    if (route.busNumbers.isNotEmpty)
                    Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                    children: [
                    for (int i = 0; i < route.busNumbers.length; i++)
                    Row(
                    children: [
                    Text(
                    route.busNumbers[i],
                    style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                    Icons.directions_bus,
                    color: Colors.deepPurple,
                    ),
                    if (i < route.busNumbers.length - 1)
                    Row(
                    children: [
                    const Icon(
                    Icons.arrow_forward,
                    color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8.0),
                    ],
                    ),
                    ],
                    ),
                    if (route.busNumbers.length > 1)
                    const SizedBox(width: 8.0),
                    if (route.busNumbers.length > 1)
                    const Icon(
                    Icons.arrow_forward,
                    color: Colors.deepPurple,
                    ),
                    if (route.busNumbers.length > 1)
                    const SizedBox(width: 8.0),
                    if (route.busNumbers.length > 1)
                    const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                    ),
                    ],
                    ),
                    ),
                    if (route.intermediateStops.isNotEmpty || route.finalStop != null)
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 8.0),
                    const Text(
                    'Intermediate Stops:',
                    style: TextStyle(fontSize: 16.0),
                    ),
                    if (route.intermediateStops.isNotEmpty)
                    for (final stop in route.intermediateStops)
                    Row(
                    children: [
                    const Icon(
                    Icons.arrow_downward,
                    color: Colors.deepPurple,
                    ),
                    Text(
                    '- $stop',
                    style: const TextStyle(fontSize: 16.0),
                    ),
                    ],
                    ),
                    if (route.finalStop != null)
                    Row(
                    children: [
                    const Icon(
                    Icons.arrow_forward,
                    color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                    ),
                    ],
                    ),
                    ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                    children: [
                    const Icon(
                    Icons.location_on,
                    color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                    'Final Stop: ${route.finalStop ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 16.0),
                    ),
                    ],
                    ),
                    const SizedBox(height: 8.0),
                    ],
                    ),
                    ),
                    ],
                    ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchDirections() async {
    setState(() {
      isLoading = true;
    });

    const apiKey = 'Google_MAPS_API';
    final origin = Uri.encodeQueryComponent(originController.text);
    final destination = Uri.encodeQueryComponent(destinationController.text);

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&mode=transit&destination=$destination&alternatives=true&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);

        List<RouteDetails> extractedRoutes = [];

        for (final route in decodedData['routes']) {
          final busNumbers = <String>[];
          String? startingStop;
          String? finalStop;
          int? busDuration;
          List<String> intermediateStops = [];
          List<String> transfers = [];

          for (final leg in route['legs']) {
            for (final step in leg['steps']) {
              if (step['travel_mode'] == 'TRANSIT' &&
                  step['transit_details'] != null &&
                  step['transit_details']['line'] != null &&
                  step['transit_details']['line']['vehicle'] != null &&
                  step['transit_details']['line']['vehicle']['type'] == 'BUS' &&
                  step['transit_details']['line']['short_name'] != null) {
                final busNumber = step['transit_details']['line']['short_name'];
                busNumbers.add(busNumber);

                final currentStop = step['transit_details']['departure_stop']['name'];
                if (startingStop == null) {
                  startingStop = currentStop;
                } else if (currentStop != startingStop) {
                  intermediateStops.add(currentStop);

                  final transferBusNumber = step['transit_details']['line']['short_name'];
                  transfers.add('Transfer at $currentStop (Take bus $transferBusNumber)');
                }

                final nextStop = step['transit_details']['arrival_stop']['name'];
                if (nextStop!= currentStop) {
                  final nextBusNumber = step['transit_details']['line']['short_name'];
                  transfers.add('Take bus $nextBusNumber from $currentStop');
                }

                finalStop = nextStop;
              }
            }
            busDuration = leg['duration']['value'];
            print('Bus Duration: $busDuration');
          }

          extractedRoutes.add(
            RouteDetails(
              busNumbers: List.from(busNumbers),
              startingStop: startingStop,
              finalStop: finalStop,
              busDuration: formatDuration(busDuration),
              intermediateStops: intermediateStops,
              transfers: transfers,
            ),
          );
        }

        setState(() {
          busRoutes = extractedRoutes;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDuration(int? duration) {
    if (duration == null) {
      return '';
    }

    final minutes = (duration / 60).round();
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}

class RouteDetails {
  final List<String> busNumbers;
  final String? startingStop;
  final String? finalStop;
  final String? busDuration;
  final List<String> intermediateStops;
  final List<String> transfers;

  RouteDetails({
    required this.busNumbers,
    this.startingStop,
    this.finalStop,
    this.busDuration,
    this.intermediateStops = const [],
    this.transfers = const [],
  });
}

