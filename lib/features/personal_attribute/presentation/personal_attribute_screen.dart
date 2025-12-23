// personal_attribute_screen.dart
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';
import 'package:basu_118/features/personal_attribute/presentation/bloc/personal_attribute_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class PersonalAttributeScreen extends StatefulWidget {
  const PersonalAttributeScreen({super.key});

  @override
  State<PersonalAttributeScreen> createState() =>
      _PersonalAttributeScreenState();
}

class _PersonalAttributeScreenState extends State<PersonalAttributeScreen> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String?> _originalValues = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalAttributeBloc>().add(GetPersonalAttributesEvent());
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers(List<PersonalAttributeDTO> attributes) {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _originalValues.clear();

    for (final attribute in attributes) {
      final controller = TextEditingController(text: attribute.value ?? '');
      _controllers[attribute.attId] = controller;
      _originalValues[attribute.attId] = attribute.value;

      controller.addListener(() {
        _checkForChanges();
      });
    }
  }

  void _checkForChanges() {
    bool hasChanges = false;

    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      final originalValue = _originalValues[attId];

      final currentValue = controller.text.isEmpty ? null : controller.text;
      if (currentValue != originalValue) {
        hasChanges = true;
        break;
      }
    }

    if (mounted && hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  String _getFieldLabel(PersonalAttributeDTO attribute) {
    switch (attribute.type.toLowerCase()) {
      case 'phone':
        return 'شماره ${attribute.attName}';
      case 'email':
        return 'ایمیل ${attribute.attName}';
      case 'address':
        return 'آدرس ${attribute.attName}';
      default:
        return attribute.attName;
    }
  }

  TextInputType _getKeyboardType(PersonalAttributeDTO attribute) {
    switch (attribute.type.toLowerCase()) {
      case 'phone':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  String? _validateField(String? value, PersonalAttributeDTO attribute) {
    if (value == null || value.isEmpty) {
      return null;
    }

    switch (attribute.type.toLowerCase()) {
      case 'email':
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return 'فرمت ایمیل نامعتبر است';
        }
        break;
      case 'phone':
        final phoneRegex = RegExp(r'^[0-9]{10,11}$');
        if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
          return 'شماره تلفن نامعتبر است';
        }
        break;
      case 'number':
        if (double.tryParse(value) == null) {
          return 'لطفا یک عدد معتبر وارد کنید';
        }
        break;
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        context,
        message: 'لطفا مقادیر را به درستی وارد کنید',
        type: AppSnackBarType.error,
      );
      return;
    }

    // Send ALL fields, not just changed ones
    final List<Map<String, dynamic>> attributesToUpdate = [];

    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      
      // Always include ALL fields, even unchanged ones
      attributesToUpdate.add({
        'att_id': attId,
        'value': controller.text.isEmpty ? null : controller.text,
      });
    }

    if (attributesToUpdate.isEmpty) {
      showAppSnackBar(
        context,
        message: 'هیچ فیلدی برای ارسال وجود ندارد',
        type: AppSnackBarType.info,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      context.read<PersonalAttributeBloc>().add(
        SetPersonalAttributeValuesEvent(attributes: attributesToUpdate),
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

  void _handleSubmitSuccess(String message) {
    // Update original values for ALL fields
    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      _originalValues[attId] = controller.text.isEmpty ? null : controller.text;
    }

    setState(() {
      _hasChanges = false;
      _isSubmitting = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'تغییرات ذخیره شد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<PersonalAttributeBloc>().add(
                      GetPersonalAttributesEvent(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('باشه'),
                ),
              ),
            ],
          ),
        );
      },
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

  void _handleCancel() {
    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      final originalValue = _originalValues[attId];
      controller.text = originalValue ?? '';
    }

    setState(() {
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.grey.shade700),
          onPressed: () {
            if (_hasChanges) {
              _showExitConfirmation();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'اطلاعات شخصی',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<PersonalAttributeBloc, PersonalAttributeState>(
        listener: (context, state) {
          if (state is PersonalAttributeFailure) {
            showAppSnackBar(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
          }
          
          if (state is SetPersonalAttributeValuesSuccess) {
            _handleSubmitSuccess(state.message);
          }
          
          if (state is SetPersonalAttributeValuesFailure) {
            _handleSubmitFailure(state.message);
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'تغییرات ذخیره نشده',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
            content: const Text(
              'تغییرات شما ذخیره نشده است. آیا مطمئن هستید که می‌خواهید از صفحه خارج شوید؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'لغو',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('خروج'),
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

  Widget _buildBody(PersonalAttributeState state) {
    if (state is PersonalAttributeLoading || 
        state is SetPersonalAttributeValuesLoading ||
        _isSubmitting) {
      return Stack(
        children: [
          if (state is PersonalAttributeSuccess) 
            _buildSuccessContent(state)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 16),
                  const SizedBox(height: 16),
                  Text(
                    _isSubmitting ? 'در حال ذخیره تغییرات...' : 'در حال دریافت اطلاعات...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 20),
              ),
            ),
        ],
      );
    }

    if (state is PersonalAttributeFailure) {
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
              onPressed: () {
                context.read<PersonalAttributeBloc>().add(
                  GetPersonalAttributesEvent(),
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

    if (state is PersonalAttributeSuccess) {
      return _buildSuccessContent(state);
    }

    if (state is SetPersonalAttributeValuesFailure) {
      if (_controllers.isNotEmpty) {
        return _buildSuccessContentFromControllers();
      }
      
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
              onPressed: () {
                context.read<PersonalAttributeBloc>().add(
                  GetPersonalAttributesEvent(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('بازگشت'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.person, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(PersonalAttributeSuccess state) {
    final attributes = state.response.attributes;

    if (_controllers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeControllers(attributes);
      });
    }

    return _buildForm(attributes);
  }

  Widget _buildSuccessContentFromControllers() {
    return _buildForm([]);
  }

  Widget _buildForm(List<PersonalAttributeDTO> attributes) {
    final hasAttributes = attributes.isNotEmpty || _controllers.isNotEmpty;

    if (!hasAttributes) {
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

    final displayAttributes = attributes.isNotEmpty 
        ? attributes 
        : _controllers.keys.map((attId) => PersonalAttributeDTO(
              attId: attId,
              attName: 'Attribute $attId',
              type: 'text',
              value: _originalValues[attId],
            )).toList();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<PersonalAttributeBloc>().add(
                  GetPersonalAttributesEvent(),
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'راهنما',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لطفا اطلاعات شخصی خود را با دقت وارد کنید. این اطلاعات برای خدمات بهتر به شما استفاده خواهد شد.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...displayAttributes.map((attribute) {
                    final controller = _controllers[attribute.attId];
                    if (controller == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getFieldLabel(attribute),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller,
                            keyboardType: _getKeyboardType(attribute),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: '${_getFieldLabel(attribute)} را وارد کنید',
                              hintTextDirection: TextDirection.rtl,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              suffixIcon: controller.text.isNotEmpty
                                  ? const Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Colors.green,
                                    )
                                  : null,
                            ),
                            validator: (value) => _validateField(value, attribute),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          if (_hasChanges)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _handleCancel,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'ذخیره تغییرات',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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