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
    func merge<Entity: BaseEntity>(items: [Entity]) -> Completable
    func get<Entity: BaseEntity>(_ type: Entity.Type) -> Single<[Entity]>
    func get<Entity: BaseEntity>(_ pageIndex: Int, _ pageSize: Int, sortBy: String, asc: Bool) -> Single<[Entity]>
    func add<Entity: BaseEntity>(item: Entity) -> Completable
    func add<Entity: BaseEntity>(items: [Entity]) -> Completable
    func update<Entity: BaseEntity>(item: Entity, updateBlock: @escaping (Entity) -> Void) -> Completable
    func delete<Entity: BaseEntity>(item: Entity) -> Single<String>
    func updateAll<Entity: BaseEntity>(_ newItems: [Entity]) -> Completable
}
