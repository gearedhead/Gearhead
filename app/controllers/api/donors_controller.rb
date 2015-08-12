class Api::DonorsController < Api::ApplicationController
  def index
    @donors = User.paginate page: params[:page], per_page: 50
    respond_with @donors
  end

  def search
    @donors = User.search(params[:user]).paginate(page: params[:page], per_page: 50)
    respond_with @donors
  end
end
