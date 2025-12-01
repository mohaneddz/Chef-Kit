import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../blocs/home/chef_card_widget.dart';

class AllChefsPage extends StatefulWidget {
  const AllChefsPage({Key? key}) : super(key: key);

  @override
  State<AllChefsPage> createState() => _AllChefsPageState();
}

class _AllChefsPageState extends State<AllChefsPage> {
  int _currentPage = 1;
  final int _chefsPerPage = 9;
  
  // Sample chef data - you can replace this with real data later
  static final List<Map<String, dynamic>> allChefs = [
    {'name': 'G. Ramsay', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': true},
    {'name': 'A. Bocuse', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': true},
    {'name': 'R. Redzepi', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': true},
    {'name': 'Jamie Oliver', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'M. Bottura', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'A. Ducasse', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'J. Robuchon', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'T. Keller', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'M. White', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'E. Lagasse', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'B. Flay', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'D. Chang', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'A. Bourdain', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'N. Lawson', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'Y. Ottolenghi', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'H. Blumenthal', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'W. Puck', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'M. Mina', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'C. Ramsey', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'J. Child', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'I. Orkin', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
    {'name': 'D. Barber', 'imageUrl': 'assets/images/chefs/chef_1.png', 'isOnFire': false},
    {'name': 'S. Yoon', 'imageUrl': 'assets/images/chefs/chef_3.png', 'isOnFire': false},
    {'name': 'A. Boulud', 'imageUrl': 'assets/images/chefs/chef_2.png', 'isOnFire': false},
  ];

  List<Map<String, dynamic>> get superHotChefs => 
      allChefs.where((chef) => chef['isOnFire'] == true).toList();
  
  List<Map<String, dynamic>> get regularChefs => 
      allChefs.where((chef) => chef['isOnFire'] == false).toList();
  
  int get totalPages => (regularChefs.length / _chefsPerPage).ceil();
  
  List<Map<String, dynamic>> get displayedChefs {
    final startIndex = (_currentPage - 1) * _chefsPerPage;
    final endIndex = (startIndex + _chefsPerPage).clamp(0, regularChefs.length);
    return regularChefs.sublist(startIndex, endIndex);
  }
  
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Chefs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E8E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.local_fire_department,
                      '${superHotChefs.length}',
                      'Super Hot',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      Icons.restaurant_menu,
                      '${regularChefs.length}',
                      'All Chefs',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatItem(
                      Icons.people,
                      '${allChefs.length}',
                      'Total',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Super Hot Chefs Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFFAA6B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Super Hot Chefs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'The most trending chefs right now',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.75,
                ),
                itemCount: superHotChefs.length,
                itemBuilder: (context, index) {
                  final chef = superHotChefs[index];
                  return _buildAnimatedChefCard(chef, index);
                },
              ),
              const SizedBox(height: 32),

              // All Chefs Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.orange.withOpacity(0.8),
                          AppColors.orange,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'All Chefs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Page $_currentPage of $totalPages • ${displayedChefs.length} chefs',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                key: ValueKey(_currentPage), // Force rebuild on page change
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayedChefs.length,
                itemBuilder: (context, index) {
                  final chef = displayedChefs[index];
                  return _buildAnimatedChefCard(chef, index);
                },
              ),
              
              // Pagination Controls
              if (totalPages > 1) ...[
                const SizedBox(height: 20),
                _buildPaginationControls(),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChefCard(Map<String, dynamic> chef, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: ChefCardWidget(
        name: chef['name'],
        imageUrl: chef['imageUrl'],
        isOnFire: chef['isOnFire'],
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${chef['name']} profile...'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.red600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous button
            _buildNavButton(
              icon: Icons.chevron_left,
              onTap: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            ),
            const SizedBox(width: 8),
            
            // Page numbers
            ..._buildPageNumbers(),
            
            const SizedBox(width: 8),
            // Next button
            _buildNavButton(
              icon: Icons.chevron_right,
              onTap: _currentPage < totalPages ? () => _goToPage(_currentPage + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    
    // Show max 5 page buttons at a time
    int startPage = 1;
    int endPage = totalPages;
    
    if (totalPages > 5) {
      if (_currentPage <= 3) {
        endPage = 5;
      } else if (_currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
      } else {
        startPage = _currentPage - 2;
        endPage = _currentPage + 2;
      }
    }
    
    // First page if not visible
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(1));
      if (startPage > 2) {
        pageButtons.add(_buildDots());
      }
    }
    
    // Page numbers
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(i));
    }
    
    // Last page if not visible
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pageButtons.add(_buildDots());
      }
      pageButtons.add(_buildPageButton(totalPages));
    }
    
    return pageButtons;
  }

  Widget _buildPageButton(int pageNumber) {
    final isActive = pageNumber == _currentPage;
    return GestureDetector(
      onTap: () => _goToPage(pageNumber),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                )
              : null,
          color: isActive ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 36,
      height: 36,
      child: Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.red600 : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }
}
