module Pod

    class Prebuild
        def self.keyword
            :binary
        end
    end

    class Podfile
      class TargetDefinition

        ## --- option for setting using prebuild framework ---
        def parse_prebuild_framework(name, requirements)
            should_prebuild = Pod::Podfile::DSL.prebuild_all

            options = requirements.last
            if options.is_a?(Hash) && options[Pod::Prebuild.keyword] != nil
                should_prebuild = options.delete(Pod::Prebuild.keyword)
                requirements.pop if options.empty?
            end

            pod_name = Specification.root_name(name)
            set_prebuild_for_pod(pod_name, should_prebuild)
        end

        def set_prebuild_for_pod(pod_name, should_prebuild)

            if should_prebuild == true
                @prebuild_framework_pod_names ||= []
                @prebuild_framework_pod_names.push pod_name
            else
                @should_not_prebuild_framework_pod_names ||= []
                @should_not_prebuild_framework_pod_names.push pod_name
            end
        end

        def prebuild_framework_pod_names
            names = @prebuild_framework_pod_names || []
            if parent != nil and parent.kind_of? TargetDefinition
                names += parent.prebuild_framework_pod_names
            end
            names
        end
        def should_not_prebuild_framework_pod_names
            []
            # names = @should_not_prebuild_framework_pod_names || []
            # if parent != nil and parent.kind_of? TargetDefinition
            #     names += parent.should_not_prebuild_framework_pod_names
            # end
            # names
        end

        # ---- patch method ----
        # We want modify `store_pod` method, but it's hard to insert a line in the
        # implementation. So we patch a method called in `store_pod`.
        old_method = instance_method(:parse_inhibit_warnings)

        define_method(:parse_inhibit_warnings) do |name, requirements|
          parse_prebuild_framework(name, requirements)
          old_method.bind(self).(name, requirements)
        end

      end
    end
end


module Pod
    class Installer

        def prebuild_pod_targets
            @prebuild_pod_targets ||= (
            all = []

            aggregate_targets = self.aggregate_targets
            aggregate_targets.each do |aggregate_target|
                target_definition = aggregate_target.target_definition
                targets = aggregate_target.pod_targets || []

                # filter prebuild
                prebuild_names = target_definition.prebuild_framework_pod_names
                if not Podfile::DSL.prebuild_all
                    targets = targets.select { |pod_target| prebuild_names.include?(pod_target.pod_name) }
                end

                # Bangnt: Auto include dependencies - should we disable it?
                dependency_targets = targets.map {|t| t.recursive_dependent_targets }.flatten.uniq || []
                targets = (targets + dependency_targets).uniq

                # filter should not prebuild
                explict_should_not_names = target_definition.should_not_prebuild_framework_pod_names
                puts "explict_should_not_names: #{explict_should_not_names}"
                targets = targets.reject { |pod_target| explict_should_not_names.include?(pod_target.pod_name) }

                all += targets
            end
            #puts "alls before reject: #{all}"
            #all = all.reject {|pod_target| sandbox.local?(pod_target.pod_name) } # testing build dev pod only
            puts "after filtering: #{all}"

            dev_pods = all.map(&:pod_name).reject { |name| !sandbox.local?(name) }
            puts "All dev pods: #{dev_pods}"

            all.uniq
            )
        end

        # the root names who needs prebuild, including dependency pods.
        def prebuild_pod_names

            localResourcesTargets = [
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
            issueTargets = ['Crashlytics', 'Fabric']

            # We don't build some pod libs because of issue or they are too small
            # HMSegmentedControl not used -> remove
            podsBlackList = ['UIColor_Hex_Swift', 'SwiftyUserDefaults', 'SwiftLint', 'Sourcery', 'ReachabilitySwift', 'objc-geohash', 'NSLogger', 'NearbyMessages', 'MSREventBridge', 'GzipSwift', 'GrabIcon-IOS', 'GoogleToolboxForMac',
            'Firebase', 'DRDPluginResources', 'Cuckoo', 'CTCheckbox', 'Crashlytics', 'BKMoneyKit', 'VoipKit']

            devpodWhiteList = [
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

            # Bang: testing issue for duplicated vendor
           @prebuild_pod_names ||= self.prebuild_pod_targets.map(&:pod_name).reject { |name| localResourcesTargets.include?(name) || issueTargets.include?(name) || podsBlackList.include?(name) }.reject { |name| sandbox.local?(name) && !devpodWhiteList.include?(name) }
        end


        def validate_every_pod_only_have_one_form

            multi_targets_pods = self.pod_targets.group_by do |t|
                t.pod_name
            end.select do |k, v|
                v.map{|t| t.platform.name }.count > 1
            end

            multi_targets_pods = multi_targets_pods.reject do |name, targets|
                contained = targets.map{|t| self.prebuild_pod_targets.include? t }
                contained.uniq.count == 1 # all equal
            end

            return if multi_targets_pods.empty?

            warnings = "One pod can only be prebuilt or not prebuilt. These pod have different forms in multiple targets:\n"
            warnings += multi_targets_pods.map{|name, targets| "         #{name}: #{targets.map{|t|t.platform.name}}"}.join("\n")
            raise Informative, warnings
        end

    end
end



