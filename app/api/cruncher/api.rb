module Cruncher
  class API < Grape::API
    prefix 'api'
    version 'v1', using: :path
    format :json

    mount Cruncher::SheetResource
  end
end
