// search_screen.dart
import 'dart:async';
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:basu_118/features/search/data/dto/search_dto.dart';
import 'package:basu_118/features/search/data/dto/search_history_dto.dart';
import 'package:basu_118/features/search/presentation/bloc/search_bloc.dart';
import 'package:basu_118/features/search/presentation/bloc/search_history_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  String _lastSearchedQuery = ''; // Track last searched query

  // Track loading states locally
  final Map<int, bool> _deletingItems = {};
  bool _creatingHistory = false;
  List<HistoryDTO> _currentHistories = [];

  // Debounce duration (1 second)
  final Duration _debounceDuration = const Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Auto-focus the search field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // Load search history
      _loadSearchHistory();
    });
  }

  void _loadSearchHistory() {
    // Assuming you have userId available - replace with your actual userId
    var userId = AuthService().userInfo!.uid!; // Replace with actual user ID
    context.read<SearchHistoryBloc>().add(
      GetSearchHistoryStarted(userId: userId),
    );
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {});

    // Cancel previous timer if exists
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // Don't search if query is too short
    if (query.length < 2) {
      // If we previously had results and now query is too short, reset
      if (_lastSearchedQuery.isNotEmpty) {
        _lastSearchedQuery = '';
        context.read<SearchBloc>().add(SearchReset());
      }
      return;
    }

    // Only search if query changed
    if (query == _lastSearchedQuery) return;

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query == _lastSearchedQuery) return;

    _lastSearchedQuery = query; // Update last searched query

    // Reset state before new search - shows loading state

    // Get filters from FilterBloc
    final filterState = context.read<FilterBloc>().state;
    // Get SearchBloc
    final searchBloc = context.read<SearchBloc>();

    searchBloc.add(SearchReset());

    // Small delay to ensure state reset is processed
    await Future.delayed(const Duration(milliseconds: 50));

    int? facultyId;
    int? departmentId;
    String? workArea;

    if (filterState is FilterLoaded) {
      facultyId = filterState.faculty?.id;
      departmentId = filterState.department?.id;
      workArea = filterState.workArea.isNotEmpty ? filterState.workArea : null;
    }

    // Dispatch search event with filters
    searchBloc.add(
      SearchStarted(
        query: query,
        facultyId: facultyId,
        departmentId: departmentId,
        workArea: workArea,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _lastSearchedQuery = ''; // Reset last searched query
    setState(() {});
    _searchFocusNode.requestFocus();

    // Reset search state
    context.read<SearchBloc>().add(SearchReset());

    // Cancel any pending search
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // Reload history
    _loadSearchHistory();
  }

  void _onHistoryItemTap(String query) {
    _searchController.text = query;
    _searchFocusNode.requestFocus();
    setState(() {});
    _performSearch(query);
  }

  void _onDeleteHistory(int shId) {
    // Mark as deleting locally
    setState(() {
      _deletingItems[shId] = true;
    });

    // Dispatch delete event
    context.read<SearchHistoryBloc>().add(DeleteSearchHistory(shId: shId));
  }

  void _onCreateSearchHistory(String query) {
    // Mark as creating locally
    setState(() {
      _creatingHistory = true;
    });

    var uid = AuthService().userInfo!.uid!; // Replace with actual user ID from your auth state
    context.read<SearchHistoryBloc>().add(
      CreateSearchHistory(query: query, uid: uid),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Search bar (takes most space)
              Expanded(
                child: _SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) {
                    // Handled by listener
                  },
                  hintText: 'جستجو کنید...',
                  onClear: _clearSearch,
                ),
              ),
              SizedBox(width: 12),
              // Back button on the right side
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(CupertinoIcons.forward, color: Colors.grey.shade700),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SearchHistoryBloc, SearchHistoryState>(
            listener: (context, state) {
              if (state is GetSearchHistorySuccess) {
                // Update local cache when history loads
                setState(() {
                  _currentHistories = state.response.histories;
                  _creatingHistory = false;
                  // Clear all deleting flags when history reloads
                  _deletingItems.clear();
                });
              }

              if (state is DeleteSearchHistorySuccess) {
                // Reload history after successful delete
                _loadSearchHistory();
              }

              if (state is CreateSearchHistorySuccess) {
                // Reload history after successful create
                _loadSearchHistory();
              }

              if (state is DeleteSearchHistoryFailure ||
                  state is CreateSearchHistoryFailure) {
                // Clear loading states on failure
                setState(() {
                  _creatingHistory = false;
                  _deletingItems.clear();
                });
              }
            },
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final query = _searchController.text.trim();

    // Show initial message when no query
    if (query.isEmpty) {
      return Stack(
        children: [
          // Center message with icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  'عبارت مورد نظر خود را جستجو کنید',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Search history at the top (below search field)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildSearchHistoryPanel(),
          ),
        ],
      );
    }

    // Show search results when there's a query
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return _buildSearchResults(context, state, query);
      },
    );
  }

  Widget _buildSearchHistoryPanel() {
    return BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      builder: (context, state) {
        // Show loading only on initial load when we have no histories
        if (state is GetSearchHistoryLoading && _currentHistories.isEmpty) {
          return Container(
            margin: EdgeInsets.all(12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: Text('درحال دریافت تاریخچه...')),
          );
        }

        // Show error only if we have no histories to display
        if (state is GetSearchHistoryFailure && _currentHistories.isEmpty) {
          return Container(
            margin: EdgeInsets.all(12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            ),
          );
        }

        // Don't show anything if no histories
        if (_currentHistories.isEmpty) {
          return Container();
        }

        return Container(
          margin: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // History title with nice styling
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.clock,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'تاریخچه جستجو',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // History list
              ..._currentHistories
                  .map((history) => _buildHistoryItem(history))
                  ,
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(HistoryDTO history) {
    final isDeleting = _deletingItems[history.shid] == true;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
        leading: Icon(
          CupertinoIcons.search,
          size: 16,
          color: Colors.grey.shade500,
        ),
        title: Text(
          history.query,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            isDeleting
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(color: Colors.red,),
                )
                : _creatingHistory
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade500,
                    ),
                  ),
                )
                : IconButton(
                  icon: Icon(
                    CupertinoIcons.xmark,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  onPressed: () => _onDeleteHistory(history.shid),
                ),
        onTap: () => _onHistoryItemTap(history.query),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    SearchState state,
    String query,
  ) {
    // Show loading indicator while searching
    if (state is SearchLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال جستجو...'),
          ],
        ),
      );
    }

    // Show error state
    if (state is SearchFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _performSearch(query);
              },
              child: Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    // Show search results
    if (state is SearchSuccess) {
      final response = state.response;
      final hasResults =
          response.employees.employeeF.isNotEmpty ||
          response.employees.employeeNF.isNotEmpty ||
          response.posts.isNotEmpty ||
          response.spaces.isNotEmpty;

      if (!hasResults) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.search, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'نتیجه‌ای برای "$query" یافت نشد',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return _buildSearchResultsContent(response);
    }

    // Default state (SearchInitial) - shown after reset, before new search starts
    if (query.isNotEmpty && query.length >= 2) {
      // This state is shown very briefly when resetting before new search
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال آماده‌سازی جستجو...'),
          ],
        ),
      );
    }

    return Container(); // Empty container
  }

  Widget _buildSearchResultsContent(SearchResponseDTO response) {
    final allEmployees = [
      ...response.employees.employeeF,
      ...response.employees.employeeNF,
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employees section
          if (allEmployees.isNotEmpty) ...[
            _buildSectionHeader('کارمندان'),
            ...allEmployees.map((employee) => _buildEmployeeItem(employee)),
            const SizedBox(height: 16),
          ],

          // Posts section
          if (response.posts.isNotEmpty) ...[
            _buildSectionHeader('پست‌ها'),
            ...response.posts.map((post) => _buildPostItem(post)),
            const SizedBox(height: 16),
          ],

          // Spaces section
          if (response.spaces.isNotEmpty) ...[
            _buildSectionHeader('فضاها'),
            ...response.spaces.map((space) => _buildSpaceItem(space)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildEmployeeItem(EmployeeSearch employee) {
    return ListTile(
      leading: const Icon(CupertinoIcons.person),
      title: Text(employee.user.fullName),
      subtitle: Text(employee.user.phone),
      onTap: () {
        // Navigate to employee profile
        print('Employee tapped: ${employee.empId}');
        // Create search history
        _onCreateSearchHistory(employee.user.fullName);
      },
    );
  }

  Widget _buildPostItem(PostSearch post) {
    return ListTile(
      leading: const Icon(CupertinoIcons.doc_text),
      title: Text(post.pname),
      subtitle: Text(
        post.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        // Navigate to post details
        print('Post tapped: ${post.pname}');
        // Create search history
        _onCreateSearchHistory(post.pname);
      },
    );
  }

  Widget _buildSpaceItem(SpaceSearch space) {
    return ListTile(
      leading: const Icon(CupertinoIcons.building_2_fill),
      title: Text(space.sname),
      subtitle: Text('اتاق: ${space.room}'),
      onTap: () {
        // Navigate to space details
        print('Space tapped: ${space.sname}');
        // Create search history
        _onCreateSearchHistory(space.sname);
      },
    );
  }
}

// Private SearchBar widget (only for use in this file)
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const _SearchBar({
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.hintText = 'جست و جو کنید',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          textDirection: TextDirection.rtl,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 11,
              horizontal: 0,
            ),
            isDense: true,
            border: InputBorder.none,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                CupertinoIcons.search,
                size: 18,
                color: Colors.grey.shade600,
              ),
            ),
            suffixIcon:
                controller.text.isNotEmpty
                    ? GestureDetector(
                      onTap: onClear,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : null,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            hintTextDirection: TextDirection.rtl,
          ),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade900,
            height: 1.0,
          ),
          cursorHeight: 16,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
