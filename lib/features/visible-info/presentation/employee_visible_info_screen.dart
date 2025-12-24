// visible_info_screen.dart
import 'package:basu_118/features/visible-info/dto/visible_info_response_dto.dart';
import 'package:basu_118/features/visible-info/presentation/bloc/visible_info_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class VisibleInfoScreen extends StatefulWidget {
  final int empId;

  const VisibleInfoScreen({
    super.key,
    required this.empId,
  });

  @override
  State<VisibleInfoScreen> createState() => _VisibleInfoScreenState();
}

class _VisibleInfoScreenState extends State<VisibleInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the event when screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VisibleInfoBloc>().add(
        GetVisibleInfoEvent(empId: widget.empId),
      );
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
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'اطلاعات قابل مشاهده',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<VisibleInfoBloc, VisibleInfoState>(
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(VisibleInfoState state) {
    if (state is VisibleInfoLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text('در حال دریافت اطلاعات...'),
          ],
        ),
      );
    }

    if (state is VisibleInfoFailure) {
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
                context.read<VisibleInfoBloc>().add(
                  GetVisibleInfoEvent(empId: widget.empId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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

    if (state is VisibleInfoSuccess) {
      final employeeInfo = state.response.employeeInfo;

      if (employeeInfo.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.eye_slash,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'هیچ اطلاعات قابل مشاهده‌ای وجود ندارد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<VisibleInfoBloc>().add(
            GetVisibleInfoEvent(empId: widget.empId),
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
                          Icons.visibility,
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
                      'این صفحه اطلاعاتی را نشان می‌دهد که این کارمند اجازه مشاهده آن‌ها را به شما داده است.',
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

            // Attribute list
            ...employeeInfo.map((info) => _buildAttributeCard(info)).toList(),
          ],
        ),
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.eye, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeCard(EmployeeAttributeVisibleInfoDTO info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with blue color
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100, width: 1),
              ),
              child: Icon(
                _getIconForAttribute(info.attName),
                size: 22,
                color: Colors.blue.shade600,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.attName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Value container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            info.value != null && info.value!.isNotEmpty
                                ? Icons.info_outline
                                : Icons.remove,
                            size: 16,
                            color: info.value != null && info.value!.isNotEmpty
                                ? Colors.blue.shade600
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            info.value != null && info.value!.isNotEmpty
                                ? info.value!
                                : 'مقداری تنظیم نشده',
                            style: TextStyle(
                              fontSize: 14,
                              color: info.value != null && info.value!.isNotEmpty
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade500,
                              fontStyle: info.value != null && info.value!.isNotEmpty
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAttribute(String attName) {
    final lowerName = attName.toLowerCase();
    
    if (lowerName.contains('تلفن') || lowerName.contains('موبایل') || lowerName.contains('شماره')) {
      return Icons.phone;
    } else if (lowerName.contains('ایمیل') || lowerName.contains('email')) {
      return Icons.email;
    } else if (lowerName.contains('آدرس') || lowerName.contains('address')) {
      return Icons.location_on;
    } else if (lowerName.contains('سن') || lowerName.contains('age')) {
      return Icons.cake;
    } else if (lowerName.contains('متولد') || lowerName.contains('birth')) {
      return Icons.date_range;
    } else if (lowerName.contains('تحصیل') || lowerName.contains('education')) {
      return Icons.school;
    } else if (lowerName.contains('شغل') || lowerName.contains('job')) {
      return Icons.work;
    } else {
      return Icons.info;
    }
  }
}