module Api
  module V1
    class BaseController < ApplicationController
      before_action :doorkeeper_authorize!
    end
  end
end
