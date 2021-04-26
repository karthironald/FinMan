//
//  FMIncomeRepository.swift
//  FinMan
//
//  Created by Karthick Selvaraj on 26/04/21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FMIncomeRepository: ObservableObject {
    
    private let path: String = "Income"
    private let store = Firestore.firestore()

    var userId = ""
    private let authenticationService = AuthenticationService()
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var cards: [Card] = []
    
    init() {
      // 1
      authenticationService.$user
        .compactMap { user in
          user?.uid
        }
        .assign(to: \.userId, on: self)
        .store(in: &cancellables)

      // 2
      authenticationService.$user
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
          // 3
          self?.getCards()
        }
        .store(in: &cancellables)
    }


    func add(_ card: Card) {
      do {
        var newCard = card
        newCard.userId = userId
        _ = try store.collection(path).addDocument(from: newCard)
      } catch {
        fatalError("Unable to add card: \(error.localizedDescription).")
      }
    }

    func getCards() {
      store.collection(path)
        .whereField("userId", isEqualTo: userId)
        .addSnapshotListener { (querySnapshot, error) in
        if let error = error {
          print(error.localizedDescription)
          return
        }
        self.cards = querySnapshot?.documents.compactMap({ document in
          try? document.data(as: Card.self)
        }) ?? []
      }
    }
    
    func update(card: Card) {
      guard let id = card.id else { return }
      do {
        try store.collection(path).document(id).setData(from: card)
      } catch {
        print("Unable to update card")
      }
    }
    
    func delete(card: Card) {
      guard let id = card.id else { return }
      store.collection(path).document(id).delete(completion: { (error) in
        if let error = error {
          print(error.localizedDescription)
        }
      })
    }
    
}
