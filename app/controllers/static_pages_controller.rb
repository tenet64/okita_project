class StaticPagesController < ApplicationController
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
