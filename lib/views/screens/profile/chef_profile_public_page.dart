import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/chef_profile/chef_profile_bloc.dart';
import '../../../blocs/chef_profile/chef_profile_state.dart';
import '../../../blocs/chef_profile/chef_profile_events.dart';
import '../../../blocs/auth/auth_cubit.dart';
import '../recipe/recipe_details_page.dart';

class ChefProfilePublicPage extends StatefulWidget {
  final String chefId;
  const ChefProfilePublicPage({Key? key, required this.chefId})
    : super(key: key);

  @override
  State<ChefProfilePublicPage> createState() => _ChefProfilePublicPageState();
}

class _ChefProfilePublicPageState extends State<ChefProfilePublicPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ChefProfileBloc>().add(LoadChefProfileEvent(widget.chefId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 20,
                  ),
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
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: BlocBuilder<ChefProfileBloc, ChefProfileState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.chef == null) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Chef not found'),
                    );
                  }
                  final chef = state.chef!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: chef.isOnFire
                                    ? Border.all(
                                        color: const Color(0xFFFF6B6B),
                                        width: 2,
                                      )
                                    : Border.all(color: Colors.transparent),
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.grey[200],
                                backgroundImage:
                                    chef.imageUrl.startsWith('http')
                                    ? NetworkImage(chef.imageUrl)
                                          as ImageProvider
                                    : AssetImage(chef.imageUrl),
                              ),
                            ),
                            if (chef.isOnFire)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              chef.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: Color(0xFF1D1617),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chef.specialties.isNotEmpty 
                              ? chef.specialties.join(' • ')
                              : "Professional Chef",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("Recipes", state.recipes.length.toString()),
                            Container(height: 24, width: 1, color: Colors.grey[300]),
                            _buildStatItem("Followers", chef.isFollowed ? "12.5k" : "12.4k"),
                            Container(height: 24, width: 1, color: Colors.grey[300]),
                            _buildStatItem("Rating", "4.9"),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.read<ChefProfileBloc>().add(ToggleChefFollowEvent(chef.id)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: chef.isFollowed ? Colors.white : const Color(0xFFFF6B6B),
                                  foregroundColor: chef.isFollowed ? Colors.black : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: chef.isFollowed
                                        ? BorderSide(color: Colors.grey.withOpacity(0.3))
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Text(
                                  chef.isFollowed ? "Following" : "Follow",
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),

            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFFFF6B6B),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFF6B6B),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
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

        body: BlocBuilder<ChefProfileBloc, ChefProfileState>(
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: state.recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = state.recipes[index];
                          return _buildPremiumRecipeCard(recipe);
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
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
            );
          },
        ),
      ),
    );
  }

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

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildPremiumRecipeCard(dynamic recipe) {
    // recipe expected to be a Recipe model with fields
    return GestureDetector(
      onTap: () {
        final cookTime = int.tryParse(recipe.time.replaceAll(RegExp(r"[^0-9]"), '')) ?? 30;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RecipeDetailsPage(
              recipeId: recipe.id,
              recipeName: recipe.title,
              recipeDescription: recipe.subtitle,
              recipeImageUrl: recipe.imageUrl,
              recipePrepTime: 15,
              recipeCookTime: cookTime,
              recipeCalories: 450,
              recipeServingsCount: 4,
              recipeIngredients: const [
                '2 cups all-purpose flour',
                '1 cup granulated sugar',
                '3 large eggs',
                '1/2 cup unsalted butter, softened',
                '1 tsp vanilla extract',
                '1/2 tsp salt',
                '2 tsp baking powder',
                '1 cup milk',
              ],
              recipeInstructions: const [
                'Preheat your oven to 350°F (175°C). Grease and flour a 9-inch baking pan.',
                'In a large bowl, cream together the butter and sugar until light and fluffy.',
                'Beat in the eggs one at a time, then stir in the vanilla extract.',
                'Combine the flour, baking powder, and salt; add to the creamed mixture alternately with milk.',
                'Pour batter into the prepared pan and bake for 30-35 minutes.',
                'Allow to cool in the pan for 10 minutes, then turn out onto a wire rack to cool completely.',
              ],
              recipeTags: recipe.tags,
              initialFavorite: recipe.isFavorite,
            ),
          ),
        );
      },
      child: Container(
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
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: AssetImage(recipe.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => context.read<ChefProfileBloc>().add(
                      ToggleChefRecipeFavoriteEvent(recipe.id),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        recipe.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: recipe.isFavorite
                            ? const Color(0xFFFF6B6B)
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.name,
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
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time_filled,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime + recipe.cookTime} min',
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
    ));
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Widget _buildRecipeImage(String url) {
    print('🖼️ Loading image: $url');
    
    // Handle asset images
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Asset image failed to load: $url');
          return _buildPlaceholder();
        },
      );
    }
    
    // Handle network images
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Network image failed to load: $url');
          return _buildPlaceholder();
        },
      );
    }
    
    // Fallback for invalid URLs
    return _buildPlaceholder();
  }
  
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

// TabBar persistent header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(
        0xFFFAFAFA,
      ), // Matches background to hide content scrolling behind
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
