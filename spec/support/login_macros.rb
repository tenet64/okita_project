module LoginMacros
  def login(user)
    visit unauthenticated_root_path
    # puts current_path

    click_link "ログイン"

    visit new_user_session_path
    # puts current_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password123'
    
    click_button 'ログイン'
    
    expect(page).to have_content 'ログインしました' 
    
    # puts "ログイン後の現在のパス: #{current_path}"

    
  end
end