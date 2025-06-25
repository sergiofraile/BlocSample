//
//  BoardGamesState.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//
enum BoardGamesState: Equatable {
    case initial
    case loading
    case loaded([BoardGameModel])
    case error(BoardGameError)
}

//
//
//protocol BoardGamesState: Equatable {}
//
//struct BoardGamesLoading: BoardGamesState {}
//
//struct BoardGamesLoaded: BoardGamesState {
//    let boardGames: [BoardGameModel]
//    
//    init(boardGames: [BoardGameModel]) {
//        self.boardGames = boardGames
//    }
//}
//
//struct BoardGamesError: BoardGamesState {
//    let error: Error
//    
//    init(error: Error) {
//        self.error = error
//    }
//    
//    static func == (lhs: BoardGamesError, rhs: BoardGamesError) -> Bool {
//        lhs.error.localizedDescription == rhs.error.localizedDescription
//    }
//}
//
//struct BoardGamesEmpty: BoardGamesState {}
//
////extension BoardGamesState: Equatable {
////    static func == (lhs: BoardGamesState, rhs: BoardGamesState) -> Bool {
////        return type(of: lhs) != type(of: rhs)
////    }
////}
//
//
////abstract class CollectionState extends Equatable {
////  const CollectionState();
////
////  @override
////  List<Object> get props => [];
////}
////
////class CollectionLoading extends CollectionState {}
////
////class CollectionLoaded extends CollectionState {
////  final Collection collection;
////
////  const CollectionLoaded({@required this.collection});
////
////  @override
////  List<Object> get props => [collection];
////
////  @override
////  String toString() => 'CollectionLoaded { collection: $collection }';
////}
////
////class CollectionNotLoaded extends CollectionState {}
////
////class CollectionEmpty extends CollectionState {}
