// screens/rent_property_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/constants/appColors.dart';
import '../models/RentPropertyModel.dart';
import '../provider/RentPropertyProvider.dart';
import '../widgets/RentPropertyCard.dart';
import 'PropertyDetailScreen.dart';

class RentPropertyScreen extends StatefulWidget {
  final String searchQuery;

  const RentPropertyScreen({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  State<RentPropertyScreen> createState() => _RentPropertyScreenState();
}

class _RentPropertyScreenState extends State<RentPropertyScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All';
  String _selectedCity = 'All';
  List<PropertyModel> _filteredProperties = [];
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentPropertyProvider>().fetchProperties();
    });
  }

  @override
  void didUpdateWidget(RentPropertyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle search query changes from parent
    if (widget.searchQuery != oldWidget.searchQuery) {
      _handleSearchQueryChange();
    }
  }

  void _handleSearchQueryChange() {
    if (widget.searchQuery.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredProperties.clear();
      });
    } else {
      setState(() {
        _isSearching = true;
        _filteredProperties = context
            .read<RentPropertyProvider>()
            .searchProperties(widget.searchQuery);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<PropertyModel> _getCurrentProperties() {
    if (_isSearching && _filteredProperties.isNotEmpty) {
      return _filteredProperties;
    } else if (_isSearching) {
      // If searching but no results, return empty list
      return [];
    }

    // Apply filters if any
    final provider = context.read<RentPropertyProvider>();
    List<PropertyModel> properties = provider.properties;

    // Apply type filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Available') {
        properties = provider.getAvailableProperties();
      } else {
        properties = provider.getPropertiesByType(_selectedFilter);
      }
    }

    // Apply city filter
    if (_selectedCity != 'All') {
      properties =
          properties
              .where(
                (property) =>
                    property.location.city.toLowerCase() ==
                    _selectedCity.toLowerCase(),
              )
              .toList();
    }

    return properties;
  }

  void _applyFilters() {
    setState(() {
      _isSearching = false;
      _filteredProperties.clear();
    });
  }

  List<String> _getAvailableCities() {
    final provider = context.read<RentPropertyProvider>();
    final cities =
        provider.properties
            .map((p) => p.location.city)
            .where((city) => city.isNotEmpty)
            .toSet()
            .toList();
    cities.sort();
    return ['All', ...cities];
  }

  List<String> _getAvailableTypes() {
    final provider = context.read<RentPropertyProvider>();
    final types =
        provider.properties
            .map((p) => p.type)
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList();
    types.sort();
    return ['All', 'Available', ...types];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 8.h),
          // _buildFilters(),
          if (widget.searchQuery.isNotEmpty) _buildSearchIndicator(),
          Expanded(
            child: Consumer<RentPropertyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading properties...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.error != null) {
                  return _buildErrorWidget(provider);
                }

                if (provider.properties.isEmpty) {
                  return _buildEmptyWidget();
                }

                final currentProperties = _getCurrentProperties();
                if (currentProperties.isEmpty) {
                  return _buildNoResultsWidget();
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: _getCurrentProperties().length,
                        itemBuilder: (context, index) {
                          final property = _getCurrentProperties()[index];
                          return PropertyCardWidget(
                            property: property,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PropertyDetailScreen(
                                        propertyId: property.id,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Searching for: "${widget.searchQuery}"',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${_filteredProperties.length} found',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Filters
          Consumer<RentPropertyProvider>(
            builder: (context, provider, child) {
              if (provider.properties.isEmpty) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  // Type filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedFilter,
                      decoration: InputDecoration(
                        labelText: 'Filter by Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          _getAvailableTypes()
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  // City filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'Filter by City',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          _getAvailableCities()
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          // Clear filters button
          if (_selectedFilter != 'All' || _selectedCity != 'All')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'All';
                      _selectedCity = 'All';
                    });
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(RentPropertyProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.refreshProperties();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Properties Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no properties available at the moment.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<RentPropertyProvider>().refreshProperties();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    String message = 'No Results Found';
    String description =
        'Try adjusting your filters to find what you\'re looking for.';

    if (widget.searchQuery.isNotEmpty) {
      description =
          'No properties match your search "${widget.searchQuery}". Try a different search term.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.searchQuery.isNotEmpty
                  ? Icons.search_off
                  : Icons.filter_list_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'All';
                  _selectedCity = 'All';
                });
                _applyFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
