import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/constants.dart'; // Keep your existing constants

class ChefProfilePublicPage extends StatefulWidget {
  final String name;
  final String imageUrl;
  final bool isOnFire;

  const ChefProfilePublicPage({
    Key? key,
    required this.name,
    required this.imageUrl,
    this.isOnFire = false,
  }) : super(key: key);

  @override
  State<ChefProfilePublicPage> createState() => _ChefProfilePublicPageState();
}

class _ChefProfilePublicPageState extends State<ChefProfilePublicPage> with SingleTickerProviderStateMixin {
  bool _isFollowing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, String>> recipes = [
      {'title': 'Signature Ramen Bowl', 'time': '45 min', 'image': 'assets/images/recipes/recipe_1.png', 'rating': '4.8'},
      {'title': 'Crispy Chicken Escalope', 'time': '30 min', 'image': 'assets/images/escalope.png', 'rating': '4.9'},
      {'title': 'Seasonal Barkoukes Soup', 'time': '55 min', 'image': 'assets/images/Barkoukes.jpg', 'rating': '5.0'},
      {'title': 'Sweet Strawberry Salad', 'time': '15 min', 'image': 'assets/images/tomato.png', 'rating': '4.7'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 1. Simple clean App Bar
            SliverAppBar(
              backgroundColor: const Color(0xFFFAFAFA),
              elevation: 0,
              pinned: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            // 2. Profile Info Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Avatar with Fire Status
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: widget.isOnFire
                                ? Border.all(color: const Color(0xFFFF6B6B), width: 2)
                                : Border.all(color: Colors.transparent),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: widget.imageUrl.startsWith('http')
                                ? NetworkImage(widget.imageUrl) as ImageProvider
                                : AssetImage(widget.imageUrl),
                          ),
                        ),
                        if (widget.isOnFire)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Name & Verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                            color: Color(0xFF1D1617),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Bio / Tagline
                    Text(
                      "Michelin Star Chef • Fusion Cuisine • Food Artist",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("Recipes", "124"),
                        Container(height: 24, width: 1, color: Colors.grey[300]),
                        _buildStatItem("Followers", "12.5k"),
                        Container(height: 24, width: 1, color: Colors.grey[300]),
                        _buildStatItem("Rating", "4.9"),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isFollowing = !_isFollowing),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowing ? Colors.white : const Color(0xFFFF6B6B),
                              foregroundColor: _isFollowing ? Colors.black : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: _isFollowing 
                                  ? BorderSide(color: Colors.grey.withOpacity(0.3)) 
                                  : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              _isFollowing ? "Following" : "Follow",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Message",
                              style: TextStyle(
                                color: Colors.black, 
                                fontWeight: FontWeight.w600, 
                                fontFamily: 'Poppins'
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 3. Sticky Tab Bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFF6B6B),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFF6B6B),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins', fontSize: 15),
                  tabs: const [
                    Tab(text: "Recipes"),
                    Tab(text: "About"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        // 4. Content Body
        body: TabBarView(
          controller: _tabController,
          children: [
            // Recipes Grid Tab
            ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75, // Taller cards
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return _buildPremiumRecipeCard(recipes[index]);
                    },
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),

            // About Tab (Simple placeholder)
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Story",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Passionate about bold flavors and elevated comfort food. I started cooking when I was 10 years old in my grandmother's kitchen in Algiers. Now, I bring those traditional flavors to modern cuisine.",
                    style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700], fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Specialties",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip("Mediterranean"),
                      _buildChip("Healthy"),
                      _buildChip("Pastry"),
                      _buildChip("Fusion"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Stats
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: Color(0xFF1D1617),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // Helper Widget for About Chips
  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[800], fontSize: 12, fontFamily: 'Poppins'),
      ),
    );
  }

  // Updated Recipe Card
  Widget _buildPremiumRecipeCard(Map<String, String> recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: AssetImage(recipe['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 16, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      recipe['rating']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_filled, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      recipe['time']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Class to make TabBar sticky
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFFFAFAFA), // Matches background to hide content scrolling behind
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}