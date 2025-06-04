import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'merchant_list_screen.dart';

class CustomerHomeContent extends StatelessWidget {
  final String token;

  const CustomerHomeContent({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0;

    final currentDateTime = DateTime.now();
    final formattedDateTime = DateFormat(
      'EEEE, MMMM d, yyyy, hh:mm a',
    ).format(currentDateTime);

    final List<Map<String, dynamic>> services = [
      {'name': 'Hair Salon', 'icon': Icons.cut},
      {'name': 'Barbershop', 'icon': Icons.face},
      {'name': 'Massage', 'icon': Icons.spa},
      {'name': 'Skin Care', 'icon': Icons.face_retouching_natural},
      {'name': 'Makeup', 'icon': Icons.brush},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120 * scaleFactor),
        child: AppBar(
          backgroundColor: const Color(0xFF6A1B9A),
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${currentDateTime.hour < 12 ? 'Morning' : 'Evening'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Arshan Sayed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * scaleFactor,
                ),
              ),
              Text(
                formattedDateTime,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12 * scaleFactor,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(60 * scaleFactor),
            child: Padding(
              padding: EdgeInsets.all(8.0 * scaleFactor),
              child: TextField(
                readOnly: true,
                onTap: () {},
                decoration: InputDecoration(
                  hintText: 'Search Your Service',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0 * scaleFactor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SERVICES SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Services",
                    style: TextStyle(
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View all",
                    style: TextStyle(
                      fontSize: 12 * scaleFactor,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * scaleFactor),
              SizedBox(
                height: 80 * scaleFactor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MerchantListScreen(
                                  serviceName: service['name'],
                                  token: token,
                                  customerId: '', // Set if needed
                                ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12 * scaleFactor),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16 * scaleFactor,
                          vertical: 8 * scaleFactor,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(20 * scaleFactor),
                          border: Border.all(color: Colors.purple),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              service['icon'],
                              size: 30 * scaleFactor,
                              color: Colors.purple,
                            ),
                            SizedBox(height: 4 * scaleFactor),
                            Text(
                              service['name'],
                              style: TextStyle(fontSize: 12 * scaleFactor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24 * scaleFactor),

              // 🧪 Saloons Section (TODO: Use real API data)
              Text(
                "Saloons",
                style: TextStyle(
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12 * scaleFactor),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(2, (index) {
                    return Container(
                      width: 180 * scaleFactor,
                      margin: EdgeInsets.only(right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/saloonservice.jpg',
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Salon Niro",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "12/214, Kaduwela, Piliyandala",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(
                                "5.0",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "| 226 Reviews",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: 24 * scaleFactor),

              // 🔁 Recommended & Nearest sections can follow the same structure
              Text(
                "Nearest Saloon",
                style: TextStyle(
                  fontSize: 18 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                itemCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                        'assets/saloons/lotas_saloon_image.png',
                      ),
                    ),
                    title: Text('Lotas Saloon'),
                    subtitle: Text('Colombo Havelock Road'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 133, 18, 179),
                      ),
                      child: const Text('Book Now'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
