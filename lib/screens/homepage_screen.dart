import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../backend/utils/constants/constants_flutter.dart';
import '../backend/utils/formatters.dart';
import '../backend/models/destination_model.dart';
import '../screens/user_profile.dart';
import '../screens/payment_screen.dart';

class HomepageScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const HomepageScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  HomepageScreenState createState() => HomepageScreenState();
}

class HomepageScreenState extends State<HomepageScreen> {
  TextEditingController searchController = TextEditingController();
  // late GoogleMapController mapController;
  // Set<Marker> _markers = {};
  List<Destination> destinations = [];
  List<Destination> filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    fetchDestination().then((_) {
      // _updateMarkers(); // Fungsi update marker sekarang dikomentari
    });
  }

  // Future<void> _updateMarkers() async {
  //   Set<Marker> markers = {};
  //   for (var destination in filteredDestinations) {
  //     markers.add(
  //       Marker(
  //         markerId: MarkerId(destination["destination_id"].toString()),
  //         position: LatLng(destination['latitude'], destination['longitude']),
  //         infoWindow: InfoWindow(title: destination['title']),
  //       ),
  //     );
  //   }
  //   if (mounted) {
  //     setState(() {
  //       _markers = markers;
  //     });
  //   }
  // }

  Future<void> fetchDestination() async {
    final response = await http.get(Uri.parse('$destinationEndpoint/'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> data = jsonResponse['data'];

      print("✅ DATA FETCHED: $data"); // DEBUG POINT #1

      setState(() {
        destinations =
            data.map((item) => Destination.fromJson(item)).toList();
        filteredDestinations = List.from(destinations);
      });

      print("✅ DESTINATIONS PARSED: ${destinations.length} item(s)"); // DEBUG POINT #2
    } else {
      print('Gagal memuat destinasi: ${response.statusCode}');
    }
  }

  void _searchDestinations(String query) {
    List<Destination> results =
        destinations
            .where(
              (destination) => destination.name.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

    if (!mounted) return;

    setState(() {
      filteredDestinations = results;
    });
  }

  void _showDestinationDetails(Destination destination) {
    print("📂 Opening detail for: ${destination.name}"); // DEBUG POINT #7
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  base64Decode(destination.imageUrl.split(',').last),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                destination.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                destination.address,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Text(
                destination.description ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "Only Ticket: ${Formatters.currencyFormat.format(destination.price["Only-Ticket"])}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(47, 73, 44, 1),
                ),
              ),
                const SizedBox(height: 5),
                Text(
                  "Package: ${Formatters.currencyFormat.format(destination.price["Package"])}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(47, 73, 44, 1),
                ),
              ),
              const SizedBox(height: 20),
              // Pastikan kita mengirim destination ke PriceOptionCard
              PriceOptionCard(destination: destination),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🛠 BUILD CALLED - Filtered Destinations: ${filteredDestinations.length}"); // DEBUG POINT #3
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserProfileScreen(
                                    userEmail: widget.userEmail,
                                    userName: widget.userName,
                                  ),
                            ),
                          );
                        },
                        child: ValueListenableBuilder<String?>(
                          valueListenable:
                              UserProfileScreenState.profileImageNotifier,
                          builder: (context, profileImage, child) {
                            return CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  profileImage != null
                                      ? FileImage(File(profileImage))
                                      : AssetImage("assets/avatar_fullname.png")
                                          as ImageProvider,
                              backgroundColor: Colors.white,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.userEmail,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications, size: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: searchController,
                onChanged: _searchDestinations,
                decoration: InputDecoration(
                  hintText: "Search destinations...",
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.green[900],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  // GoogleMap widget dikomentari
                  // Expanded(
                  //   child: GoogleMap(
                  //     initialCameraPosition: CameraPosition(
                  //       target: LatLng(
                  //         -6.2088,
                  //         106.8456,
                  //       ), // Default location Jakarta
                  //       zoom: 10,
                  //     ),
                  //     markers: _markers,
                  //     onMapCreated: (GoogleMapController controller) {
                  //       mapController = controller;
                  //     },
                  //   ),
                  // ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredDestinations.length,
                      itemBuilder: (context, index) {
                        print("📦 RENDERING CARD: ${filteredDestinations[index].name}"); // DEBUG POINT #4
                        return GestureDetector(
                          onTap:
                              () => _showDestinationDetails(
                                filteredDestinations[index],
                              ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: Image.memory(
                                    base64Decode(filteredDestinations[index].imageUrl.split(',').last),
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredDestinations[index].name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        filteredDestinations[index].address,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        Formatters.currencyFormat.format(filteredDestinations[index].price["Only-Ticket"]),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(47, 73, 44, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceOptionCard extends StatelessWidget {
  final Destination destination;

  const PriceOptionCard({super.key, required this.destination});

  void _navigateToPaymentScreen(BuildContext context, String packageType) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    String price = destination.price[packageType] != null
        ? destination.price[packageType]!.toStringAsFixed(0)
        : "Harga tidak tersedia";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              destination: destination,
              packageType: packageType,
              price: price,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToPaymentScreen(context, "Only-Ticket"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(47, 73, 44, 1),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "ONLY TICKET",
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToPaymentScreen(context, "Package"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(47, 73, 44, 1),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "PACKAGE (Tour + Hotel + Ticket)",
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

