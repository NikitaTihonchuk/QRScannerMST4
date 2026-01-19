import Foundation

enum Localization {
    /// Main screen localization
    enum Main {
        static let helloWorld = NSLocalizedString("main.hello_world", value: "Hello, World!", comment: "Hello World greeting")
    }
    
    /// Home screen localization
    enum Home {
        // Header
        static let welcome = NSLocalizedString("home.welcome", value: "Welcome, User!", comment: "Welcome greeting")
        static let manageSubtitle = NSLocalizedString("home.manage_subtitle", value: "Manage your QR codes easily", comment: "Home screen subtitle")
        
        // Main buttons
        static let scanQR = NSLocalizedString("home.scan_qr", value: "Scan QR", comment: "Scan QR button")
        static let scanQRSubtitle = NSLocalizedString("home.scan_qr_subtitle", value: "Quick scan", comment: "Scan QR subtitle")
        
        static let createQR = NSLocalizedString("home.create_qr", value: "Create QR", comment: "Create QR button")
        static let createQRSubtitle = NSLocalizedString("home.create_qr_subtitle", value: "Generate new", comment: "Create QR subtitle")
        
        static let myQRCodes = NSLocalizedString("home.my_qr_codes", value: "My QR\nCodes", comment: "My QR Codes button")
        static let myQRCodesSubtitle = NSLocalizedString("home.my_qr_codes_subtitle", value: "Saved codes", comment: "My QR Codes subtitle")
        
        static let history = NSLocalizedString("home.history", value: "History", comment: "History button")
        static let historySubtitle = NSLocalizedString("home.history_subtitle", value: "Recent scans", comment: "History subtitle")
        
        // Recent Activity
        static let recentActivity = NSLocalizedString("home.recent_activity", value: "Recent Activity", comment: "Recent Activity section title")
        static let seeAll = NSLocalizedString("home.see_all", value: "See All", comment: "See All label title")
        static let scannedWebsite = NSLocalizedString("home.scanned_website", value: "Scanned website link", comment: "Scanned website activity")
        static let minutesAgo = NSLocalizedString("home.minutes_ago", value: "2 minutes ago", comment: "Time ago")
        
        static let noRecentActivity = NSLocalizedString("home.no_recent_activity", value: "No recent activity", comment: "No recent activity label")
        static let scanOrCreateQRCodesToSeeThemHere = NSLocalizedString("home.scan_or_create_QR_codes_to_see_them_here", value: "Scan or create QR codes to see them here", comment: "Scan or create QR codes to see them here text")
    }
    
    /// TabView localization
    enum TabView {
        static let home = NSLocalizedString("tabview.home", value: "Home", comment: "Home tab")
        static let scanQR = NSLocalizedString("tabview.scan_qr", value: "Scan QR", comment: "Scan QR tab")
        static let myQRCodes = NSLocalizedString("tabview.my_qr_codes", value: "My QR Codes", comment: "My QR Codes tab")
        static let history = NSLocalizedString("tabview.history", value: "History", comment: "History tab")
    }
    
    /// Onboarding screen localization
    enum Onboarding {
        // Screen 1
        static let welcome = NSLocalizedString("onboarding.welcome", value: "Welcome", comment: "Welcome title")
        static let welcomeSubtitle = NSLocalizedString("onboarding.welcome_subtitle", value: "Scan, Create & Manage\nQR Codes Easily", comment: "Welcome subtitle")
        
        // Screen 2
        static let scanTitle = NSLocalizedString("onboarding.scan_title", value: "Scan QR Codes", comment: "Scan title")
        static let scanSubtitle = NSLocalizedString("onboarding.scan_subtitle", value: "Quickly Scan Any QR Code", comment: "Scan subtitle")
        static let scanDescription = NSLocalizedString("onboarding.scan_description", value: "Align QR codes in frame and get instant\nresults", comment: "Scan description")
        
        // Screen 3
        static let createTitle = NSLocalizedString("onboarding.create_title", value: "Create QR Codes", comment: "Create title")
        static let createSubtitle = NSLocalizedString("onboarding.create_subtitle", value: "Generate QR Codes Instantly", comment: "Create subtitle")
        static let createDescription = NSLocalizedString("onboarding.create_description", value: "Enter URL, text, or contact info and get\nyour custom QR", comment: "Create description")
        
        // Screen 4
        static let manageTitle = NSLocalizedString("onboarding.manage_title", value: "Manage & Share", comment: "Manage title")
        static let manageSubtitle = NSLocalizedString("onboarding.manage_subtitle", value: "Save, Share, and Track All\nYour QR Codes", comment: "Manage subtitle")
        static let manageDescription = NSLocalizedString("onboarding.manage_description", value: "Access My QR Codes and History anytime", comment: "Manage description")
        
        // Buttons
        static let next = NSLocalizedString("onboarding.next", value: "Next", comment: "Next button")
        static let skip = NSLocalizedString("onboarding.skip", value: "Skip", comment: "Skip button")
        static let getStarted = NSLocalizedString("onboarding.get_started", value: "Get Started", comment: "Get Started button")
    }
    
    /// Scan Result screen localization
    enum ScanResult {
        static let title = NSLocalizedString("scan_result.title", value: "Scan Result", comment: "Scan Result title")
        static let scanSuccessful = NSLocalizedString("scan_result.scan_successful", value: "Scan Successful", comment: "Scan successful message")
        static let qrCodeDecodedSuccessfully = NSLocalizedString("scan_result.qr_code_decoded_successfully", value: "QR code decoded successfully", comment: "QR decoded message")
        static let fullContent = NSLocalizedString("scan_result.full_content", value: "Full Content", comment: "Full content label")
        static let scanned = NSLocalizedString("scan_result.scanned", value: "Scanned", comment: "Scanned label")
        static let type = NSLocalizedString("scan_result.type", value: "Type", comment: "Type label")
        static let url = NSLocalizedString("scan_result.url", value: "URL", comment: "URL type")
        static let openLink = NSLocalizedString("scan_result.open_link", value: "Open Link", comment: "Open link button")
        static let copy = NSLocalizedString("scan_result.copy", value: "Copy", comment: "Copy button")
        static let share = NSLocalizedString("scan_result.share", value: "Share", comment: "Share button")
        static let save = NSLocalizedString("scan_result.save", value: "Save", comment: "Save button")
        static let saved = NSLocalizedString("scan_result.saved", value: "Saved", comment: "Saved button")
        static let copiedToClipboard = NSLocalizedString("scan_result.copied_to_clipboard", value: "Copied to clipboard", comment: "Copied notification")
        static let savedToHistory = NSLocalizedString("scan_result.saved_to_history", value: "Saved to history", comment: "Saved notification")
    }
    
    /// Create QR screen localization
    enum CreateQR {
        static let title = NSLocalizedString("create_qr.title", value: "Create QR Code", comment: "Create QR title")
        static let contentType = NSLocalizedString("create_qr.content_type", value: "Content Type", comment: "Content type label")
        static let url = NSLocalizedString("create_qr.url", value: "URL", comment: "URL type")
        static let text = NSLocalizedString("create_qr.text", value: "Text", comment: "Text type")
        static let contact = NSLocalizedString("create_qr.contact", value: "Contact", comment: "Contact type")
        static let wifi = NSLocalizedString("create_qr.wifi", value: "Wi-Fi", comment: "Wi-Fi type")
        
        // Input fields
        static let qrCodeName = NSLocalizedString("create_qr.qr_code_name", value: "QR Code Name", comment: "QR code name label")
        static let qrCodeNamePlaceholder = NSLocalizedString("create_qr.qr_code_name_placeholder", value: "Enter a name for this QR code", comment: "QR code name placeholder")
        static let websiteURL = NSLocalizedString("create_qr.website_url", value: "Website URL", comment: "Website URL label")
        static let websiteURLPlaceholder = NSLocalizedString("create_qr.website_url_placeholder", value: "https://example.com", comment: "Website URL placeholder")
        static let textContent = NSLocalizedString("create_qr.text_content", value: "Text Content", comment: "Text content label")
        static let textContentPlaceholder = NSLocalizedString("create_qr.text_content_placeholder", value: "Enter your text here...", comment: "Text content placeholder")
        static let name = NSLocalizedString("create_qr.name", value: "Name", comment: "Name label")
        static let namePlaceholder = NSLocalizedString("create_qr.name_placeholder", value: "John Doe", comment: "Name placeholder")
        static let phone = NSLocalizedString("create_qr.phone", value: "Phone", comment: "Phone label")
        static let phonePlaceholder = NSLocalizedString("create_qr.phone_placeholder", value: "+1234567890", comment: "Phone placeholder")
        static let networkName = NSLocalizedString("create_qr.network_name", value: "Network Name (SSID)", comment: "Network name label")
        static let networkNamePlaceholder = NSLocalizedString("create_qr.network_name_placeholder", value: "My WiFi", comment: "Network name placeholder")
        static let password = NSLocalizedString("create_qr.password", value: "Password", comment: "Password label")
        static let passwordPlaceholder = NSLocalizedString("create_qr.password_placeholder", value: "Password", comment: "Password placeholder")
        
        // Design options
        static let designOptions = NSLocalizedString("create_qr.design_options", value: "Design Options", comment: "Design options label")
        static let color = NSLocalizedString("create_qr.color", value: "Color", comment: "Color label")
        static let addLogo = NSLocalizedString("create_qr.add_logo", value: "+ Add Logo", comment: "Add logo button")
        static let generateButton = NSLocalizedString("create_qr.generate_button", value: "Generate QR Code", comment: "Generate button")
        
        // Success screen
        static let qrCodeReady = NSLocalizedString("create_qr.qr_code_ready", value: "The QR code is ready", comment: "QR code ready message")
        static let shareButton = NSLocalizedString("create_qr.share_button", value: "Share", comment: "Share button")
        static let saveButton = NSLocalizedString("create_qr.save_button", value: "Save", comment: "Save button")
        static let savedButton = NSLocalizedString("create_qr.saved_button", value: "Saved", comment: "Saved button")
    }
    
    /// My QR Codes screen localization
    enum MyQRCodes {
        static let title = NSLocalizedString("my_qr_codes.title", value: "My QR Codes", comment: "My QR Codes title")
        static let searchPlaceholder = NSLocalizedString("my_qr_codes.search_placeholder", value: "Search QR codes...", comment: "Search placeholder")
        static let cancel = NSLocalizedString("my_qr_codes.cancel", value: "Cancel", comment: "Cancel button")
        static let filterAll = NSLocalizedString("my_qr_codes.filter_all", value: "All", comment: "All filter")
        static let filterURL = NSLocalizedString("my_qr_codes.filter_url", value: "URL", comment: "URL filter")
        static let filterText = NSLocalizedString("my_qr_codes.filter_text", value: "Text", comment: "Text filter")
        static let filterWiFi = NSLocalizedString("my_qr_codes.filter_wifi", value: "WiFi", comment: "WiFi filter")
        static let filterContact = NSLocalizedString("my_qr_codes.filter_contact", value: "Contact", comment: "Contact filter")
        
        // Empty state
        static let emptyTitle = NSLocalizedString("my_qr_codes.empty_title", value: "No Created QR Codes", comment: "Empty state title")
        static let emptySubtitle = NSLocalizedString("my_qr_codes.empty_subtitle", value: "Create QR codes and save them here\nfor quick access later", comment: "Empty state subtitle")
        
        // No results
        static let noResultsTitle = NSLocalizedString("my_qr_codes.no_results_title", value: "No Results Found", comment: "No results title")
        static let noResultsSubtitle = NSLocalizedString("my_qr_codes.no_results_subtitle", value: "Try searching with different keywords", comment: "No results subtitle")
        
        // Action menu
        static let shareAll = NSLocalizedString("my_qr_codes.share_all", value: "Share All", comment: "Share all button")
        static let edit = NSLocalizedString("my_qr_codes.edit", value: "Edit", comment: "Edit button")
        static let delete = NSLocalizedString("my_qr_codes.delete", value: "Delete", comment: "Delete button")
        
        // Delete alert
        static let clearAllAlertTitle = NSLocalizedString("my_qr_codes.clear_all_alert_title", value: "Clear All QR Codes", comment: "Clear all alert title")
        static let clearAllAlertMessage = NSLocalizedString("my_qr_codes.clear_all_alert_message", value: "Are you sure you want to delete all created QR codes? This action cannot be undone.", comment: "Clear all alert message")
        static let clearAllButton = NSLocalizedString("my_qr_codes.clear_all_button", value: "Clear All", comment: "Clear all button")
        static let cancelButton = NSLocalizedString("my_qr_codes.cancel_button", value: "Cancel", comment: "Cancel button")
    }
    
    /// My QR Code Detail screen localization
    enum QRDetail {
        static let title = NSLocalizedString("qr_detail.title", value: "QR Code Details", comment: "QR detail title")
        static let done = NSLocalizedString("qr_detail.done", value: "Done", comment: "Done button")
        static let adjustBrightness = NSLocalizedString("qr_detail.adjust_brightness", value: "Adjust brightness for better scanning", comment: "Adjust brightness hint")
        static let name = NSLocalizedString("qr_detail.name", value: "Name", comment: "Name label")
        static let type = NSLocalizedString("qr_detail.type", value: "Type", comment: "Type label")
        static let content = NSLocalizedString("qr_detail.content", value: "Content", comment: "Content label")
        static let created = NSLocalizedString("qr_detail.created", value: "Created", comment: "Created label")
        static let copyContent = NSLocalizedString("qr_detail.copy_content", value: "Copy Content", comment: "Copy content button")
        static let exportQR = NSLocalizedString("qr_detail.export_qr", value: "Export QR Code", comment: "Export QR button")
        static let delete = NSLocalizedString("qr_detail.delete", value: "Delete", comment: "Delete button")
        static let deleteAlertTitle = NSLocalizedString("qr_detail.delete_alert_title", value: "Delete QR Code", comment: "Delete alert title")
        static let deleteAlertMessage = NSLocalizedString("qr_detail.delete_alert_message", value: "Are you sure you want to delete this QR code?", comment: "Delete alert message")
    }
    
    /// History screen localization
    enum History {
        static let title = NSLocalizedString("history.title", value: "History", comment: "History title")
        static let filterAll = NSLocalizedString("history.filter_all", value: "All", comment: "All filter")
        static let filterScanned = NSLocalizedString("history.filter_scanned", value: "Scanned", comment: "Scanned filter")
        static let filterCreated = NSLocalizedString("history.filter_created", value: "Created", comment: "Created filter")
        
        // Sort options
        static let sortNewestFirst = NSLocalizedString("history.sort_newest_first", value: "Newest First", comment: "Newest first sort")
        static let sortOldestFirst = NSLocalizedString("history.sort_oldest_first", value: "Oldest First", comment: "Oldest first sort")
        static let sortBy = NSLocalizedString("history.sort_by", value: "Sort by", comment: "Sort by label")
        static let cancel = NSLocalizedString("history.cancel", value: "Cancel", comment: "Cancel button")
        
        // Empty state
        static let emptyTitle = NSLocalizedString("history.empty_title", value: "No History Yet", comment: "Empty history title")
        static let emptySubtitle = NSLocalizedString("history.empty_subtitle", value: "Your scanned and created QR codes\nwill appear here", comment: "Empty history subtitle")
        
        // Date sections
        static let today = NSLocalizedString("history.today", value: "Today", comment: "Today section")
        static let yesterday = NSLocalizedString("history.yesterday", value: "Yesterday", comment: "Yesterday section")
        
        // Action types
        static let scanned = NSLocalizedString("history.scanned", value: "Scanned", comment: "Scanned action")
        static let created = NSLocalizedString("history.created", value: "Created", comment: "Created action")
    }
    
    /// History Detail screen localization
    enum HistoryDetail {
        static let title = NSLocalizedString("history_detail.title", value: "History Details", comment: "History detail title")
        static let done = NSLocalizedString("history_detail.done", value: "Done", comment: "Done button")
        static let titleField = NSLocalizedString("history_detail.title_field", value: "Title", comment: "Title field")
        static let typeField = NSLocalizedString("history_detail.type_field", value: "Type", comment: "Type field")
        static let contentField = NSLocalizedString("history_detail.content_field", value: "Content", comment: "Content field")
        static let actionField = NSLocalizedString("history_detail.action_field", value: "Action", comment: "Action field")
        static let dateField = NSLocalizedString("history_detail.date_field", value: "Date", comment: "Date field")
        static let copyContent = NSLocalizedString("history_detail.copy_content", value: "Copy Content", comment: "Copy content button")
        static let share = NSLocalizedString("history_detail.share", value: "Share", comment: "Share button")
        static let delete = NSLocalizedString("history_detail.delete", value: "Delete", comment: "Delete button")
    }
    
    /// QR Content Types localization
    enum QRType {
        static let url = NSLocalizedString("qr_type.url", value: "Website", comment: "URL type")
        static let text = NSLocalizedString("qr_type.text", value: "Text", comment: "Text type")
        static let contact = NSLocalizedString("qr_type.contact", value: "Contact", comment: "Contact type")
        static let wifi = NSLocalizedString("qr_type.wifi", value: "Wi-Fi", comment: "Wi-Fi type")
        static let email = NSLocalizedString("qr_type.email", value: "Email", comment: "Email type")
        static let phone = NSLocalizedString("qr_type.phone", value: "Phone", comment: "Phone type")
        static let sms = NSLocalizedString("qr_type.sms", value: "SMS", comment: "SMS type")
        static let unknown = NSLocalizedString("qr_type.unknown", value: "Unknown", comment: "Unknown type")
    }
    
    /// Common strings localization
    enum Common {
        static let close = NSLocalizedString("common.close", value: "Close", comment: "Close button")
        static let done = NSLocalizedString("common.done", value: "Done", comment: "Done button")
        static let cancel = NSLocalizedString("common.cancel", value: "Cancel", comment: "Cancel button")
        static let delete = NSLocalizedString("common.delete", value: "Delete", comment: "Delete button")
        static let save = NSLocalizedString("common.save", value: "Save", comment: "Save button")
        static let share = NSLocalizedString("common.share", value: "Share", comment: "Share button")
        static let copy = NSLocalizedString("common.copy", value: "Copy", comment: "Copy button")
        static let edit = NSLocalizedString("common.edit", value: "Edit", comment: "Edit button")
        static let ok = NSLocalizedString("common.ok", value: "OK", comment: "OK button")
        static let yes = NSLocalizedString("common.yes", value: "Yes", comment: "Yes button")
        static let no = NSLocalizedString("common.no", value: "No", comment: "No button")
    }
    
    /// Paywall screen localization
    enum Paywall {
        static let restore = NSLocalizedString("paywall.restore", value: "Restore", comment: "Restore button")
        static let title = NSLocalizedString("paywall.title", value: "Unlock Full QR\nTools", comment: "Paywall title")
        static let subtitle = NSLocalizedString("paywall.subtitle", value: "Unlimited scans, custom QR creation, and full\nhistory access.", comment: "Paywall subtitle")
        
        // Features
        static let unlimitedQRScans = NSLocalizedString("paywall.unlimited_qr_scans", value: "Unlimited QR Scans", comment: "Unlimited QR Scans feature")
        static let unlimitedQRScansDesc = NSLocalizedString("paywall.unlimited_qr_scans_desc", value: "Scan as many QR codes as you want", comment: "Unlimited QR Scans description")
        
        static let createAllQRTypes = NSLocalizedString("paywall.create_all_qr_types", value: "Create All QR Types", comment: "Create All QR Types feature")
        static let createAllQRTypesDesc = NSLocalizedString("paywall.create_all_qr_types_desc", value: "URL, Text, Contact, WiFi, and more", comment: "Create All QR Types description")
        
        static let noAds = NSLocalizedString("paywall.no_ads", value: "No Ads", comment: "No Ads feature")
        static let noAdsDesc = NSLocalizedString("paywall.no_ads_desc", value: "Clean, distraction-free experience", comment: "No Ads description")
        
        static let cloudBackup = NSLocalizedString("paywall.cloud_backup", value: "Cloud Backup", comment: "Cloud Backup feature")
        static let cloudBackupDesc = NSLocalizedString("paywall.cloud_backup_desc", value: "Sync across all your devices", comment: "Cloud Backup description")
        
        static let advancedAnalytics = NSLocalizedString("paywall.advanced_analytics", value: "Advanced Analytics", comment: "Advanced Analytics feature")
        static let advancedAnalyticsDesc = NSLocalizedString("paywall.advanced_analytics_desc", value: "Track scans and usage patterns", comment: "Advanced Analytics description")
        
        // Plans
        static let weeklyPlan = NSLocalizedString("paywall.weekly_plan", value: "Weekly Plan", comment: "Weekly Plan")
        static let monthlyPlan = NSLocalizedString("paywall.monthly_plan", value: "Monthly Plan", comment: "Monthly Plan")
        static let yearlyPlan = NSLocalizedString("paywall.yearly_plan", value: "Yearly Plan", comment: "Yearly Plan")
        
        static let perWeek = NSLocalizedString("paywall.per_week", value: "/ week", comment: "per week")
        static let perMonth = NSLocalizedString("paywall.per_month", value: "/ month", comment: "per month")
        static let perYear = NSLocalizedString("paywall.per_year", value: "/ year", comment: "per year")
        
        static let freeTrialDays = NSLocalizedString("paywall.free_trial_days", value: "3-day free trial", comment: "3-day free trial")
        static let cancelAnytime = NSLocalizedString("paywall.cancel_anytime", value: "Cancel anytime", comment: "Cancel anytime")
        static let bestValueOption = NSLocalizedString("paywall.best_value_option", value: "Best value option", comment: "Best value option")
        
        static let mostPopular = NSLocalizedString("paywall.most_popular", value: "MOST POPULAR", comment: "Most popular badge")
        static let savePercent = NSLocalizedString("paywall.save_percent", value: "SAVE 70%", comment: "Save percent badge")
        static let saveAmount = NSLocalizedString("paywall.save_amount", value: "Save $70", comment: "Save amount")
        
        // Button and footer
        static let continueButton = NSLocalizedString("paywall.continue", value: "Continue", comment: "Continue button")
        static let autoRenewable = NSLocalizedString("paywall.auto_renewable", value: "Auto-renewable. Cancel anytime.", comment: "Auto-renewable text")
        static let termsOfService = NSLocalizedString("paywall.terms_of_service", value: "Terms of Service", comment: "Terms of Service")
        static let privacyPolicy = NSLocalizedString("paywall.privacy_policy", value: "Privacy Policy", comment: "Privacy Policy")
    }
}
