//
//  RepositoryProtocol.swift
//  SmartEducation
//
//  Created by MacBook on 12/16/20.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

protocol RepositoryProtocol {
    func itemsCount<ItemType: BaseEntity>(_ type: ItemType.Type) -> Int
    func setCollectionChangedObserver<ItemType: BaseEntity>(_ type: ItemType.Type, _ block: @escaping () -> Void)
    func get<Entity: BaseEntity>(_ type: Entity.Type) -> Single<Results<Entity>?>
    func add<Entity: BaseEntity>(item: Entity) -> Completable
    func update<Entity: BaseEntity>(item: Entity, updateBlock: @escaping (Entity) -> Void) -> Completable
    func delete<Entity: BaseEntity>(item: Entity) -> Single<String>
}
