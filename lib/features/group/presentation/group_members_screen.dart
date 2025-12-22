import 'package:basu_118/features/group/dto/group_members_response_dto.dart';
import 'package:basu_118/features/group/presentation/bloc/group_member_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupMembersScreen extends StatefulWidget {
  final int gid;

  const GroupMembersScreen({super.key, required this.gid});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  // Track which member is being deleted
  int? _deletingEmpId;

  @override
  void initState() {
    super.initState();
    // Trigger the event when screen starts up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroupMembers();
    });
  }

  void _fetchGroupMembers() {
    context.read<GroupMemberBloc>().add(
      GetGroupMembersEvent(groupId: widget.gid),
    );
  }

  void _deleteMember(int empId) {
    setState(() {
      _deletingEmpId = empId;
    });

    context.read<GroupMemberBloc>().add(
      DeleteGroupMemberEvent(groupId: widget.gid, empId: empId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupMemberBloc, GroupMemberState>(
      listener: (context, state) {
        // Handle delete success
        if (state is DeleteGroupMemberSuccess) {
          setState(() {
            _deletingEmpId = null;
          });

          showAppSnackBar(
            context,
            message: state.message,
            type: AppSnackBarType.success,
          );

          // Refresh members list
          _fetchGroupMembers();
        }

        // Handle delete failure
        if (state is DeleteGroupmemberFailure) {
          setState(() {
            _deletingEmpId = null;
          });

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
          title: BlocBuilder<GroupMemberBloc, GroupMemberState>(
            builder: (context, state) {
              String title = 'اعضای گروه';

              if (state is GetGroupMembersSuccess) {
                title = state.response.group.groupName;
              }

              return Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              );
            },
          ),
        ),
        body: BlocBuilder<GroupMemberBloc, GroupMemberState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(GroupMemberState state) {
    // Handle delete loading states
    if (state is DeleteGroupMemberLoading) {
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

    if (state is GetGroupMembersLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              'در حال دریافت اعضای گروه...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is GetGroupMembersFailure) {
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
              onPressed: _fetchGroupMembers,
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

    if (state is GetGroupMembersSuccess) {
      final group = state.response.group;
      final members = group.members;

      if (members.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.person_solid,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'هنوز عضوی در این گروه وجود ندارد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Text(
                'می‌توانید افراد را به این گروه اضافه کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _fetchGroupMembers();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isDeleting = _deletingEmpId == member.empId;
            return _buildMemberCard(member, index + 1, isDeleting);
          },
        ),
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.group, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget? _buildPreviousState() {
    final bloc = context.read<GroupMemberBloc>();
    final state = bloc.state;

    // Return the appropriate widget based on previous state
    if (state is GetGroupMembersSuccess ||
        state is GetGroupMembersFailure ||
        state is GetGroupMembersLoading ||
        state is GetGroupMembersInitial) {
      return _buildBody(state);
    }

    return null;
  }

  Widget _buildMemberCard(
    MemberGroupMember member,
    int index,
    bool isDeleting,
  ) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Icon with Number
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getMemberColor(member.empId),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Member Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member Name
                      Text(
                        member.user.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Employee ID
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.number,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'کد: ${member.empId}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More Options Button (hidden when deleting)
                if (!isDeleting)
                  IconButton(
                    onPressed: () {
                      _showMemberOptions(member);
                    },
                    icon: Icon(
                      CupertinoIcons.ellipsis_vertical,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
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

  void _showMemberOptions(MemberGroupMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                'گزینه‌های عضو',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                member.user.fullName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Options
              Column(
                children: [
                  // View Profile Option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text(
                      'مشاهده اطلاعات تماس',
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: Icon(
                      CupertinoIcons.chevron_back,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/contact-detail/${member.cId}/${member.user.fullName}');
                    },
                  ),

                  // Remove from Group Option
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.person_badge_minus_fill,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'حذف از گروه',
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                    trailing: Icon(
                      CupertinoIcons.chevron_back,
                      size: 18,
                      color: Colors.grey.shade400,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _showRemoveConfirmationDialog(member);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'انصراف',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveConfirmationDialog(MemberGroupMember member) {
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
            'حذف عضو',
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
                'آیا از حذف "${member.user.fullName}" از گروه مطمئن هستید؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
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

                // Remove Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteMember(member.empId);
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

  Color _getMemberColor(int empId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];
    return colors[empId % colors.length];
  }
}
