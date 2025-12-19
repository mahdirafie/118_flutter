part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class RelativeInfoInitial extends HomeState {}

final class RelativeInfoLoading extends HomeState {}

final class RelativeInfoSuccess extends HomeState {
  final HomeResponseDTO response;

  const RelativeInfoSuccess({required this.response});
}

final class RelativeInfoFailure extends HomeState {
  final String message;

  const RelativeInfoFailure({required this.message});
}
