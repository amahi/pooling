Poolings::Engine.routes.draw do
	root :to => 'poolings#index'
	match 'shares' => 'poolings#shares', :via=>:get
	get 'toggle_share_pooling' => 'poolings#toggle_share_pooling'
	get 'update_extra_copies' => 'poolings#update_extra_copies'
	get 'toggle_disk_pool_partition' => 'poolings#toggle_disk_pool_partition'
end