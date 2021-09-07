def shared_pods
	pod 'Alamofire'
	pod 'SwiftyGif'
end

target 'Assignment' do

	use_frameworks!
	shared_pods

	target 'AssignmentTests' do
		inherit! :search_paths
	end

	target 'AssignmentUITests' do
		pod 'TABTestKit',
		shared_pods
		inherit! :search_paths
	end

end

