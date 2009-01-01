module ShoeHelpers
  
  def netlogin
    layout do
      flow do
        colorContent('user: ', red)
        @user = edit_line(@loader.user, :margin => 15)
      end
      flow do
        colorContent('password: ', red)
        @pass = edit_line(@loader.password, :margin => 15)
      end
      flow do
        button('cancel', :margin => 15) { clear; options }
        button('Done', :margin => 15) {@loader.user = @user.text; @loader.password = @pass.text; clear; options}
      end
    end
    @title.replace 'Login'
    @display.replace 'Please enter User and password for host login'
  end
  
end