// contact_detail_screen.dart
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/favorites/presentation/favorite_category_bottom_sheet.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:basu_118/features/contact_detail/presentation/bloc/contact_detail_bloc.dart';
import 'package:basu_118/features/contact_detail/dto/contact_detail_dto.dart';
import 'package:go_router/go_router.dart';

class ContactDetailScreen extends StatefulWidget {
  final int cid;

  const ContactDetailScreen({super.key, required this.cid});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  bool _isFavoriteLoading = false;
  bool _isDeleteLoading = false;

  @override
  void initState() {
    super.initState();
    // Trigger the event when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactDetailBloc>().add(
        GetContactDetailStarted(
          cid: widget.cid,
          uid: AuthService().userInfo!.uid!,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FavoriteBloc, FavoriteState>(
          listener: (context, state) {
            // Handle delete operations
            if (state is DeleteFromFavoritesSuccess) {
              setState(() {
                _isDeleteLoading = false;
              });

              // Refresh contact detail data
              final userId = AuthService().userInfo?.uid;
              if (userId != null) {
                context.read<ContactDetailBloc>().add(
                  GetContactDetailStarted(
                    cid: widget.cid,
                    uid: userId,
                  ),
                );
              }
            }

            if (state is DeleteFromFavoritesFailure) {
              setState(() {
                _isDeleteLoading = false;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: Colors.grey.shade700),
            onPressed: () {
              context.pop();
            },
          ),
          centerTitle: true,
          title: Text(
            'جزئیات تماس',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<ContactDetailBloc, ContactDetailState>(
          builder: (context, state) {
            return _buildBody(state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(ContactDetailState state) {
    if (state is GetContactDetailLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text('در حال دریافت اطلاعات تماس...'),
          ],
        ),
      );
    }

    if (state is GetContactDetailFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ContactDetailBloc>().add(
                  GetContactDetailStarted(
                    cid: widget.cid,
                    uid: AuthService().userInfo!.uid!,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state is GetContactDetailSuccess) {
      final contact = state.response.contact;
      final relativeInfo = contact.relativeInfo;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Profile Card based on contact type
            _buildProfileCard(contact, state),

            const SizedBox(height: 32),

            // Contact Numbers Section
            _buildContactNumbersSection(contact.contactInfos),

            const SizedBox(height: 32),

            // Related Information based on contact type
            if (relativeInfo != null)
              _buildRelatedInfoSection(contact.contactType, relativeInfo),
          ],
        ),
      );
    }

    return Container(); // Initial state
  }

  Widget _buildProfileCard(ContactContact contact, GetContactDetailSuccess state) {
    // Get main title and icon based on contact type
    final (String title, IconData icon, String typeLabel) = _getContactMainInfo(
      contact,
    );

    // Determine favorite loading state
    final isLoading = _isFavoriteLoading || _isDeleteLoading;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade50],
            ),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            children: [
              // Icon and Title (Centered)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Icon(icon, size: 36, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Type Label
                    Text(
                      typeLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite Button (at bottom of card)
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: Center(
                  child: _buildFavoriteButton(contact, isLoading),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(ContactContact contact, bool isLoading) {
    if (isLoading) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            contact.isFavorite ? Colors.red : Colors.grey.shade400,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: () async {
        if (contact.isFavorite) {
          // Delete from favorites
          await _handleDeleteFromFavorites();
        } else {
          // Add to favorites
          await _handleAddToFavorites();
        }
      },
      icon: Icon(
        contact.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        size: 28,
        color: contact.isFavorite ? Colors.red : Colors.grey.shade400,
      ),
    );
  }

  Future<void> _handleAddToFavorites() async {
    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    // Show bottom sheet for category selection
    final selectedIds = await FavoriteCategoryBottomSheet.show(
      context: context,
      cid: widget.cid,
    );

    // Stop loading regardless of result
    setState(() {
      _isFavoriteLoading = false;
    });

    // If user selected categories, refresh contact detail
    if (selectedIds != null && selectedIds.isNotEmpty) {
      // Wait a bit to allow bottom sheet to close completely
      await Future.delayed(const Duration(milliseconds: 300));
      
      final userId = AuthService().userInfo?.uid;
      if (userId != null) {
        context.read<ContactDetailBloc>().add(
          GetContactDetailStarted(
            cid: widget.cid,
            uid: userId,
          ),
        );
      }
    }
    // If selectedIds is empty array, user selected "none" - still need to refresh
    else if (selectedIds != null && selectedIds.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final userId = AuthService().userInfo?.uid;
      if (userId != null) {
        context.read<ContactDetailBloc>().add(
          GetContactDetailStarted(
            cid: widget.cid,
            uid: userId,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteFromFavorites() async {
    if (_isDeleteLoading) return;

    setState(() {
      _isDeleteLoading = true;
    });

    final userId = AuthService().userInfo?.uid;
    if (userId != null) {
      context.read<FavoriteBloc>().add(
        DeleteFromFavorites(cid: widget.cid, uid: userId),
      );
    } else {
      setState(() {
        _isDeleteLoading = false;
      });
    }
  }

  (String, IconData, String) _getContactMainInfo(ContactContact contact) {
    final relativeInfo = contact.relativeInfo;

    switch (contact.contactType) {
      case 'employee':
        final employeeName = relativeInfo?.employee?.user?.fullName ?? 'کارمند';
        return (employeeName, CupertinoIcons.person_fill, 'کارمند');

      case 'post':
        final postName = relativeInfo?.post?.pname ?? 'پست';
        return (postName, CupertinoIcons.briefcase_fill, 'پست سازمانی');

      case 'space':
        final spaceName = relativeInfo?.space?.sname ?? 'فضا';
        return (spaceName, CupertinoIcons.building_2_fill, 'فضای فیزیکی');

      default:
        return ('ناشناس', CupertinoIcons.question_circle_fill, 'ناشناس');
    }
  }

  Widget _buildContactNumbersSection(List<ContactInfoContact> contactInfos) {
    if (contactInfos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.phone, size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'شماره تماسی ثبت نشده است',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Text(
            'شماره‌های تماس',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        ...contactInfos
            .map((contactInfo) => _buildContactNumberCard(contactInfo))
            ,
      ],
    );
  }

  Widget _buildContactNumberCard(ContactInfoContact contactInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Number
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    CupertinoIcons.phone_fill,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    contactInfo.contactNumber,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Information Grid
            if (_hasAdditionalInfo(contactInfo))
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (contactInfo.range != null)
                    _buildInfoChip('محدوده', contactInfo.range!),
                  if (contactInfo.subrange != null)
                    _buildInfoChip('زیرمحدوده', contactInfo.subrange!),
                  if (contactInfo.forward != null)
                    _buildInfoChip('ارجاع', contactInfo.forward!),
                  if (contactInfo.extension != null)
                    _buildInfoChip('داخلی', contactInfo.extension!),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool _hasAdditionalInfo(ContactInfoContact contactInfo) {
    return contactInfo.range != null ||
        contactInfo.subrange != null ||
        contactInfo.forward != null ||
        contactInfo.extension != null;
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildRelatedInfoSection(
    String contactType,
    RelativeInfoContact relativeInfo,
  ) {
    final relatedItems = _getRelatedItems(contactType, relativeInfo);

    if (relatedItems.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
          child: Text(
            'اطلاعات مرتبط',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Show related items based on contact type
        ...relatedItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRelatedInfoCard(item),
              ),
            )
            ,
      ],
    );
  }

  List<RelatedItem> _getRelatedItems(
    String contactType,
    RelativeInfoContact relativeInfo,
  ) {
    final items = <RelatedItem>[];

    switch (contactType) {
      case 'employee':
        // For employee, show related post and space
        if (relativeInfo.post != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.briefcase_fill,
              title: 'پست مربوطه',
              value: relativeInfo.post!.pname,
            ),
          );
        }
        if (relativeInfo.space != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.building_2_fill,
              title: 'فضای مربوطه',
              value: relativeInfo.space!.sname,
            ),
          );
        }
        break;

      case 'post':
        // For post, show related employee and space
        if (relativeInfo.employee?.user != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.person_fill,
              title: 'کارمند مربوطه',
              value: relativeInfo.employee!.user!.fullName,
            ),
          );
        }
        if (relativeInfo.space != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.building_2_fill,
              title: 'فضای مربوطه',
              value: relativeInfo.space!.sname,
            ),
          );
        }
        break;

      case 'space':
        // For space, show related post and employee
        if (relativeInfo.post != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.briefcase_fill,
              title: 'پست مربوطه',
              value: relativeInfo.post!.pname,
            ),
          );
        }
        if (relativeInfo.employee?.user != null) {
          items.add(
            RelatedItem(
              icon: CupertinoIcons.person_fill,
              title: 'کارمند مربوطه',
              value: relativeInfo.employee!.user!.fullName,
            ),
          );
        }
        break;
    }

    return items;
  }

  Widget _buildRelatedInfoCard(RelatedItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 22, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for related items
class RelatedItem {
  final IconData icon;
  final String title;
  final String value;

  RelatedItem({required this.icon, required this.title, required this.value});
}