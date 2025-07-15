import 'package:flutter/material.dart';

class SalonBookingApp extends StatefulWidget {
  const SalonBookingApp({Key? key}) : super(key: key);
  @override
  _SalonBookingAppState createState() => _SalonBookingAppState();
}

class _SalonBookingAppState extends State<SalonBookingApp> {
  String activeTab = 'Service';
  String? selectedService;

  final List<Map<String, dynamic>> services = [
    {
      'id': 1,
      'name': 'Hair Cut',
      'color': Colors.grey[800],
    },
    {
      'id': 2,
      'name': 'Head Massage',
      'color': Colors.amber[700],
    },
    {
      'id': 3,
      'name': 'Shaving',
      'color': Colors.grey[700],
    }
  ];

  void handleBookNow(String serviceName) {
    setState(() {
      selectedService = serviceName;
    });
    
    // Simulate booking process
    Future.delayed(Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed for $serviceName!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        selectedService = null;
      });
    });
  }

  Widget buildServiceCard(Map<String, dynamic> service) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink[50]!,
            Colors.purple[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink[100]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Service Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[700]!,
                    Colors.grey[900]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: service['color'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: service['name'] == 'Hair Cut' ? Colors.black : service['color'],
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 8),
            
            // Service Name
            Flexible(
              child: Text(
                service['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Book Now Button
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: selectedService == service['name'] 
                    ? null 
                    : () => handleBookNow(service['name']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey[400]!;
                      }
                      return Colors.transparent;
                    },
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: selectedService == service['name']
                          ? [Colors.grey[400]!, Colors.grey[400]!]
                          : [Colors.purple[600]!, Colors.pink[600]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      selectedService == service['name'] ? 'Booking...' : 'Book Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabButton(String tab, IconData icon) {
    bool isActive = activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeTab = tab;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isActive 
                ? [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.purple[600] : Colors.grey[600],
              ),
              SizedBox(height: 4),
              Text(
                tab,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.purple[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Back Arrow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Salon Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey[200]!,
                              Colors.grey[300]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green[700]!,
                                  Colors.green[800]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Salon Name
                      Text(
                        'Lotas Saloon',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Colombo Havelock Road',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.yellow[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.5',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '(456 review)',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Navigation Tabs
              Padding(
                padding: EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      buildTabButton('About', Icons.info),
                      buildTabButton('Service', Icons.content_cut),
                      buildTabButton('Review', Icons.chat_bubble),
                      buildTabButton('Contact', Icons.phone),
                    ],
                  ),
                ),
              ),
              
              // Services Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Service Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 9, // 3 rows of 3 services each
                      itemBuilder: (context, index) {
                        return buildServiceCard(services[index % 3]);
                      },
                    ),
                    
                    SizedBox(height: 24),
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

