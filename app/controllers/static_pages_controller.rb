class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :top, :terms, :privacy, :contact ]

  def top
  end
  
  def terms
    render :terms
  end

  def privacy
    render :privacy
  end

  def contact
    render :contact
  end
end
