// Updated SearchPage with navigation to details
import 'package:flutter/material.dart';
import '../models/merchant.dart';
import '../services/merchant_service.dart';

class SearchPage extends StatefulWidget {
  final String token;

  const SearchPage({Key? key, required this.token}) : super(key: key);

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
        builder: (context) => MerchantDetailsPage(merchant: merchant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sallons & Spas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0 * scaleFactor),
        child: Column(
          children: [
            // Search Section
            Container(
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
            SizedBox(height: 16 * scaleFactor),
            
            // Search Results Info
            if (_isSearching)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12 * scaleFactor),
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

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12 * scaleFactor,
                        mainAxisSpacing: 12 * scaleFactor,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: merchantsToShow.length,
                      itemBuilder: (context, index) {
                        final merchant = merchantsToShow[index];
                        return GestureDetector(
                          onTap: () => _showMerchantDetails(merchant),
                          child: Container(
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
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12 * scaleFactor),
                                    ),
                                    child: Image.asset(
                                      'assets/saloonservice.jpg',
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.all(12 * scaleFactor),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              merchant.outletName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14 * scaleFactor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4 * scaleFactor),
                                            Text(
                                              merchant.address,
                                              style: TextStyle(
                                                fontSize: 12 * scaleFactor,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 14 * scaleFactor,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 2 * scaleFactor),
                                            Text(
                                              merchant.rating?.toString() ?? '5.0',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12 * scaleFactor,
                                              ),
                                            ),
                                            SizedBox(width: 4 * scaleFactor),
                                            Expanded(
                                              child: Text(
                                                "| ${(merchant.reviews ?? 0).toString()} Reviews",
                                                style: TextStyle(
                                                  fontSize: 10 * scaleFactor,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Merchant Details Page
class MerchantDetailsPage extends StatelessWidget {
  final Merchant merchant;

  const MerchantDetailsPage({Key? key, required this.merchant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant.outletName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Add to favorites functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              height: 250 * scaleFactor,
              width: double.infinity,
              child: Image.asset(
                'assets/saloonservice.jpg',
                fit: BoxFit.cover,
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16 * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          merchant.outletName,
                          style: TextStyle(
                            fontSize: 24 * scaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scaleFactor,
                          vertical: 6 * scaleFactor,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20 * scaleFactor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16 * scaleFactor,
                            ),
                            SizedBox(width: 4 * scaleFactor),
                            Text(
                              merchant.rating?.toString() ?? '5.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14 * scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8 * scaleFactor),
                  
                  // Reviews count
                  Text(
                    '${merchant.reviews ?? 0} Reviews',
                    style: TextStyle(
                      fontSize: 16 * scaleFactor,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  SizedBox(height: 16 * scaleFactor),
                  
                  // Address Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16 * scaleFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20 * scaleFactor,
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Text(
                                'Address',
                                style: TextStyle(
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          Text(
                            merchant.address,
                            style: TextStyle(
                              fontSize: 14 * scaleFactor,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12 * scaleFactor),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Open maps functionality
                                  },
                                  icon: Icon(
                                    Icons.directions,
                                    size: 18 * scaleFactor,
                                  ),
                                  label: Text(
                                    'Get Directions',
                                    style: TextStyle(fontSize: 14 * scaleFactor),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12 * scaleFactor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Call functionality
                                  },
                                  icon: Icon(
                                    Icons.phone,
                                    size: 18 * scaleFactor,
                                  ),
                                  label: Text(
                                    'Call Now',
                                    style: TextStyle(fontSize: 14 * scaleFactor),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12 * scaleFactor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16 * scaleFactor),
                  
                  // Services Section (if available)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16 * scaleFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_center,
                                color: Colors.orange,
                                size: 20 * scaleFactor,
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Text(
                                'Services',
                                style: TextStyle(
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12 * scaleFactor),
                          // Add services list here based on your Merchant model
                          Text(
                            'Hair Cut, Hair Styling, Beard Trim, Facial, Massage',
                            style: TextStyle(
                              fontSize: 14 * scaleFactor,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24 * scaleFactor),
                  
                  // Book Appointment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to booking page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                        ),
                      ),
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16 * scaleFactor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}