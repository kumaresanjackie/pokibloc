import '../../models/poki_name_model.dart';

abstract class PokiState {}

class PokiInitial extends PokiState {}

class PokiLoading extends PokiState {}

class PokiLoaded extends PokiState {
  final List<PokiNameModel> pokemons;
  final bool hasReachedMax;

  PokiLoaded({required this.pokemons, required this.hasReachedMax});
}

class PokiError extends PokiState {
  final String error;

  PokiError({required this.error});
}
