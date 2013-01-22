class MainController < ApplicationController
	
  skip_before_filter :require_login, :except => [:graph]

  def index
  end

end
