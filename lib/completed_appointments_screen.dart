import 'package:flutter/material.dart';

class CompletedAppointmentsScreen extends StatelessWidget {
  const CompletedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6A1B9A),
          title: const Text('Appointments'),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 8),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Completed'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Cancelled'),
                    ],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            UpcomingAppointmentsTab(),
            CompletedAppointmentsTab(),
            CancelledAppointmentsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: 1,
          selectedItemColor: const Color(0xFF6A1B9A),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: '',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by Business Name...',
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.place, color: Colors.white),
        const SizedBox(width: 8),
        const Icon(Icons.calendar_today, color: Colors.white),
      ],
    );
  }
}

class UpcomingAppointmentsTab extends StatelessWidget {
  const UpcomingAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Upcoming Appointments will appear here'));
  }
}

class CompletedAppointmentsTab extends StatelessWidget {
  const CompletedAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> completedAppointments = [
      {
        'service': 'Haircut',
        'date': '16/09/2025',
        'customer': 'Kamal Dunsinghe',
        'oldPrice': '25,000 LKR',
        'newPrice': '15,000 LKR',
      },
      {
        'service': 'Bridal Dressing',
        'date': '16/09/2025',
        'customer': 'Ayesham K. Fab',
        'oldPrice': '125,000 LKR',
        'newPrice': '95,000 LKR',
      },
      {
        'service': 'Makeup',
        'date': '16/09/2025',
        'customer': 'Nathasha Perera',
        'oldPrice': '7,000 LKR',
        'newPrice': '5,000 LKR',
      },
      {
        'service': 'Facial',
        'date': '16/09/2025',
        'customer': 'Nethmi Kavya',
        'oldPrice': '25,000 LKR',
        'newPrice': '15,000 LKR',
      },
      {
        'service': 'Eyebrows Making',
        'date': '16/09/2025',
        'customer': 'Thulashi Sanjeewani',
        'oldPrice': '30,000 LKR',
        'newPrice': '25,000 LKR',
      },
      {
        'service': 'Haircut',
        'date': '16/09/2025',
        'customer': 'NadI Dunsinghe',
        'oldPrice': '25,000 LKR',
        'newPrice': '15,000 LKR',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        final item = completedAppointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['service'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 4),
                    Text(item['date'], style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage(
                        'assets/user.png',
                      ), // Add this asset
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['customer'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['oldPrice'],
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          item['newPrice'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6A1B9A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Review',
                        style: TextStyle(color: Color(0xFF6A1B9A)),
                      ),
                    ),
                    const SizedBox(width: 8),
                   ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6A1B9A,
                        ), // Background color
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CancelledAppointmentsTab extends StatelessWidget {
  const CancelledAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cancelled Appointments will appear here'));
  }
}
