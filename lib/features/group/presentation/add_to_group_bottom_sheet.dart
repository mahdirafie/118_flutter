// add_to_group_bottom_sheet.dart
import 'package:basu_118/features/group/dto/group_response_dto.dart';
import 'package:basu_118/features/group/presentation/bloc/group_bloc.dart';
import 'package:basu_118/features/group/presentation/bloc/group_member_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class AddToGroupBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required int empId, // The empId to add to group (from ContactContact)
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return _AddToGroupBottomSheetContent(empId: empId);
      },
    );
  }
}

class _AddToGroupBottomSheetContent extends StatefulWidget {
  final int empId;

  const _AddToGroupBottomSheetContent({required this.empId});

  @override
  State<_AddToGroupBottomSheetContent> createState() =>
      __AddToGroupBottomSheetContentState();
}

class __AddToGroupBottomSheetContentState
    extends State<_AddToGroupBottomSheetContent> {
  int? _selectedGroupId;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    // Fetch groups on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
    });
  }

  void _fetchGroups() {
      context.read<GroupBloc>().add(GetGroupsStarted());
  }

  void _handleAddToGroup() {
    if (_selectedGroupId == null || _isAdding) return;

    setState(() {
      _isAdding = true;
    });

    // Dispatch AddToGroupEvent
    context.read<GroupMemberBloc>().add(
      AddToGroupEvent(
        groupId: _selectedGroupId!,
        empId: widget.empId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GroupMemberBloc, GroupMemberState>(
          listener: (context, state) {
            if (state is AddToGroupSuccess) {
              // Close the bottom sheet
              Navigator.of(context).pop();
              
              // Show success message
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.success,
              );
            }
            
            if (state is AddToGroupFailure) {
              setState(() {
                _isAdding = false;
              });
              
              if(Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              // Show error message
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            }
          },
        ),
      ],
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),
            
            // Content area
            Expanded(
              child: _buildContent(),
            ),
            
            // Add Button (only show if a group is selected)
            if (_selectedGroupId != null && !_isAdding) _buildAddButton(),
            
            // Loading state
            if (_isAdding) _buildAddingLoader(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'افزودن به گروه',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
            onPressed: () {
              if (!_isAdding) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GetGroupLoading) {
          return _buildLoadingState();
        }
        
        if (state is GetGroupFailure) {
          return _buildErrorState(state.message);
        }
        
        if (state is GetGroupSuccess) {
          final groups = state.response.groups;
          
          if (groups.isEmpty) {
            return _buildEmptyState();
          }
          
          return _buildGroupsList(groups);
        }
        
        // Initial state
        return _buildLoadingState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 16),
          Text(
            'در حال دریافت گروه‌ها...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchGroups,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.folder,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'هیچ گروهی وجود ندارد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابتدا یک گروه ایجاد کنید',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<GroupDTO> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final isSelected = _selectedGroupId == group.gid;
        
        return _buildGroupItem(group, isSelected);
      },
    );
  }

  Widget _buildGroupItem(GroupDTO group, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedGroupId = isSelected ? null : group.gid;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
            ),
            child: Row(
              children: [
                // Group Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    CupertinoIcons.folder_fill,
                    size: 20,
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Group Name
                Expanded(
                  child: Text(
                    group.gname,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.grey.shade800,
                    ),
                  ),
                ),
                
                // Selection Indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        color: Colors.white,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleAddToGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'افزودن به گروه',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddingLoader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'در حال افزودن به گروه...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}