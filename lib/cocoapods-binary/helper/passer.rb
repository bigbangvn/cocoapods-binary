require_relative '../tool/tool'
require 'set'

module Pod
    class Prebuild

        # Pass the data between the 2 steps
        #
        # At step 2, the normal pod install, it needs some info of the
        # prebuilt step. So we store it here.
        #
        class Passer

            # indicate the add/remove/update of prebuit pods
            # @return [Analyzer::SpecsState]
            #
            class_attr_accessor :prebuild_pods_changes


            # represent the path of resurces to copy
            class ResourcePath
                attr_accessor :real_file_path
                attr_accessor :target_file_path
            end
            # Save the resoures for static framework, and used when installing the prebuild framework
            # static framework needs copy the resurces mannully
            #
            # @return [Hash<String, [Passer::ResourcePath]>]
            class_attr_accessor :resources_to_copy_for_static_framework
            self.resources_to_copy_for_static_framework = {}

            # Some pod won't be build in prebuild stage even if it have `binary=>true`.
            # The targets of this pods have `oshould_build? == true`.
            # We should skip integration (patch spec) for this pods
            #
            # @return [Array<String>]
            class_attr_accessor :target_names_to_skip_integration_framework
            self.target_names_to_skip_integration_framework = []

        end

        class DaxIOSWorkaround

            class_attr_accessor :localResourcesTargets
            self.localResourcesTargets = [
                'CommonResources',
                'DriverExperienceResources',
                'FoodResources',
                'ExpressResources',
                'TransportResources',
                'PaymentResources',
                'EconResources',
                'LendingResources',
                'GeoResources'
            ]

            class_attr_accessor :issueTargets
            self.issueTargets = ['Crashlytics', 'Fabric']

            # We don't build some pod libs because of issue or they are too small
            # HMSegmentedControl not used -> remove. But still need them here, because they're dependencies of other prebuild target. Otherwise, pod install will not include them -> prebuild fail
            class_attr_accessor :podsBlackList
            self.podsBlackList = ['UIColor_Hex_Swift', 'SwiftyUserDefaults', 'SwiftLint', 'Sourcery', 'ReachabilitySwift', 'objc-geohash', 'NSLogger', 'NearbyMessages', 'MSREventBridge', 'GzipSwift', 'GrabIcon-IOS', 'GoogleToolboxForMac',
            'Firebase', 'DRDPluginResources', 'Cuckoo', 'CTCheckbox', 'Crashlytics', 'BKMoneyKit', 'VoipKit',
            'HydraSwift', # It's prebuilt lib, but was accidentally included when dev pod binary is enabled
             #'Stubber', # Problem with UI tests
             #'MGActionLiveness' # It includes static lib -> cause duplicate
             'LoginModule' # It's static now -> empbeded in main target -> can't gather codecoverage because wrong symbol path
            ]

            class_attr_accessor :devpodWhiteList
            self.devpodWhiteList = Set[
                'ExpressModule',
                'JobFlowData',

                'ABTestingData',
                'ABTestingService',
                'AdvanceJobModule',
                'AnalyticsService',
                'AnalyticsTracker',
                'AutoAcceptService',
                'AvailabilityService',
                'BaseKIFTest',
                'BaseModule',
                'ChatService',
                'DaxHistoryModule',
                'DaxHistoryService',
                'DaxRatePaxModule',
                'DaxReferDaxModule',
                'DaxReferDaxService',
                'DaxReferDaxTracker',
                'DaxSecurity',
                'DaxTippingService',
                'DeliveriesCommon',
                'DevicesService',
                'DiagnosticTools',
                'DiscoveryHub',
                'DriverBaseModule',
                'DriverChoiceModule',
                'DriverChoiceService',
                'DriverCoreData',
                'DriverCoreService',
                'DriverQualityService',
                'DriverSafety',
                'DriverSafetyService',

                'DriverService',
                'DriverTestsCommon',
                'DriverTestsMock',
                'EarningsModule',
                'ExperimentService',
                'ExpressModule',
                'FaceAuthenticationModule',
                'FaceAuthenticationService',
                'FakeDependencies',
                'FavLocationSearchModule',
                'FavLocationService',
                'FeedbackService',
                'FoodModule',
                'FoundationCommons',
                'GenericDataSource',
                'GrabLogger',
                'GrabNowModule',
                'GrabnowService',
                'HeatmapModule',
                'HeatMapService',
                'HedwigInAppMessagingService',
                'HedwigInboxService',
                'HedwigNotificationService',
                'InboxModule',
                'IncentivesModule',
                'IncentivesService',
                'InsuranceModule',
                'InsuranceService',
                'InTransitFlowModule',
                'JobCardModule',
                'JobCardUICommons',
                'JobFlowData',
                'JobFlowService',
                'JsonTools',
                'Lending',
                'LendingService',
                'LivenessDetection',
                'LocationService',
                'LoginModule',
                'MapModule',
                'MGActionLiveness',
                'MGActionLivenessUI',
                'MGBaseKit',
                'MGFaceIDLicense',
                'MLeaksFinder',
                'MultiVehiclesModule',
                'NetworkUtil',
                'NotificationsService',
                'PartnerBenefitsModule',
                'PartnerBenefitsService',
                'PartnerBenefitsV2',
                'PartnerBenefitsV2Service',
                'PaymentService',
                'PDRMModule',
                'PhoneContactsModule',
                'PhoneNumberKit',
                'PluginKit',
                'ProfileService',
                'ProfileSettingsModule',
                'QuickDrawerModule',
                'RxCocoaExtensions',
                'SafetyTripMonitoring',
                'SnapshotTestToolModule',
                'Stubber',
                'SupportModule',
                'SuspensionExpModule',
                'TestExtensions',
                'TestToolModule',
                'TopUpPaxModule',
                'TopUpPaxService',
                'TransitCommonsModule',
                'TransportModule',
                'TZStackView',
                'UICommons',
                'UserSettingsModule',
                'VehicleTypesData',
                'VehicleTypesService',
                'VoIPModule',
                'WalletModule',
                'WebSandboxModule'
            ]
        end
    end
end