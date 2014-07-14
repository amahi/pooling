Poolings::Engine.routes.draw do
	root :to => 'poolings#index'
	match 'shares' => 'poolings#shares', :via=>:get
end
