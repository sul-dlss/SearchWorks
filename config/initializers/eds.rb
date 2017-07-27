require 'ebsco/eds'

raise ArgumentError, 'EDS API requires user, password, and profile settings' if Settings.EDS_USER.blank? ||
                                                                                Settings.EDS_PASS.blank? ||
                                                                                Settings.EDS_PROFILE.blank?

$EDS_GUEST_MODE = true # TODO: hardcoded to non-authenticated
