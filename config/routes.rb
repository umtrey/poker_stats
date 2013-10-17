PokerStats4::Application.routes.draw do
  post "/stats" => "poker#index", :as => :root
end
