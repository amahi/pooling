Poolings::Engine.routes.draw do
	root :to => 'poolings#index'
	match 'shares' => 'poolings#shares', :via=>:get
	put 'toggle_share_pooling' => 'poolings#toggle_share_pooling'
	put 'update_extra_copies' => 'poolings#update_extra_copies'
end