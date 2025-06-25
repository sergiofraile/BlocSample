//
//  BoardGamesBloc.swift
//  BlocProject
//
//  Created by Sergio Fraile on 24/06/2025.
//

import Bloc
import Foundation

class BoardGamesBloc: Bloc<BoardGamesState, BoardGamesEvent> {

    override init(initialState: BoardGamesState) {
        super.init(initialState: initialState)
        
        self.on(.loadGames) { event, emit in
            emit(.loading)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let self = self else { return }
                // After the request, emit the loaded state with some dummy data
                let boardGames = [BoardGameModel(name: "Chess"), BoardGameModel(name: "Monopoly")]
                self.emit(.loaded(boardGames))
            }
        }
    }
}
//class BoardGamesBloc<State: BoardGamesState & Equatable>: Bloc<State, BoardGamesEvent> {
//    
//    override init(initialState: State) {
//        super.init(initialState: initialState)
//        
////        self.on(.loading) { event, emit in
////            // Increment the current state by 1
////            emit([])
////        }
////        
////        self.on(.loaded([])) { event, emit in
////            // Decrease the current state by 1
////            emit([])
////        }
////        
////        self.on(.error("paco")) { event, emit in
////            // Reset the state to the initial value
////            emit([])
////        }
//    }
//    
////    override func mapEventToState(event: BoardGamesEvent) async {
////        switch event {
////        case .request:
////            mapRequestToState()
////        case .loaded(let boardGames):
////            mapLoadedToState(boardGames: boardGames)
////        case .error(_):
////            <#code#>
////        }
////        
////    func mapRequestToState() {
////        emit (BoardGamesLoading() as! State)
////        // Simulate a network request
////        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
////            // After the request, emit the loaded state with some dummy data
////            let boardGames = [BoardGameModel(name: "Chess"), BoardGameModel(name: "Monopoly")]
////            self.emit(BoardGamesLoaded(boardGames: boardGames) as! State)
////        }
////    }
////        
////    func mapLoadedToState(boardGames: [BoardGameModel]) {
////        
////        
////        
//        
//}

//
//class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
//  final DataService dataService;
//  final int loadingAttempts = 6;
//  final int requestDelay = 2;
//
//  CollectionBloc({
//    @required this.dataService,
//  }) : assert(dataService != null);
//
//  @override
//  CollectionState get initialState => CollectionLoading();
//
//  @override
//  Stream<CollectionState> mapEventToState(CollectionEvent event) async* {
//    if (event is LoadCollection) {
//      yield* _mapLoadCollectionsToState(event);
//    } else if (event is UnloadCollection) {
//      yield* _mapUnloadCollectionsToState(event);
//    } else if (event is LoadingCollection) {
//      yield* _mapLoadingCollectionToState(event);
//    }
//  }
//
//  Stream<CollectionState> _mapLoadCollectionsToState(
//      LoadCollection event) async* {
//    try {
//      final cacheMap = await dataService.databaseService
//          .getCacheElement(event.user.userName, kCollectionType);
//      Collection collection;
//      var needsToRequest = true;
//
//      if (cacheMap != null) {
//        var now = DateTime.now();
//        var cachedOn = DateTime.parse(cacheMap[kColumnTimestamp]);
//        var hoursSinceCache = now.difference(cachedOn).inMinutes;
//        if (hoursSinceCache <= kCacheTimeoutInMinutesForCollections) {
//          needsToRequest = false;
//          var decodedJson = json.decode(cacheMap[kColumnValue]);
//          collection = Collection.fromJson(decodedJson);
//        }
//      }
//
//      if (needsToRequest) {
//        collection =
//            await _loadCollection(event.user.userName, loadingAttempts);
//        dataService.databaseService.insertCacheElement(
//            event.user.userName, kBoardGameType, collection.jsonString);
//      }
//
//      if (collection.games.isEmpty) {
//        yield CollectionEmpty();
//      } else {
//        yield CollectionLoaded(collection: collection);
//      }
//    } catch (_) {
//      yield CollectionNotLoaded();
//    }
//  }
//
//  Stream<CollectionState> _mapUnloadCollectionsToState(
//      UnloadCollection event) async* {
//    yield CollectionNotLoaded();
//  }
//
//  Stream<CollectionState> _mapLoadingCollectionToState(
//      LoadingCollection event) async* {
//    yield CollectionLoading();
//  }
//
//  Future<Collection> _loadCollection(String userName, int attempts) async {
//    try {
//      final collection = await this
//          .dataService
//          .apiService
//          .getCollectionFromUser(userName, kRequestStats);
//      return collection;
//    } catch (error) {
//      if (attempts == 0) {
//        throw Exception('Collection could not be loaded');
//      } else {
//        await Future.delayed(Duration(seconds: requestDelay));
//        return await _loadCollection(userName, attempts - 1);
//      }
//    }
//  }
//}
