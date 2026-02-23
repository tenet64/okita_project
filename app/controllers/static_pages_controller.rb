class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :top, :terms, :privacy, :contact ]

  def top
  end
<<<<<<< HEAD
  
=======

  def how_to_use
    render :how_to_use
  end
>>>>>>> 46dc497a9368836cbd3ea1e9dbf1c42aeabd5d09
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
