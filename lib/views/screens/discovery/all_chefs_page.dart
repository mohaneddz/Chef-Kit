import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common/constants.dart';
import '../../widgets/profile/chef_card_widget.dart';
import '../../../blocs/chefs/chefs_bloc.dart';
import '../../../blocs/chefs/chefs_state.dart';
import '../../../blocs/chefs/chefs_events.dart';
import '../../../blocs/chef_profile/chef_profile_bloc.dart';
import '../profile/chef_profile_public_page.dart';

class AllChefsPage extends StatelessWidget {
  const AllChefsPage({Key? key}) : super(key: key);

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
        title: Text(
          AppLocalizations.of(context)!.allChefs,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ChefsBloc, ChefsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
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
                          '${state.superHotChefs.length}',
                          AppLocalizations.of(context)!.superHot,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          Icons.restaurant_menu,
                          '${state.allChefs.where((c) => !c.isOnFire).length}',
                          AppLocalizations.of(context)!.allChefs,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          Icons.people,
                          '${state.allChefs.length}',
                          AppLocalizations.of(context)!.total,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
                      Text(
                        AppLocalizations.of(context)!.superHotChefs,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.trendingChefsSubtitle,
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: state.superHotChefs.length,
                    itemBuilder: (context, index) {
                      final chef = state.superHotChefs[index];
                      return _buildChefCard(context, chef);
                    },
                  ),
                  const SizedBox(height: 32),
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
                      Text(
                        AppLocalizations.of(context)!.allChefs,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.paginationInfo(
                      state.currentPage,
                      state.totalPages,
                      state.displayedChefs.length,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    key: ValueKey(state.currentPage),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: state.displayedChefs.length,
                    itemBuilder: (context, index) {
                      final chef = state.displayedChefs[index];
                      return _buildChefCard(context, chef);
                    },
                  ),
                  if (state.totalPages > 1) ...[
                    const SizedBox(height: 20),
                    _buildPaginationControls(context, state),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
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

  Widget _buildChefCard(BuildContext ctx, dynamic chef) {
    return ChefCardWidget(
      name: chef.name,
      imageUrl: chef.imageUrl,
      isOnFire: chef.isOnFire,
      onTap: () {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: ctx.read<ChefProfileBloc>(),
              child: ChefProfilePublicPage(chefId: chef.id),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(BuildContext context, ChefsState state) {
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
            _buildNavButton(
              icon: Icons.chevron_left,
              onTap: state.currentPage > 1
                  ? () => context.read<ChefsBloc>().add(
                      GoToChefsPage(state.currentPage - 1),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            ..._buildPageNumbers(context, state),
            const SizedBox(width: 8),
            _buildNavButton(
              icon: Icons.chevron_right,
              onTap: state.currentPage < state.totalPages
                  ? () => context.read<ChefsBloc>().add(
                      GoToChefsPage(state.currentPage + 1),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context, ChefsState state) {
    List<Widget> pageButtons = [];
    int startPage = 1;
    int endPage = state.totalPages;
    if (state.totalPages > 5) {
      if (state.currentPage <= 3) {
        endPage = 5;
      } else if (state.currentPage >= state.totalPages - 2) {
        startPage = state.totalPages - 4;
      } else {
        startPage = state.currentPage - 2;
        endPage = state.currentPage + 2;
      }
    }
    if (startPage > 1) {
      pageButtons.add(_buildPageButton(context, 1, state));
      if (startPage > 2) pageButtons.add(_buildDots());
    }
    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(_buildPageButton(context, i, state));
    }
    if (endPage < state.totalPages) {
      if (endPage < state.totalPages - 1) pageButtons.add(_buildDots());
      pageButtons.add(_buildPageButton(context, state.totalPages, state));
    }
    return pageButtons;
  }

  Widget _buildPageButton(
    BuildContext context,
    int pageNumber,
    ChefsState state,
  ) {
    final isActive = pageNumber == state.currentPage;
    return GestureDetector(
      onTap: () => context.read<ChefsBloc>().add(GoToChefsPage(pageNumber)),
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
