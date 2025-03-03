import 'package:flutter/material.dart';
import 'package:movie_app_2024_02/src/providers/peliculas_provider.dart';
import 'package:movie_app_2024_02/src/search/search_delegate.dart';
import 'package:movie_app_2024_02/src/widgets/card_swiper_widget.dart';
import 'package:movie_app_2024_02/src/widgets/movie_horizontal.dart';
import 'package:movie_app_2024_02/src/models/pelicula_model.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final PeliculasProvider peliculasProvider = PeliculasProvider();

  @override
  Widget build(BuildContext context) {
    peliculasProvider.getPopulares();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Películas en cines'),
        backgroundColor: Colors.indigoAccent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch());
            },
          ),
        ],
      ),
      body: Column(children: <Widget>[_swiperTarjetas(), _footer(context)]),
    );
  }

  Widget _swiperTarjetas() {
    return FutureBuilder<List<Pelicula>>(
      future: peliculasProvider.getEnCines(),
      builder: (BuildContext context, AsyncSnapshot<List<Pelicula>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 400.0,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
            height: 400.0,
            child: Center(child: Text("Error al cargar datos")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 400.0,
            child: Center(child: Text("No hay películas disponibles")),
          );
        } else {
          return CardSwiper(peliculas: snapshot.data ?? []);
        }
      },
    );
  }

  Widget _footer(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              'Populares',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 5.0),
          StreamBuilder<List<Pelicula>>(
            stream: peliculasProvider.popularesStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<Pelicula>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error al cargar datos"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No hay películas populares"));
              } else {
                return MovieHorizontal(
                  peliculas: snapshot.data ?? [],
                  siguientePagina: peliculasProvider.getPopulares,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}