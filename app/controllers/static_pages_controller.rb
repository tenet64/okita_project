class StaticPagesController < ApplicationController
  def top
  end

  def how_to_use
    render :how_to_use
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
