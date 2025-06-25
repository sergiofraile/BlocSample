//
//  BoardGamesEvent.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc

enum BoardGamesEvent: BlocEvent {
    case loadGames
}

//
//abstract class CollectionEvent extends Equatable {
//  const CollectionEvent();
//
//  @override
//  List<Object> get props => [];
//}
//
//class LoadingCollection extends CollectionEvent {}
//
//class LoadCollection extends CollectionEvent {
//  final User user;
//
//  const LoadCollection({@required this.user});
//
//  @override
//  List<Object> get props => [user];
//
//  @override
//  String toString() => 'LoadCollection { user: $user }';
//}
//
//class UnloadCollection extends CollectionEvent {}
