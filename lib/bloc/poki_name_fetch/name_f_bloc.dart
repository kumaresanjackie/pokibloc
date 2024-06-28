import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../models/poki_name_model.dart';


abstract class PokiEvent {}

class FetchPoki extends PokiEvent {}

class LoadPokemonsFromHive extends PokiEvent {}

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

class PokiBloc extends Bloc<PokiEvent, PokiState> {
  final Dio _dio = Dio();
  final int _limit = 21;
  int _offset = 0;
  bool _isFetching = false;
  final Box<PokiNameModel> _pokemonBox = Hive.box<PokiNameModel>('pokemons');

  PokiBloc() : super(PokiInitial()) {
    on<FetchPoki>(_onFetchPoki);
    on<LoadPokemonsFromHive>(_onLoadPokemonsFromHive);
  }

  Future<void> _onFetchPoki(FetchPoki event, Emitter<PokiState> emit) async {
    if (_isFetching) return;

    _isFetching = true;
    final currentState = state;
    List<PokiNameModel> oldPokemons = [];
    if (currentState is PokiLoaded) {
      oldPokemons = currentState.pokemons;
    }

    try {
      final response = await _dio.get(
        'https://pokeapi.co/api/v2/pokemon',
        queryParameters: {
          'offset': _offset,
          'limit': _limit,
        },
      );

      List<PokiNameModel> pokemons = (response.data['results'] as List)
          .map((pokemon) => PokiNameModel.fromJson(pokemon))
          .toList();

      _offset += _limit;

      // Save new data to Hive
      for (var pokemon in pokemons) {
        _pokemonBox.put(pokemon.name, pokemon);
      }

      emit(PokiLoaded(
        pokemons: oldPokemons + pokemons,
        hasReachedMax: pokemons.length < _limit,
      ));
    } catch (e) {
      emit(PokiError(error: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onLoadPokemonsFromHive(LoadPokemonsFromHive event, Emitter<PokiState> emit) async {
    List<PokiNameModel> pokemons = _pokemonBox.values.toList();
    if (pokemons.isEmpty) {
      // If Hive is empty, fetch from the API
      add(FetchPoki());
    } else {
      emit(PokiLoaded(pokemons: pokemons, hasReachedMax: false));
    }
  }
}
