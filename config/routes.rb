Pooling::Engine.routes.draw do
	root :to => 'pooling#index'
	match 'shares' => 'pooling#shares', :via=>:get
	get 'toggle_share_pooling' => 'pooling#toggle_share_pooling'
	get 'update_extra_copies' => 'pooling#update_extra_copies'
	get 'toggle_disk_pool_partition' => 'pooling#toggle_disk_pool_partition'
	get 'status' => 'pooling#status'
	get 'check_status' => 'pooling#check_status'
end