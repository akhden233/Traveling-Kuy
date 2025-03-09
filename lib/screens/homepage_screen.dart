import 'package:flutter/material.dart';
import 'dart:io';
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
  List<Map<String, String>> destinations = [
    {
      "image": "assets/baturaden.png",
      "title": "Lokawisata Baturaden",
      "address":
          "Jl.Baturade no 174, Dusun 1, Karangmangu, Kec. Baturaden, Kab. Banyumas 53151",
      "price_ticket_only": "Rp500.000",
      "price_package": "Rp700.000",
      "description":
          "Lokawisata Baturaden offers beautiful natural views and hot springs.",
    },
    {
      "image": "assets/curug_jenggala.png",
      "title": "Curug Jenggala",
      "address":
          "Jalan Pangaran Limboro, Dusun III Kalipagu, Keterger, Kecamatan Baturaden",
      "price_ticket_only": "Rp250.000",
      "price_package": "Rp350.000",
    },
    {
      "image": "assets/borobudur.png",
      "title": "Candi Borobudur",
      "address":
          "Jl. Badrawati, Kw. Candi Borobudur, Borobudur, Kec. Borobudur, Kabupaten Magelang, Jawa Tengah",
      "price_ticket_only": "Rp800.000",
      "price_package": "Rp1.000.000",
      "description":
          "Borobudur is one of the world's greatest Buddhist monuments, a UNESCO World Heritage site.",
    },
    {
      "image": "assets/labuan_bajo.png",
      "title": "Labuan bajo",
      "address":
          "Kecamatan Komodo, Kabupaten Manggarai Barat, Provinsi Nusa Tenggara Timur, Indonesia.",
      "price_ticket_only": "Rp1.000.000",
      "price_package": "Rp1.700.000",
      "description":
          "Labuan Bajo adalah sebuah kota kecil yang terletak di ujung barat Pulau Flores, Nusa Tenggara Timur, Indonesia. Kota ini dikenal sebagai gerbang utama menuju Taman Nasional Komodo, rumah dari hewan purba Komodo. Labuan Bajo menawarkan pemandangan alam yang menakjubkan, termasuk perairan biru jernih, pulau-pulau eksotis, dan kehidupan bawah laut yang kaya. Destinasi ini populer untuk kegiatan seperti snorkeling, diving, trekking, dan menikmati sunset yang memukau. Selain itu, Labuan Bajo juga menjadi tempat peluncuran untuk menjelajahi Pulau Komodo, Pulau Padar, dan Pink Beach yang terkenal.",
    },
    {
      "image": "assets/raja_ampat.png",
      "title": "Raja Ampat",
      "address": "Barat bagian Kepala Burung (Vogelkoop) Pulau Papua.",
      "price_ticket_only": "Rp2.000.000",
      "price_package": "Rp4.000.000",
      "description":
          "Dengan keunikan alamnya, Raja Ampat telah menjadi salah satu destinasi wisata unggulan Indonesia dan sering disebut sebagai bagi para traveler.",
    },
  ];

  List<Map<String, String>> filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    filteredDestinations = List.from(destinations);
  }

  void _searchDestinations(String query) {
    List<Map<String, String>> results =
        destinations
            .where(
              (destination) => destination["title"]!.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      filteredDestinations = results;
    });
  }

  void _showDestinationDetails(Map<String, String> destination) {
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
                child: Image.asset(
                  destination["image"]!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                destination["title"]!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                destination["address"]!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Text(
                destination["description"] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                destination["price"] ?? "",
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
    return PopScope(
      canPop: false, // Prevent back navigation to "Get Started" screen
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                                        : AssetImage(
                                              "assets/avatar_fullname.png",
                                            )
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredDestinations.length,
                  itemBuilder: (context, index) {
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
                              child: Image.asset(
                                filteredDestinations[index]["image"]!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredDestinations[index]["title"]!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    filteredDestinations[index]["address"]!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    filteredDestinations[index]["price_ticket_only"] ??
                                        "Harga tidak tersedia",
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
      ),
    );
  }
}

class PriceOptionCard extends StatelessWidget {
  final Map<String, String> destination;

  const PriceOptionCard({super.key, required this.destination});

  void _navigateToPaymentScreen(BuildContext context, String packageType) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Tutup modal jika masih terbuka
    }

    // Ambil harga dengan null-aware operator untuk mencegah error
    String selectedPrice =
        packageType == "Only Ticket"
            ? (destination["price_ticket_only"] ?? "Harga tidak tersedia")
            : (destination["price_package"] ?? "Harga tidak tersedia");

    // Tunggu modal benar-benar tertutup sebelum berpindah halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => PaymentScreen(
                  destination: destination,
                  packageType: packageType,
                  price: selectedPrice, // Pastikan harga ada
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
        // Tombol "ONLY TICKET"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _navigateToPaymentScreen(context, "Only Ticket"),
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
        // Tombol "PAKET"
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                () => _navigateToPaymentScreen(
                  context,
                  "Paket (Tour Guide, Ticket, Makan, Penginapan)",
                ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(47, 73, 44, 1),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "PAKET (Tour Guide, Ticket, Makan, Penginapan)",
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
