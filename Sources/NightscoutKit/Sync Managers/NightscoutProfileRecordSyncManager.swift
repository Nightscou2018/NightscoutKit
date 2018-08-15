//
//  NightscoutProfileRecordSyncManager.swift
//  NightscoutKit
//
//  Created by Michael Pangburn on 8/14/18.
//  Copyright © 2018 Michael Pangburn. All rights reserved.
//

internal final class NightscoutProfileRecordSyncManager: _NightscoutObserver, SyncManager {
    typealias Object = NightscoutProfileRecord

    var _recentlyUploaded: ThreadSafe<SortedArray<OperationCompletion<NightscoutProfileRecord>>> = ThreadSafe(SortedArray(areInIncreasingOrder: NightscoutProfileRecordSyncManager.mostRecentObjectsFirst))
    var _recentlyUpdated: ThreadSafe<SortedArray<OperationCompletion<NightscoutProfileRecord>>> = ThreadSafe(SortedArray(areInIncreasingOrder: NightscoutProfileRecordSyncManager.mostRecentObjectsFirst))
    var _recentlyDeleted: ThreadSafe<SortedArray<OperationCompletion<NightscoutProfileRecord>>> = ThreadSafe(SortedArray(areInIncreasingOrder: NightscoutProfileRecordSyncManager.mostRecentObjectsFirst))

    override func downloader(_ downloader: NightscoutDownloader, didFetchProfileRecords records: [NightscoutProfileRecord]) {
        updateWithFetchedObjects(records)
    }

    override func uploader(_ uploader: NightscoutUploader, didUploadProfileRecords records: Set<NightscoutProfileRecord>) {
        updateWithUploadedObjects(records)
    }

    override func uploader(_ uploader: NightscoutUploader, didUpdateProfileRecords records: Set<NightscoutProfileRecord>) {
        updateWithUpdatedObjects(records)
    }

    override func uploader(_ uploader: NightscoutUploader, didDeleteProfileRecords records: Set<NightscoutProfileRecord>) {
        updateWithDeletedObjects(records)
    }
}