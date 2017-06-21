Pageflow::Chart::Engine.routes.draw do
  get 'proxy/*path', to: 'proxies#s3', format: false
  resources :scraped_sites, only: [:create, :show]
end
