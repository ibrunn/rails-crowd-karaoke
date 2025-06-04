class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]


  def welcome
    
    @generated_uuid = SecureRandom.uuid

  end


  def home

  end
end
