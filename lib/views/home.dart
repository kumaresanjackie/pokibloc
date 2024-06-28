import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/poki_name_fetch/name_f_bloc.dart';

class PokiGrid extends StatefulWidget {
  @override
  _PokiGridState createState() => _PokiGridState();
}

class _PokiGridState extends State<PokiGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<PokiBloc>().add(FetchPoki());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Poki Grid')),
      body: BlocBuilder<PokiBloc, PokiState>(
        builder: (context, state) {
          if (state is PokiInitial || state is PokiLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PokiError) {
            return Center(child: Text(state.error));
          } else if (state is PokiLoaded) {
            if (state.pokemons.isEmpty) {
              return Center(child: Text('No pokemons found'));
            }

            return GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: state.pokemons.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.pokemons.length) {
                  return Center(child: CircularProgressIndicator());
                }
                final pokemon = state.pokemons[index];
                return Card(
                  child: Column(
                    children: [
                      // Image.network(pokemon.imageUrl ?? ''),
                      Text(pokemon.name ?? ''),
                        Text('${index+1}'),
                    ],
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
