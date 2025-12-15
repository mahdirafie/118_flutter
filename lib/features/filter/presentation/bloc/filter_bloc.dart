import 'dart:convert';
import 'package:basu_118/features/filter/dto/department_dto.dart';
import 'package:basu_118/features/filter/dto/faculty_dto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  static const String _storageKey = 'app_filters';

  FilterBloc() : super(FilterInitial()) {
    on<FilterLoadEvent>(_onLoadFilters);
    on<FilterFacultyChangedEvent>(_onFacultyChanged);
    on<FilterDepartmentChangedEvent>(_onDepartmentChanged);
    on<FilterWorkAreaChangedEvent>(_onWorkAreaChanged);
    on<FilterClearEvent>(_onClearFilters);
    on<FilterClearFacultyEvent>(_onClearFaculty);
    on<FilterClearDepartmentEvent>(_onClearDepartment);
    on<FilterClearWorkAreaEvent>(_onClearWorkArea);
  }

  Future<void> _onLoadFilters(
    FilterLoadEvent event,
    Emitter<FilterState> emit,
  ) async {
    emit(FilterLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> data =
            json.decode(jsonString) as Map<String, dynamic>;
        final loadedState = FilterLoaded.fromJson(data);
        emit(loadedState);
      } else {
        emit(const FilterLoaded());
      }
    } catch (e) {
      emit(const FilterLoaded());
    }
  }

  void _onFacultyChanged(
    FilterFacultyChangedEvent event,
    Emitter<FilterState> emit,
  ) {
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: event.faculty,
        department: null, // Clear department when faculty changes
        workArea: currentState.workArea,
      );
      emit(newState);
      _saveFiltersToStorage(newState);
    } else {
      final newState = FilterLoaded(faculty: event.faculty);
      emit(newState);
      _saveFiltersToStorage(newState);
    }
  }

  void _onDepartmentChanged(
    FilterDepartmentChangedEvent event,
    Emitter<FilterState> emit,
  ) {
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: currentState.faculty,
        department: event.department,
        workArea: currentState.workArea,
      );
      emit(newState);
      _saveFiltersToStorage(newState);
    } else {
      final newState = FilterLoaded(department: event.department);
      emit(newState);
      _saveFiltersToStorage(newState);
    }
  }

  void _onWorkAreaChanged(
    FilterWorkAreaChangedEvent event,
    Emitter<FilterState> emit,
  ) {
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: currentState.faculty,
        department: currentState.department,
        workArea: event.workArea,
      );
      emit(newState);
      _saveFiltersToStorage(newState);
    } else {
      final newState = FilterLoaded(workArea: event.workArea);
      emit(newState);
      _saveFiltersToStorage(newState);
    }
  }

  void _onClearFilters(FilterClearEvent event, Emitter<FilterState> emit) {
    emit(const FilterLoaded());
    _clearStorage();
  }

  void _onClearFaculty(
    FilterClearFacultyEvent event,
    Emitter<FilterState> emit,
  ) {
    print('Clearing faculty...');
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: null,
        department: null, // Clear department too
        workArea: currentState.workArea,
      );
      print('Old state: $currentState');
      print('New state: $newState');
      emit(newState);
      _saveFiltersToStorage(newState);
      print('Faculty cleared successfully');
    } else {
      print('State is not FilterLoaded, emitting empty state');
      emit(const FilterLoaded());
    }
  }

  void _onClearDepartment(
    FilterClearDepartmentEvent event,
    Emitter<FilterState> emit,
  ) {
    print('Clearing department...');
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: currentState.faculty,
        department: null,
        workArea: currentState.workArea,
      );
      print('Old state: $currentState');
      print('New state: $newState');
      emit(newState);
      _saveFiltersToStorage(newState);
      print('Department cleared successfully');
    } else {
      print('State is not FilterLoaded, emitting empty state');
      emit(const FilterLoaded());
    }
  }

  void _onClearWorkArea(
    FilterClearWorkAreaEvent event,
    Emitter<FilterState> emit,
  ) {
    print('Clearing work area...');
    if (state is FilterLoaded) {
      final currentState = state as FilterLoaded;
      // Create new instance directly to ensure change detection
      final newState = FilterLoaded(
        faculty: currentState.faculty,
        department: currentState.department,
        workArea: '',
      );
      print('Old state: $currentState');
      print('New state: $newState');
      emit(newState);
      _saveFiltersToStorage(newState);
      print('Work area cleared successfully');
    } else {
      print('State is not FilterLoaded, emitting empty state');
      emit(const FilterLoaded());
    }
  }

  Future<void> _saveFiltersToStorage(FilterLoaded state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(state.toJson());
      await prefs.setString(_storageKey, jsonString);
      print('Filters saved to storage: $jsonString');
    } catch (e) {
      print('Error saving filters: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      print('Storage cleared');
    } catch (e) {
      print('Error clearing filters: $e');
    }
  }
}
