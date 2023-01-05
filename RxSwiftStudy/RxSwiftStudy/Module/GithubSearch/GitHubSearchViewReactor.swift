//
//  GitHubSearchViewReactor.swift
//  RxSwiftStudy
//
//  Created by 高云泽 on 2023/1/5.
//

import RxSwift
import RxCocoa
import ReactorKit

final class GitHubSearchViewReactor: Reactor {
    // 用户行为
    enum Action {
        // 搜索关键字变更
        case updateQuery(String?)
        
        // 触发加载下页
        case loadNextPage
    }
    
    // 用于描状态变更
    enum Mutation {
      case setQuery(String?)
      case setRepos([String], nextPage: Int?)
      case appendRepos([String], nextPage: Int?)
      case setLoadingNextPage(Bool)
    }
    
    // 描述当前状态
    struct State {
        var query: String?
        var repos: [String] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .updateQuery(query):
                return Observable.concat([
                    // 1) set current state's query (.setQuery)
                    Observable.just(Mutation.setQuery(query)),
                    // 2) call API and set repos (.setRepos)
                    self.search(query: query, page: 1)
                        .take(until: self.action.filter(Action.isUpdateQueryAction))
                        .map({Mutation.setRepos($0, nextPage: $1)})
                ])
            case .loadNextPage:
                // prevent from multiple requests
                if self.currentState.isLoadingNextPage { return Observable.empty() }
                guard let page = self.currentState.nextPage else { return Observable.empty() }
                return Observable.concat([
                    // 1) set loading status to true
                    Observable.just(Mutation.setLoadingNextPage(true)),
                    // 2) call API and append repos
                    self.search(query: self.currentState.query, page: page)
                        .take(until: self.action.filter(Action.isUpdateQueryAction))
                        .map { Mutation.appendRepos($0, nextPage: $1) },
                    // 3) set loading status to false
                    Observable.just(Mutation.setLoadingNextPage(false)),
                ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
            case let .setQuery(query):
                var newState = state
                newState.query = query
                return newState
            case let .setRepos(repos, nextPage):
                var newState = state
                newState.repos = repos
                newState.nextPage = nextPage
                return newState
            case let .appendRepos(repos, nextPage):
                var newState = state
                newState.repos.append(contentsOf: repos)
                newState.nextPage = nextPage
                return newState
            case let .setLoadingNextPage(isLoadingNextPage):
                var newState = state
                newState.isLoadingNextPage = isLoadingNextPage
                return newState
        }
    }
}

fileprivate extension GitHubSearchViewReactor {
    func url(for query: String?, page: Int) -> URL? {
      guard let query = query, !query.isEmpty else { return nil }
      return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
    }
    
    func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
      let emptyResult: ([String], Int?) = ([], nil)
      guard let url = self.url(for: query, page: page) else { return .just(emptyResult) }
      return URLSession.shared.rx.json(url: url)
        .map { json -> ([String], Int?) in
          guard let dict = json as? [String: Any] else { return emptyResult }
          guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
          let repos = items.compactMap { $0["full_name"] as? String }
          let nextPage = repos.isEmpty ? nil : page + 1
          return (repos, nextPage)
        }
        .do(onError: { error in
          if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
            print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
          }
        })
        .catchAndReturn(emptyResult)
    }
}

extension GitHubSearchViewReactor.Action {
  static func isUpdateQueryAction(_ action: GitHubSearchViewReactor.Action) -> Bool {
    if case .updateQuery = action {
      return true
    } else {
      return false
    }
  }
}
