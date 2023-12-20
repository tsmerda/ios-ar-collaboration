//
//  Localization.swift
//  MetaCollaboration
//
//  Created by Tomáš Šmerda on 18.12.2023.
//

import Foundation

typealias L = LocalizedString

extension String {
    var tr: String { tr() }
    
    func tr(withComment comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}

enum LocalizedString {
    enum Generic {
        static let unknown = "generic_unknown";
    }
    
    enum Error {
        static let invalidURL = "error_invalid_url";
        static let serverError = "error_server_error";
        static let invalidData = "error_invalid_data";
    }
    
    enum ChooseMode {
        static let title = "choose_mode_title".tr
        static let info = "choose_mode_info".tr
        static let button = "choose_mode_button".tr
        static let online = "choose_mode_online".tr
        static let offline = "choose_mode_offline".tr
        static let notImplemented = "choose_mode_not_implemented".tr
    }
    
    enum GuideList {
        static let title = "guide_list_title".tr
        static let noDatasets = "guide_list_no_datasets".tr
        static let allAssetsSaved = "guide_list_all_assets_saved".tr
        static let failedToDelete = "guide_list_failed_to_delete".tr
    }
    
    enum GuideDetail {
        static let completed = "guide_detail_completed".tr
        static let alreadyDownloaded = "guide_detail_already_downloaded".tr
        static let notDownloaded = "guide_detail_not_downloaded".tr
        static let download = "guide_detail_download".tr
        static let begin = "guide_detail_begin".tr
    }
    
    enum StepList {
        static let title = "step_list_title".tr
        static let selected = "step_list_selected".tr
        static let buttonsLabel = "step_list_buttons_label".tr
        static let buttonPrevious = "step_list_button_previous".tr
        static let buttonContinue = "step_list_button_continue".tr
        static let exit = "step_list_exit".tr
    }
    
    enum StepDetail {
        static let instructions = "step_detail_instructions".tr
        static let step = "step_detail_step".tr
        static let tasks = "step_detail_tasks".tr
        static let preview = "step_detail_preview".tr
        static let confirm = "step_detail_confirm".tr
    }
    
    enum Confirmation {
        static let title = "confirmation_title".tr
        static let rating = "confirmation_rating".tr
        static let comment = "confirmation_comment".tr
        static let commentPlaceholder = "confirmation_comment_placeholder".tr
        static let image = "confirmation_image".tr
        static let uploadImage = "confirmation_upload_image".tr
        static let cancel = "confirmation_cancel".tr
        static let confirm = "confirmation_confirm".tr
        static let missingIDs = "confirmation_missing_ids".tr
        static let confirmed = "confirmation_confirmed".tr
    }
    
    enum Settings {
        static let title = "settings_title".tr
        static let appName = "settings_app_name".tr
        static let description = "settings_description".tr
        static let author = "settings_author".tr
        static let linkedin = "settings_linkedin".tr
        static let app = "settings_app".tr
        static let compatibility = "settings_compatibility".tr
        static let swiftui = "settings_swiftui".tr
        static let website = "settings_website".tr
        static let version = "settings_version".tr
        static let customization = "settings_customization".tr
        static let onlineMode = "settings_online_mode".tr
        static let offlineMode = "settings_offline_mode".tr
        static let removeText = "settings_remove_text".tr
        static let removeButton = "settings_remove_text".tr
    }
    
    enum Final {
        static let title = "final_title".tr
        static let text = "final_text".tr
        static let button = "final_button".tr
    }
    
    enum Stars {
        static let one = "stars_one".tr
        static let twoToFour = "stars_two_to_four".tr
        static let fourAndMore = "stars_four_and_more".tr
    }
}
