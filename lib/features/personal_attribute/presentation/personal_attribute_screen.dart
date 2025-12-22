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
  final Map<int, String> _originalValues = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Fetch personal attributes on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalAttributeBloc>().add(GetPersonalAttributesEvent());
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers(List<PersonalAttributeDTO> attributes) {
    // Clear existing controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _originalValues.clear();

    // Create controllers for each attribute
    for (final attribute in attributes) {
      final controller = TextEditingController(text: attribute.value ?? '');
      _controllers[attribute.attId] = controller;
      _originalValues[attribute.attId] = attribute.value ?? '';

      // Add listener to track changes
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
      final originalValue = _originalValues[attId] ?? '';

      if (controller.text != originalValue) {
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
    // Customize label based on attribute type if needed
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
      return 'لطفا ${_getFieldLabel(attribute)} را وارد کنید';
    }

    // Add specific validations based on type
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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(
        context,
        message: 'لطفا مقادیر را به درستی وارد کنید',
        type: AppSnackBarType.error,
      );
      return;
    }

    // Prepare data for API call
    final Map<int, String> updatedValues = {};

    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      final originalValue = _originalValues[attId] ?? '';

      // Only include changed values
      if (controller.text != originalValue) {
        updatedValues[attId] = controller.text;
      }
    }

    if (updatedValues.isEmpty) {
      showAppSnackBar(
        context,
        message: 'تغییری اعمال نشده است',
        type: AppSnackBarType.info,
      );
      return;
    }

    // TODO: Implement API call here
    // For now, show a success message
    showAppSnackBar(
      context,
      message: 'تغییرات با موفقیت ذخیره شد',
      type: AppSnackBarType.success,
    );

    // Update original values
    for (final entry in updatedValues.entries) {
      _originalValues[entry.key] = entry.value;
    }

    // Reset changes flag
    setState(() {
      _hasChanges = false;
    });

    // Show success dialog
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
              'تغییرات ذخیره شد',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'اطلاعات شما با موفقیت به‌روزرسانی شد',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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

  void _handleCancel() {
    // Reset all controllers to original values
    for (final entry in _controllers.entries) {
      final attId = entry.key;
      final controller = entry.value;
      final originalValue = _originalValues[attId] ?? '';
      controller.text = originalValue;
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
    if (state is PersonalAttributeLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text(
              'در حال دریافت اطلاعات...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
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
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            SizedBox(height: 24),
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
      final attributes = state.response.attributes;

      // Initialize controllers if not already done
      if (_controllers.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeControllers(attributes);
        });
      }

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
              SizedBox(height: 16),
              Text(
                'هیچ اطلاعات شخصی‌ای تعریف نشده است',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

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
                    // Information card
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
                                SizedBox(width: 8),
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
                            SizedBox(height: 8),
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
                    SizedBox(height: 16),

                    // Attribute fields
                    ...attributes.map((attribute) {
                      final controller = _controllers[attribute.attId];
                      if (controller == null) {
                        return SizedBox.shrink();
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
                            SizedBox(height: 8),
                            TextFormField(
                              controller: controller,
                              keyboardType: _getKeyboardType(attribute),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText:
                                    '${_getFieldLabel(attribute)} را وارد کنید',
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
                                  borderSide: BorderSide(
                                    color: Colors.blue,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                suffixIcon:
                                    attribute.value != null &&
                                            attribute.value!.isNotEmpty
                                        ? Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: Colors.green,
                                        )
                                        : null,
                              ),
                              validator:
                                  (value) => _validateField(value, attribute),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Submit button
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
                        onPressed: _handleCancel,
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
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
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

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.person, size: 48, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
