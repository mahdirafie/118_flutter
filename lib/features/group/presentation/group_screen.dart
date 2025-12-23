// group_screen.dart
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/group/dto/group_response_dto.dart';
import 'package:basu_118/features/group/presentation/bloc/group_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _groupNameController = TextEditingController();
  int? _deletingGroupId; // Track which group is being deleted

  @override
  void initState() {
    super.initState();
    // Trigger the event when screen starts up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
    });
  }

  void _fetchGroups() {
      context.read<GroupBloc>().add(GetGroupsStarted());
  }

  void _showDeleteConfirmationDialog(GroupDTO group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حذف گروه',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 48,
                color: Colors.orange.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                'آیا از حذف گروه "${group.gname}" مطمئن هستید؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'این عمل قابل بازگشت نیست',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'انصراف',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteGroup(group.gid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'حذف',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(int groupId) {
    setState(() {
      _deletingGroupId = groupId;
    });

    context.read<GroupBloc>().add(DeleteGroupEvent(groupId: groupId));
  }

  void _showCreateGroupDialog() {
    showModalBottomSheet(
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
        return StatefulBuilder(
          builder: (context, setState) {
            return _buildCreateGroupBottomSheet();
          },
        );
      },
    );
  }

  Widget _buildCreateGroupBottomSheet() {
    return DefaultTabController(
      length: 2,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
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
                    'ایجاد گروه جدید',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: 'ایجاد دستی'),
                  Tab(text: 'ایجاد خودکار'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Manual Creation Tab
                  _buildManualCreationTab(),

                  // Auto Creation Tab
                  _buildAutoCreationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualCreationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'گروه دستی',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'یک گروه خالی ایجاد کنید و بعداً افراد را به آن اضافه کنید',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Group Name Input
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'نام گروه',
              hintText: 'مثال: تیم توسعه، مدیران، دوستان',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              // Enabled (non-focused) border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              // Focused border
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              // Error border (optional)
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              // Focused error border (optional)
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              // Disabled border (optional)
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 32),

          // Create Button
          BlocConsumer<GroupBloc, GroupState>(
            listener: (context, state) {
              if (state is CreateGroupSuccess) {
                // Clear input and close dialog
                _groupNameController.clear();
                // if (Navigator.of(context).canPop()) {
                //   Navigator.of(context).pop();
                // }

                // Show success message
                showAppSnackBar(
                  context,
                  message: state.message,
                  type: AppSnackBarType.success,
                );

                // Refresh groups list
                _fetchGroups();
              }

              if (state is CreateGroupFailure) {
                // Show error message
                showAppSnackBar(
                  context,
                  message: state.message,
                  type: AppSnackBarType.error,
                );
              }
            },
            builder: (context, state) {
              final isCreating = state is CreateGroupLoading;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isCreating
                          ? null
                          : () {
                            _createManualGroup();
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isCreating
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'ایجاد گروه',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCreationTab() {
    // Get user type from current state or auth service
    final userType = _getCurrentUserType();

    List<Map<String, dynamic>> autoOptions = [];

    // Define auto-creation options based on user type
    if (userType == 'employeeF') {
      // Faculty member templates
      autoOptions = [
        {
          'title': 'گروه همکاران دانشکده',
          'description': 'گروهی شامل تمام همکاران دانشکده شما ایجاد می‌شود',
          'icon': CupertinoIcons.person_3_fill,
          'color': Colors.blue,
          'template': 'faculty', // Exact API value
        },
        {
          'title': 'گروه همکاران دپارتمان',
          'description': 'گروهی شامل همکاران دپارتمان شما ایجاد می‌شود',
          'icon': CupertinoIcons.building_2_fill,
          'color': Colors.green,
          'template': 'department', // Exact API value
        },
      ];
    } else if (userType == 'employeeNF') {
      // Non-faculty employee template
      autoOptions = [
        {
          'title': 'گروه همکاران حوزه کاری',
          'description': 'گروهی شامل همکاران حوزه کاری شما ایجاد می‌شود',
          'icon': CupertinoIcons.group_solid,
          'color': Colors.orange,
          'template': 'workarea', // Exact API value
        },
      ];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ایجاد گروه خودکار',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'یک گزینه انتخاب کنید تا گروه به صورت خودکار ایجاد شود',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Auto Options List
          if (autoOptions.isNotEmpty)
            ...autoOptions.map((option) {
              return _buildAutoOptionCard(
                title: option['title'],
                description: option['description'],
                icon: option['icon'],
                color: option['color'],
                template: option['template'],
              );
            })
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'گزینه‌ای برای ایجاد خودکار وجود ندارد',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String template,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _createAutoGroup(title, template);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),

                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  CupertinoIcons.chevron_back,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createManualGroup() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      showAppSnackBar(
        context,
        message: 'لطفا نام گروه را وارد کنید',
        type: AppSnackBarType.error,
      );
      return;
    }

    // Create group with null template for manual creation
    context.read<GroupBloc>().add(
      CreateGroupEvent(groupName: groupName, template: null),
    );
  }

  void _createAutoGroup(String groupName, String template) {
    // Create group with template for auto creation
    context.read<GroupBloc>().add(
      CreateGroupEvent(groupName: groupName, template: template),
    );
  }

  String _getCurrentUserType() {
    // Try to get from current state first
    final state = context.read<GroupBloc>().state;
    if (state is GetGroupSuccess) {
      return state.response.userType;
    }

    // Fallback to auth service
    return AuthService().userInfo?.userType ?? 'employeeNF';
  }

  String _formatDate(DateTime date) {
    // Use simple Gregorian date format to avoid conversion issues
    // Format: YYYY/MM/DD
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year/$month/$day';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        // Handle auto creation success - close dialog and show snackbar
        if (state is CreateGroupSuccess) {
          // Close the bottom sheet if it's open
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          showAppSnackBar(
            context,
            message: state.message,
            type: AppSnackBarType.success,
          );

          // Refresh groups list
          _fetchGroups();
        }

        // Handle auto creation failure
        if (state is CreateGroupFailure) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          showAppSnackBar(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
          context.read<GroupBloc>().add(
            GetGroupsStarted(),
          );
        }

        // Handle delete states
        if (state is DeleteGroupSuccess) {
          setState(() {
            _deletingGroupId = null;
          });

          // Show success message
          showAppSnackBar(
            context,
            message: state.message,
            type: AppSnackBarType.success,
          );

          // Refresh groups list
          _fetchGroups();
        }

        if (state is DeleteGroupFailure) {
          setState(() {
            _deletingGroupId = null;
          });

          // Show error message
          showAppSnackBar(
            context,
            message: state.message,
            type: AppSnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: Colors.grey.shade700),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            'گروه‌های من',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateGroupDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(GroupState state) {
    if (state is GetGroupInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.folder, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'در حال بارگذاری...',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is GetGroupLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              'در حال دریافت گروه‌ها...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is GetGroupFailure) {
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

    if (state is GetGroupSuccess) {
      final groups = state.response.groups;

      if (groups.isEmpty) {
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
                'هنوز گروهی ایجاد نکرده‌اید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Text(
                'برای ایجاد گروه جدید روی دکمه + کلیک کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _fetchGroups();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupCard(group);
            },
          ),
        ),
      );
    }

    // Handle creation/delete loading states
    if (state is CreateGroupLoading || state is DeleteGroupLoading) {
      return Stack(
        children: [
          _buildPreviousState() ?? Container(),
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return Container(); // Fallback
  }

  Widget? _buildPreviousState() {
    final bloc = context.read<GroupBloc>();
    final state = bloc.state;

    // Return the appropriate widget based on previous state
    if (state is GetGroupSuccess ||
        state is GetGroupFailure ||
        state is GetGroupLoading) {
      return _buildBody(state);
    }

    return null;
  }

  Widget _buildGroupCard(GroupDTO group) {
    final formattedDate = _formatDate(group.createdAt);
    final isDeleting = _deletingGroupId == group.gid;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            context.push('/group-members/${group.gid}');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Group Icon Section
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getGroupColor(group.gid).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getGroupColor(group.gid).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.folder_fill,
                        size: 32,
                        color: _getGroupColor(group.gid),
                      ),
                    ),
                  ),
                ),

                // Group Info Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Group Name
                        Text(
                          group.gname,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        // Creation Date Only (ID removed as requested)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.calendar,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
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
        ),

        // Delete Button (top-right corner)
        if (!isDeleting)
          Positioned(
            top: 8,
            left: 8, // Right side in RTL
            child: GestureDetector(
              onTap: () {
                _showDeleteConfirmationDialog(group);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ),

        // Loading overlay when deleting
        if (isDeleting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getGroupColor(int gid) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[gid % colors.length];
  }
}
