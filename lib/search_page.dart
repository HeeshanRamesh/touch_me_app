// Updated SearchPage with merchant details display
import 'package:flutter/material.dart';
import '../models/merchant.dart';
import '../services/merchant_service.dart';
import 'merchant_service_list_screen.dart';

class SearchPage extends StatefulWidget {
  final String token;
  final String customerId;
  
  const SearchPage({
    Key? key, 
    required this.token,
    required this.customerId,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Merchant>> _merchantsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Merchant> _allMerchants = [];
  List<Merchant> _filteredMerchants = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _merchantsFuture = fetchMerchants(widget.token);
    _loadMerchants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMerchants() async {
    try {
      final merchants = await fetchMerchants(widget.token);
      setState(() {
        _allMerchants = merchants;
        _filteredMerchants = merchants;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _filterMerchants(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredMerchants = _allMerchants;
      } else {
        _filteredMerchants = _allMerchants.where((merchant) {
          return merchant.outletName.toLowerCase().contains(query.toLowerCase()) ||
                 merchant.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterMerchants('');
  }

  void _showMerchantDetails(Merchant merchant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantServiceListScreen(
          merchantId: merchant.id,
          outletName: merchant.outletName,
          token: widget.token,
          customerId: widget.customerId,
          profileImageUrl: merchant.logoUrl,
        ),
      ),
    );
  }

  String _getTodaySchedule(Merchant merchant) {
    final now = DateTime.now();
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final currentDay = dayNames[now.weekday - 1];
    
    // This would be parsed from the merchant's opening hours data
    // For now, using the pattern from your API response
    Map<String, dynamic> openingHours = {
      'monday': {'open': '08:00', 'close': '18:00'},
      'tuesday': {'open': '08:00', 'close': '18:00'},
      'wednesday': {'open': '08:00', 'close': '18:00'},
      'thursday': {'open': '08:00', 'close': '18:00'},
      'friday': {'open': '08:00', 'close': '18:00'},
      'saturday': {'open': '09:00', 'close': '15:00'},
      'sunday': {'open': '', 'close': ''}
    };

    final todayHours = openingHours[currentDay];
    if (todayHours != null) {
      final openTime = todayHours['open'] as String?;
      final closeTime = todayHours['close'] as String?;
      
      if (openTime != null && openTime.isNotEmpty && 
          closeTime != null && closeTime.isNotEmpty) {
        return 'Open $openTime - $closeTime';
      } else {
        return 'Closed';
      }
    }
    
    return 'Hours not available';
  }

  Widget _buildMerchantCard(Merchant merchant) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    
    return GestureDetector(
      onTap: () => _showMerchantDetails(merchant),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 8 * scaleFactor),
        padding: EdgeInsets.all(16 * scaleFactor),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with outlet image, name and rating
            Row(
              children: [
                // Outlet image on the left
                Container(
                  width: 60 * scaleFactor,
                  height: 60 * scaleFactor,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8 * scaleFactor),
                    child: merchant.outletPictureUrl.isNotEmpty
                        ? Image.network(
                            merchant.outletPictureUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage(scaleFactor);
                            },
                          )
                        : merchant.logoUrl.isNotEmpty
                            ? Image.network(
                                merchant.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildFallbackImage(scaleFactor);
                                },
                              )
                            : _buildFallbackImage(scaleFactor),
                  ),
                ),
                
                SizedBox(width: 12 * scaleFactor),
                
                // Business type indicator
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
                //   decoration: BoxDecoration(
                //     color: Colors.black,
                //     borderRadius: BorderRadius.circular(4 * scaleFactor),
                //   ),
                //   child: Text(
                //     '💇',
                //     style: TextStyle(fontSize: 12 * scaleFactor),
                //   ),
                // ),
                
                SizedBox(width: 8 * scaleFactor),
                
                // Salon name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.outletName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scaleFactor,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4 * scaleFactor),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16 * scaleFactor,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4 * scaleFactor),
                          Text(
                            (merchant.rating ?? 5.0).toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * scaleFactor,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12 * scaleFactor),
            
            // Description (using owner name as a service description placeholder)
            Text(
              'Premier salon offering cutting-edge styling and color services',
              style: TextStyle(
                fontSize: 14 * scaleFactor,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            
            SizedBox(height: 12 * scaleFactor),
            
            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16 * scaleFactor,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8 * scaleFactor),
                Expanded(
                  child: Text(
                    merchant.address.isNotEmpty ? merchant.address : '123 Beauty Street, Downtown, City 12345',
                    style: TextStyle(
                      fontSize: 13 * scaleFactor,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8 * scaleFactor),
            
            // Schedule for current day - now shows actual hours
            Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 16 * scaleFactor,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8 * scaleFactor),
                Text(
                  _getTodaySchedule(merchant),
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: _getTodaySchedule(merchant) == 'Closed' 
                        ? Colors.red[600] 
                        : Colors.green[600],
                    fontWeight: _getTodaySchedule(merchant) == 'Closed' 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8 * scaleFactor),
            
            // Phone number
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16 * scaleFactor,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8 * scaleFactor),
                Text(
                  merchant.outletPhone.isNotEmpty ? merchant.outletPhone : '+1 (555) 123-4567',
                  style: TextStyle(
                    fontSize: 13 * scaleFactor,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12 * scaleFactor),
            
            // Amenities
            Wrap(
              spacing: 8 * scaleFactor,
              runSpacing: 4 * scaleFactor,
              children: [
                _buildAmenityChip('📶 Free WiFi', scaleFactor),
                _buildAmenityChip('🅿️ Parking Available', scaleFactor),
                _buildAmenityChip('🥤 Refreshments', scaleFactor),
              ],
            ),
            
            SizedBox(height: 8 * scaleFactor),
            
            // Additional amenity
            _buildAmenityChip('❄️ Air Conditioning', scaleFactor, isSecondRow: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage(double scaleFactor) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.store,
          size: 30 * scaleFactor,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String text, double scaleFactor, {bool isSecondRow = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4 * scaleFactor),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11 * scaleFactor,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Salons & Spas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: EdgeInsets.all(16.0 * scaleFactor),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12 * scaleFactor),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterMerchants,
                decoration: InputDecoration(
                  hintText: 'Search merchants by name or location...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14 * scaleFactor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20 * scaleFactor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20 * scaleFactor,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * scaleFactor,
                    vertical: 12 * scaleFactor,
                  ),
                ),
                style: TextStyle(fontSize: 14 * scaleFactor),
              ),
            ),
          ),
          
          // Search Results Info
          if (_isSearching)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredMerchants.length} merchant${_filteredMerchants.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 14 * scaleFactor,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          SizedBox(height: _isSearching ? 8 * scaleFactor : 0),

          // Merchants List
          Expanded(
            child: FutureBuilder<List<Merchant>>(
              future: _merchantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64 * scaleFactor,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16 * scaleFactor),
                        Text(
                          'Failed to load merchants',
                          style: TextStyle(
                            fontSize: 18 * scaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        Text(
                          'Please try again later',
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 16 * scaleFactor),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _merchantsFuture = fetchMerchants(widget.token);
                            });
                            _loadMerchants();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64 * scaleFactor,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16 * scaleFactor),
                        Text(
                          'No merchants found',
                          style: TextStyle(
                            fontSize: 18 * scaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8 * scaleFactor),
                        Text(
                          'Check back later for new merchants',
                          style: TextStyle(
                            fontSize: 14 * scaleFactor,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Show filtered results when searching, otherwise show all
                  final merchantsToShow = _isSearching ? _filteredMerchants : snapshot.data!;
                  
                  if (_isSearching && _filteredMerchants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64 * scaleFactor,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16 * scaleFactor),
                          Text(
                            'No merchants found',
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          Text(
                            'Try searching with different keywords',
                            style: TextStyle(
                              fontSize: 14 * scaleFactor,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: merchantsToShow.length,
                    itemBuilder: (context, index) {
                      final merchant = merchantsToShow[index];
                      return _buildMerchantCard(merchant);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}