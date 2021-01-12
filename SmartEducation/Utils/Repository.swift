//
//  Repository.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

class Repository: RepositoryProtocol {
    private let realm: Realm
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        do {
            realm = try Realm()
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
    
    func itemsCount<ItemType: BaseEntity>(_ type: ItemType.Type) -> Int {
        return (try? Realm())?.objects(ItemType.self).count ?? 0
    }
    
    func setCollectionChangedObserver<ItemType: BaseEntity>(_ type: ItemType.Type, _ block: @escaping () -> Void) {
        let token = realm.objects(ItemType.self).observe { _ in
            block()
        }
        notificationTokens.append(token)
    }
    
    func get<Entity: BaseEntity>(_ type: Entity.Type) -> Single<Results<Entity>?> {
        return Single.create { single in
            DispatchQueue.global().async {
                let realm = try? Realm()
                let objects = realm?.objects(Entity.self)
                sleep(2)
                single(.success(objects))
            }
            
            return Disposables.create()
        }
    }
    
    func add<Entity: BaseEntity>(item: Entity) -> Completable {
        return Completable.create { [weak self] completable in
            self?.realm.writeAsync( { realm in
                realm.add(item)
            }, { completable(.completed) })

            return Disposables.create()
        }
    }
    
    func update<Entity: BaseEntity>(item: Entity, updateBlock: @escaping (Entity) -> Void) -> Completable {
        return Completable.create { [weak self] completable in
            let predicate = NSPredicate(format: "id == %@", item.id)
            self?.realm.writeAsync( { realm in
                if let entityToUpdate = realm.objects(Entity.self).filter(predicate).first {
                    updateBlock(entityToUpdate)
                }
            }, { completable(.completed) })
            
            return Disposables.create()
        }
    }
    
    func delete<Entity: BaseEntity>(item: Entity) -> Single<String> {
        return Single.create { [weak self] single in
            self?.realm.writeAsync( { realm in
                let predicate = NSPredicate(format: "id == %@", item.id)
                if let entityToDelete = realm.objects(Entity.self).filter(predicate).first {
                    realm.delete(entityToDelete)
                }
            }, { single(.success(item.id)) })
            
            return Disposables.create()
        }
    }
}
