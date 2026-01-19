//
//  LorcanaBloc.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import Bloc
import Foundation

/// Bloc for managing Lorcana card browsing and search
@MainActor
class LorcanaBloc: Bloc<LorcanaState, LorcanaEvent> {
    
    private static let blocName = "LorcanaBloc"
    private static let example = "Lorcana"
    private let networkService: any LorcanaNetworkServiceProtocol
    private let pageSize = 100
    
    init(networkService: any LorcanaNetworkServiceProtocol) {
        self.networkService = networkService
        super.init(initialState: .initial)
        
        BlocLogger.logInit(Self.blocName, example: Self.example, initialState: LorcanaState.initial)
        
        // Register the clear event handler
        self.on(.clear) { _, emit in
            BlocLogger.logEvent(LorcanaEvent.clear, blocName: Self.blocName, example: Self.example)
            emit(.initial)
            BlocLogger.logState(LorcanaState.initial, blocName: Self.blocName, example: Self.example)
        }
    }
    
    override func mapEventToState(event: LorcanaEvent, emit: @escaping Emitter) {
        BlocLogger.logEvent(event, blocName: Self.blocName, example: Self.example)
        
        switch event {
        case .clear:
            // Handled by registered handler
            break
            
        case .fetchAllCards:
            Task { await fetchAllCards(emit: emit) }
            
        case .loadNextPage:
            Task { await loadNextPage(emit: emit) }
            
        case .search(let query):
            Task { await searchCards(query: query, emit: emit) }
            
        case .loadSet(let setName):
            Task { await loadSetCards(setName: setName, emit: emit) }
            
        case .loadSets:
            Task { await loadSets(emit: emit) }
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchAllCards(emit: @escaping Emitter) async {
        var newState = state
        newState.isLoading = true
        newState.error = nil
        newState.searchQuery = ""
        newState.currentPage = 1
        newState.cards = []
        emit(newState)
        BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        
        do {
            let cards = try await networkService.fetchAllCards(page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
            BlocLogger.logState(loadedState, blocName: Self.blocName, example: Self.example)
        } catch {
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Fetching all cards")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
    
    private func loadNextPage(emit: @escaping Emitter) async {
        // Don't load if already loading or no more pages
        guard !state.isLoadingMore && !state.isLoading && state.hasMorePages else { return }
        
        var newState = state
        newState.isLoadingMore = true
        emit(newState)
        BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        
        let nextPage = state.currentPage + 1
        
        do {
            let cards: [LorcanaCard]
            if state.isSearching {
                cards = try await networkService.searchCards(query: state.searchQuery, page: nextPage, pageSize: pageSize)
            } else {
                cards = try await networkService.fetchAllCards(page: nextPage, pageSize: pageSize)
            }
            
            var loadedState = state
            loadedState.cards.append(contentsOf: cards)
            loadedState.currentPage = nextPage
            loadedState.isLoadingMore = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
            BlocLogger.logState(loadedState, blocName: Self.blocName, example: Self.example)
        } catch {
            var errorState = state
            errorState.isLoadingMore = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Loading next page")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
    
    private func searchCards(query: String, emit: @escaping Emitter) async {
        var newState = state
        newState.isLoading = true
        newState.error = nil
        newState.searchQuery = query
        newState.currentPage = 1
        newState.cards = []
        emit(newState)
        BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        
        do {
            let cards = try await networkService.searchCards(query: query, page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
            BlocLogger.logState(loadedState, blocName: Self.blocName, example: Self.example)
        } catch {
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Searching cards")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
    
    private func loadSetCards(setName: String, emit: @escaping Emitter) async {
        var newState = state
        newState.isLoading = true
        newState.error = nil
        newState.currentPage = 1
        newState.cards = []
        emit(newState)
        BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        
        do {
            let cards = try await networkService.fetchCardsFromSet(setName: setName, page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
            BlocLogger.logState(loadedState, blocName: Self.blocName, example: Self.example)
        } catch {
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Loading set cards")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
    
    private func loadSets(emit: @escaping Emitter) async {
        do {
            let sets = try await networkService.fetchSets()
            var newState = state
            newState.sets = sets
            emit(newState)
            BlocLogger.logState(newState, blocName: Self.blocName, example: Self.example)
        } catch {
            var errorState = state
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
            BlocLogger.logError(error, blocName: Self.blocName, example: Self.example, context: "Loading sets")
            BlocLogger.logState(errorState, blocName: Self.blocName, example: Self.example)
        }
    }
}
