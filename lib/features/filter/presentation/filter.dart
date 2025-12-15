// filter_widget.dart
import 'package:basu_118/features/filter/presentation/bloc/filter_api_bloc.dart';
import 'package:basu_118/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_bottom_sheet.dart';

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          onFacultySelected: (faculty) {
            Navigator.pop(context);
            _showFacultySelectionSheet(context);
          },
          onDepartmentSelected: (department) {
            Navigator.pop(context);
            _showDepartmentSelectionSheet(context);
          },
          onWorkAreaSelected: (workarea) {
            Navigator.pop(context);
            _showWorkAreaSelectionSheet(context);
          },
        );
      },
    );
  }

  void _showFacultySelectionSheet(BuildContext context) {
    // Get the bloc instance
    final filterApiBloc = context.read<FilterApiBloc>();

    // Dispatch event to load faculties
    filterApiBloc.add(GetAllFaculties());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: filterApiBloc,
          child: BlocBuilder<FilterApiBloc, FilterApiState>(
            builder: (context, state) {
              return _buildFacultySelectionSheet(context, state);
            },
          ),
        );
      },
    );
  }

  Widget _buildFacultySelectionSheet(
    BuildContext context,
    FilterApiState state,
  ) {
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
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              'انتخاب دانشکده',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Content based on state
          Expanded(child: _buildFacultyContent(context, state)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFacultyContent(BuildContext context, FilterApiState state) {
    if (state is GetAllFacultiesLoading) {
      return const Center(child: Text('در حال دریافت دانشکده ها...'));
    }

    if (state is GetAllFacultiesFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FilterApiBloc>().add(GetAllFaculties());
              },
              child: Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state is GetAllFacultiesSuccess) {
      final faculties =
          state.response.faculties
              .map((model) => Faculty.fromModel(model))
              .toList();

      if (faculties.isEmpty) {
        return const Center(child: Text('هیچ دانشکده‌ای یافت نشد'));
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: faculties.length,
        itemBuilder: (context, index) {
          final faculty = faculties[index];
          return ListTile(
            title: Text(faculty.name),
            onTap: () {
              context.read<FilterBloc>().add(
                FilterFacultyChangedEvent(faculty: faculty),
              );
              Navigator.pop(context);
            },
          );
        },
      );
    }

    // Initial state
    return const Center(child: CircularProgressIndicator());
  }

  void _showDepartmentSelectionSheet(BuildContext context) {
    // Get the current faculty from FilterBloc
    final filterState = context.read<FilterBloc>().state;

    if (filterState is! FilterLoaded || filterState.faculty == null) {
      // Show message to select faculty first
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('انتخاب دانشکده'),
              content: Text('لطفاً ابتدا دانشکده را انتخاب کنید'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('باشه'),
                ),
              ],
            ),
      );
      return;
    }

    final facultyId = filterState.faculty!.id;
    final filterApiBloc = context.read<FilterApiBloc>();

    // Dispatch event to load departments for this faculty
    filterApiBloc.add(GetAllFacultyDepartments(facultyId: facultyId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: filterApiBloc,
          child: BlocBuilder<FilterApiBloc, FilterApiState>(
            builder: (context, state) {
              return _buildDepartmentSelectionSheet(
                context,
                state,
                filterState.faculty!.name,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentSelectionSheet(
    BuildContext context,
    FilterApiState state,
    String facultyName,
  ) {
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

          // Title with faculty name
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              children: [
                Text(
                  'انتخاب واحد سازمانی',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'دانشکده: $facultyName',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Content based on state
          Expanded(child: _buildDepartmentContent(context, state)),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDepartmentContent(BuildContext context, FilterApiState state) {
    if (state is GetAllFacultyDepartmentsLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال دریافت واحدهای سازمانی...'),
          ],
        ),
      );
    }

    if (state is GetAllFacultyDepartmentsFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(state.message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Get facultyId from FilterBloc again
                final filterState = context.read<FilterBloc>().state;
                if (filterState is FilterLoaded &&
                    filterState.faculty != null) {
                  context.read<FilterApiBloc>().add(
                    GetAllFacultyDepartments(
                      facultyId: filterState.faculty!.id,
                    ),
                  );
                }
              },
              child: Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state is GetAllFacultyDepartmentsSuccess) {
      final departments =
          state.response.departments
              .map((model) => Department.fromModel(model))
              .toList();

      if (departments.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey, size: 48),
              SizedBox(height: 16),
              Text('هیچ واحد سازمانی برای این دانشکده وجود ندارد'),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final department = departments[index];
          return ListTile(
            title: Text(department.name),
            onTap: () {
              context.read<FilterBloc>().add(
                FilterDepartmentChangedEvent(department: department),
              );
              Navigator.pop(context);
            },
          );
        },
      );
    }

    // Initial state or other states
    return const Center(child: CircularProgressIndicator());
  }

  void _showWorkAreaSelectionSheet(BuildContext context) {
    // Dispatch event to load work areas
    context.read<FilterApiBloc>().add(GetAllWorkareas());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocBuilder<FilterApiBloc, FilterApiState>(
          builder: (context, state) {
            List<String> workAreas = [];

            // Handle different states
            if (state is GetAllWorkareasLoading) {
              return _buildWorkAreaLoadingSheet('حوزه کاری');
            }

            if (state is GetAllWorkareasFailure) {
              return _buildWorkAreaErrorSheet('حوزه کاری', state.message, () {
                context.read<FilterApiBloc>().add(GetAllWorkareas());
              });
            }

            if (state is GetAllWorkareasSuccess) {
              workAreas = state.response.workareas;
            }

            return _buildSelectionSheet<String>(
              'حوزه کاری',
              items: workAreas,
              onItemSelected: (workArea) {
                context.read<FilterBloc>().add(
                  FilterWorkAreaChangedEvent(workArea: workArea),
                );
                Navigator.pop(context);
              },
              itemBuilder: (workArea) => Text(workArea),
            );
          },
        );
      },
    );
  }

  // Helper methods for loading and error states
  Widget _buildWorkAreaLoadingSheet(String title) {
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
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Text(
              'انتخاب $title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('در حال دریافت...')],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildWorkAreaErrorSheet(String title, String error, VoidCallback onRetry) {
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
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              'انتخاب $title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(error, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: onRetry, child: Text('تلاش مجدد')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSelectionSheet<T>(
    String title, {
    required List<T> items,
    required Function(T) onItemSelected,
    required Widget Function(T) itemBuilder,
  }) {
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
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Text(
              'انتخاب $title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: itemBuilder(items[index]),
                  onTap: () => onItemSelected(items[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        if (state is FilterLoaded) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(color: AppColors.neutral[50]),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter button (kept original style)
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.neutral[200]!,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/filter.svg',
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 5),
                          Text('فیلترها'),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Active filters chips with Wrap
                if (state.hasActiveFilters)
                  Expanded(child: _buildActiveFilters(state, context)),
              ],
            ),
          );
        }

        // Loading or initial state
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(color: AppColors.neutral[50]),
          child: Row(
            children: [
              // Filter button
              GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.neutral[200]!,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/filter.svg',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(width: 5),
                        Text('فیلترها'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Placeholder
              Container(width: 0, height: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFilters(FilterLoaded state, BuildContext context) {
    return Wrap(
      spacing: 8, // Horizontal space between chips
      runSpacing: 4, // Vertical space between rows
      children: [
        // Faculty chip
        if (state.faculty != null)
          _buildFilterChip(
            context,
            label: 'دانشکده ${state.faculty!.name}',
            onClose: () {
              print('Closing faculty filter');
              context.read<FilterBloc>().add(FilterClearFacultyEvent());
            },
          ),

        // Department chip
        if (state.department != null)
          _buildFilterChip(
            context,
            label: 'واحد ${state.department!.name}',
            onClose: () {
              print('Closing department filter');
              context.read<FilterBloc>().add(FilterClearDepartmentEvent());
            },
          ),

        // Work area chip
        if (state.workArea.isNotEmpty)
          _buildFilterChip(
            context,
            label: 'حوزه کاری: ${state.workArea}',
            onClose: () {
              print('Closing work area filter');
              context.read<FilterBloc>().add(FilterClearWorkAreaEvent());
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onClose,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, size: 16, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
