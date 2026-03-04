//
//  LorcanaBloc.swift
//  BlocProject18
//
//  Created by Cursor on 19/01/2026.
//

import Bloc
import Foundation

/// Bloc for managing Lorcana card browsing and search.
@MainActor
class LorcanaBloc: Bloc<LorcanaState, LorcanaEvent> {

    private let networkService: any LorcanaNetworkServiceProtocol
    private let pageSize = 100

    init(networkService: any LorcanaNetworkServiceProtocol) {
        self.networkService = networkService
        super.init(initialState: .initial)

        self.on(.clear) { _, emit in
            emit(.initial)
        }
    }

    override func mapEventToState(event: LorcanaEvent, emit: @escaping Emitter) {
        switch event {
        case .clear:
            break // handled by registered handler

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

        do {
            let cards = try await networkService.fetchAllCards(page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
        } catch {
            addError(error)
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
        }
    }

    private func loadNextPage(emit: @escaping Emitter) async {
        guard !state.isLoadingMore && !state.isLoading && state.hasMorePages else { return }

        var newState = state
        newState.isLoadingMore = true
        emit(newState)

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
        } catch {
            addError(error)
            var errorState = state
            errorState.isLoadingMore = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
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

        do {
            let cards = try await networkService.searchCards(query: query, page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
        } catch {
            addError(error)
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
        }
    }

    private func loadSetCards(setName: String, emit: @escaping Emitter) async {
        var newState = state
        newState.isLoading = true
        newState.error = nil
        newState.currentPage = 1
        newState.cards = []
        emit(newState)

        do {
            let cards = try await networkService.fetchCardsFromSet(setName: setName, page: 1, pageSize: pageSize)
            var loadedState = state
            loadedState.cards = cards
            loadedState.isLoading = false
            loadedState.hasMorePages = cards.count == pageSize
            emit(loadedState)
        } catch {
            addError(error)
            var errorState = state
            errorState.isLoading = false
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
        }
    }

    private func loadSets(emit: @escaping Emitter) async {
        do {
            let sets = try await networkService.fetchSets()
            var newState = state
            newState.sets = sets
            emit(newState)
        } catch {
            addError(error)
            var errorState = state
            errorState.error = LorcanaError(message: error.localizedDescription)
            emit(errorState)
        }
    }
}
