// filter_bottom_sheet.dart
import 'package:basu_118/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterBottomSheet extends StatelessWidget {
  final ValueChanged<Faculty?>? onFacultySelected;
  final ValueChanged<Department?>? onDepartmentSelected;
  final ValueChanged<String>? onWorkAreaSelected;

  const FilterBottomSheet({
    super.key,
    this.onFacultySelected,
    this.onDepartmentSelected,
    this.onWorkAreaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilterBloc, FilterState>(
      listener: (context, state) {
        // If state is initial, trigger loading
        if (state is FilterInitial) {
          context.read<FilterBloc>().add(FilterLoadEvent());
        }
      },
      builder: (context, state) {
        // Show loading for initial and loading states
        if (state is FilterInitial || state is FilterLoading) {
          return _buildLoadingSheet();
        }

        // Show loaded state
        if (state is FilterLoaded) {
          return _buildContentSheet(context, state);
        }

        // Show error state
        return _buildErrorSheet(context);
      },
    );
  }

  Widget _buildLoadingSheet() {
    return Container(
      height: 200, // Fixed height for loading
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('در حال بارگذاری...'),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSheet(BuildContext context, FilterLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Draggable handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Text(
              'فیلترها',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
          ),

          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Faculty option
                _FilterOptionItem(
                  title: 'دانشکده',
                  value: state.faculty?.name ?? 'انتخاب نشده',
                  onTap: () => onFacultySelected?.call(state.faculty),
                  icon: Icons.school_outlined,
                ),
                const SizedBox(height: 16),

                // Department option
                _FilterOptionItem(
                  title: 'واحد سازمانی',
                  value: state.department?.name ?? 'انتخاب نشده',
                  onTap: () => onDepartmentSelected?.call(state.department),
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),

                // Work area option
                _FilterOptionItem(
                  title: 'حوزه کاری',
                  value:
                      state.workArea.isNotEmpty
                          ? state.workArea
                          : 'انتخاب نشده',
                  onTap: () => onWorkAreaSelected?.call(state.workArea),
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ),

          // Clear all button (if any filters are active)
          if (state.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<FilterBloc>().add(FilterClearEvent());
                },
                icon: Icon(Icons.close, size: 18),
                label: Text('پاک کردن همه فیلترها'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Apply button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'اعمال فیلتر',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildErrorSheet(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('خطا در بارگذاری فیلترها'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FilterBloc>().add(FilterLoadEvent());
              },
              child: Text('تلاش مجدد'),
            ),
          ],
        ),
      ),
    );
  }
}

// _FilterOptionItem remains the same...
class _FilterOptionItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  const _FilterOptionItem({
    required this.title,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right side: Icon and title
                  Row(
                    children: [
                      Icon(icon, size: 22, color: Colors.grey.shade700),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  value == 'انتخاب نشده'
                                      ? Colors.grey.shade600
                                      : Colors.blue.shade700,
                              fontWeight:
                                  value == 'انتخاب نشده'
                                      ? FontWeight.normal
                                      : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Left side: Arrow icon
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
