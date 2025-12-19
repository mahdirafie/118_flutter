part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class GetRelativeInfo extends HomeEvent {
  final int userId;

  const GetRelativeInfo({required this.userId});
}
