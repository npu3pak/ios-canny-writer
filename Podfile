platform :ios, :deployment_target => '6.0'


target 'CannyWriter' do
    # Не забываем, что в VKSdk.m я перепилил
    # (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth
    pod 'VK-ios-sdk'
    pod 'WYPopoverController', :git => 'https://github.com/nicolaschengdev/WYPopoverController.git'
    pod 'MBProgressHUD', '~> 0.8'
    pod 'SDWebImage'
    pod 'PSTCollectionView', '~> 1.2'
end
