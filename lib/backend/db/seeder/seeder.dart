import '../db.dart';

void main() async {
  // List Destinasi
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
      "latitude": "-7.3362",
      "longitude": "109.2333",
    },
    {
      "image": "assets/curug_jenggala.png",
      "title": "Curug Jenggala",
      "address":
          "Jalan Pangaran Limboro, Dusun III Kalipagu, Keterger, Kecamatan Baturaden",
      "price_ticket_only": "Rp250.000",
      "price_package": "Rp350.000",
      "description":
          "Curug Jenggala adalah air terjun eksotis di lereng Gunung Slamet.",
      "latitude": "-7.3104",
      "longitude": "109.2206",
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
      "latitude": "-7.6079",
      "longitude": "110.2038",
    },
    {
      "image": "assets/labuan_bajo.png",
      "title": "Labuan Bajo",
      "address":
          "Kecamatan Komodo, Kabupaten Manggarai Barat, Provinsi Nusa Tenggara Timur, Indonesia.",
      "price_ticket_only": "Rp1.000.000",
      "price_package": "Rp1.700.000",
      "description":
          "Labuan Bajo adalah sebuah kota kecil di ujung barat Pulau Flores. Kota ini dikenal sebagai gerbang utama menuju Taman Nasional Komodo.",
      "latitude": "-8.5000",
      "longitude": "119.8833",
    },
    {
      "image": "assets/raja_ampat.png",
      "title": "Raja Ampat",
      "address": "Barat bagian Kepala Burung (Vogelkoop) Pulau Papua.",
      "price_ticket_only": "Rp2.000.000",
      "price_package": "Rp4.000.000",
      "description":
          "Dengan keunikan alamnya, Raja Ampat telah menjadi salah satu destinasi wisata unggulan Indonesia.",
      "latitude": "-0.2346",
      "longitude": "130.5227",
    },
  ];

  // Call insert
  await dbConn.InsertDestination(destinations);

  // Close conn setelah selesai
  await dbConn.closeConn();
}
