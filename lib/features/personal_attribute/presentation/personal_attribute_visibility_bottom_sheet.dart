// visible_attributes_bottom_sheet.dart
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_visible_dto.dart';
import 'package:basu_118/features/personal_attribute/presentation/bloc/personal_attribute_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class VisibleAttributesBottomSheet {
  static Future<void> show({
    required BuildContext context,
    required int receiverId,
    required String type, // "employee" or "group"
    String? title,
  }) async {
    // Load visibility statuses for this specific user/group
    context.read<PersonalAttributeBloc>().add(
      GetPersonalAttributeValuesWithVisibility(
        receiverId: receiverId,
        type: type,
      ),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<PersonalAttributeBloc>()),
          ],
          child: _VisibleAttributesBottomSheetContent(
            receiverId: receiverId,
            type: type,
            title: title,
          ),
        );
      },
    );
  }
}

class _VisibleAttributesBottomSheetContent extends StatefulWidget {
  final int receiverId;
  final String type;
  final String? title;

  const _VisibleAttributesBottomSheetContent({
    required this.receiverId,
    required this.type,
    this.title,
  });

  @override
  State<_VisibleAttributesBottomSheetContent> createState() =>
      _VisibleAttributesBottomSheetContentState();
}

class _VisibleAttributesBottomSheetContentState
    extends State<_VisibleAttributesBottomSheetContent> {
  final Map<int, bool> _visibilityStates = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialization will happen when data loads
  }

  void _initializeVisibilityStates(List<AttributeVisibleDTO> attributes) {
    _visibilityStates.clear();
    for (final attribute in attributes) {
      _visibilityStates[attribute.valId] = attribute.isSharable;
    }
  }

  List<Map<String, dynamic>> _prepareAttVals() {
    final List<Map<String, dynamic>> attVals = [];

    for (final entry in _visibilityStates.entries) {
      final valId = entry.key;
      final isSharable = entry.value;

      attVals.add({
        'val_id': valId,
        'is_sharable': isSharable,
      });
    }

    return attVals;
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final attVals = _prepareAttVals();

    if (attVals.isEmpty) {
      showAppSnackBar(
        context,
        message: 'هیچ ویژگی‌ای برای تنظیم وجود ندارد',
        type: AppSnackBarType.info,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      context.read<PersonalAttributeBloc>().add(
        SetVisibleAttributes(
          id: widget.receiverId,
          type: widget.type,
          attVals: attVals,
        ),
      );
    } catch (error) {
      setState(() {
        _isSubmitting = false;
      });
      showAppSnackBar(
        context,
        message: 'خطا در ارسال درخواست: ${error.toString()}',
        type: AppSnackBarType.error,
      );
    }
  }

  void _handleSubmitSuccess() {
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      message: 'تنظیمات دسترسی با موفقیت ذخیره شد',
      type: AppSnackBarType.success,
    );
  }

  void _handleSubmitFailure(String errorMessage) {
    setState(() {
      _isSubmitting = false;
    });
    showAppSnackBar(
      context,
      message: errorMessage,
      type: AppSnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalAttributeBloc, PersonalAttributeState>(
      listener: (context, state) {
        if (state is SetVisibleAttributesSuccess) {
          _handleSubmitSuccess();
        }
        
        if (state is SetVisibleAttributesFailure) {
          _handleSubmitFailure(state.message);
        }
        
        // Initialize visibility states when attributes are loaded
        if (state is GetPersonalAttributeValuesWithVisibilitySuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeVisibilityStates(state.response.attribute);
            setState(() {});
          });
        }
      },
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ??
                        (widget.type == 'employee'
                            ? 'تنظیم دسترسی کارمند'
                            : 'تنظیم دسترسی گروه'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'انتخاب کنید کدام اطلاعات شخصی شما قابل مشاهده باشد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Content
              Expanded(
                child: _buildContent(state),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'اعمال تغییرات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(PersonalAttributeState state) {
    // Show loading for any loading state
    if (state is GetPersonalAttributeValuesWithVisibilityLoading || 
        state is SetVisibleAttributesLoading ||
        _isSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 20),
            SizedBox(height: 16),
            Text('در حال بارگذاری...'),
          ],
        ),
      );
    }

    // Handle failures
    if (state is GetPersonalAttributeValuesWithVisibilityFailure) {
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
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<PersonalAttributeBloc>().add(
                  GetPersonalAttributeValuesWithVisibility(
                    receiverId: widget.receiverId,
                    type: widget.type,
                  ),
                );
              },
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

    // Show success content
    if (state is GetPersonalAttributeValuesWithVisibilitySuccess) {
      final attributes = state.response.attribute;
      
      if (attributes.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.person,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ اطلاعات شخصی‌ای تعریف نشده است',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: attributes.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final attribute = attributes[index];
          
          // Check if we have the visibility state for this attribute
          final isSharable = _visibilityStates[attribute.valId] ?? attribute.isSharable;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                // Toggle Switch - Always visible but enabled/disabled based on state
                SizedBox(
                  width: 70, // Fixed width for the toggle area
                  child: Switch(
                    value: isSharable,
                    onChanged: _isSubmitting 
                        ? null // Disable during submission
                        : (value) {
                            setState(() {
                              _visibilityStates[attribute.valId] = value;
                            });
                          },
                    activeColor: Colors.blue,
                    inactiveTrackColor: Colors.grey.shade400,
                    // Make sure the switch is always visible
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Attribute Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attribute.attName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (attribute.value != null && attribute.value!.isNotEmpty)
                        Text(
                          attribute.value!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        Text(
                          'مقداری تنظیم نشده',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSharable ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSharable ? Colors.green.shade200 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    isSharable ? 'قابل مشاهده' : 'غیرقابل مشاهده',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSharable ? Colors.green.shade700 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Initial loading state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 16),
          SizedBox(height: 16),
          Text('در حال بارگذاری اطلاعات...'),
        ],
      ),
    );
  }
}