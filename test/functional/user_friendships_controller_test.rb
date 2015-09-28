require 'test_helper'

class UserFriendshipsControllerTest < ActionController::TestCase

		context "#index" do
			context "when not logged in" do
				should "redirect to login page" do
					get :index
					assert_response :redirect
				end
			end

			context "when logged in" do
				setup do
					@friendship1 = create(:pending_user_friendship, user: users(:jack), friend: create(:user, first_name: 'Pending', last_name: 'Friend'))
					@friendship2 = create(:accepted_user_friendship, user: users(:jack), friend: create(:user, first_name: 'Active', last_name: 'Friend'))
				
					sign_in users(:jack)
					get :index
				end

				should "get the index page without error" do
					assert_response :success
				end

				should "assign user_friendships" do
					assert assigns(:user_friendships)
				end

				should "display friend's names" do
					assert_match /Pending/, response.body
					assert_match /Active/, response.body
				end

				should "display pending information if request is pending" do 
					assert_select "#user_friendship_#{@friendship1.id}"  do
						assert_select "em", "Friendship is pending."						
					end
				end

				should "display date when friendship accepted" do 
					assert_select "#user_friendship_#{@friendship2.id}"  do
						assert_select "em", "Friendship started #{@friendship2.updated_at}."						
					end
				end

			end
		end

		context "#new" do
			context "when not logged in" do
				should "redirect to login page" do
					get :new
					assert_response :redirect
				end
			end

		context "when logged in" do
			setup do
				sign_in users(:jack)
			end

			should "get the new page and return success" do
				get :new
				assert_response :success
			end

			should "should set a flash error if the friend_id params is missing" do
				get :new, {}
				assert_equal "Friend required", flash[:error]
			end

			should "display the friend's name" do
				get :new, friend_id: users(:jill)
				assert_match /#{users(:jill).full_name}/, response.body
			end

			should "assign a new user friendship" do
				get :new, friend_id: users(:jill)
				assert assigns(:user_friendship)
			end

			should "assign a new user friendship to the correct friend" do
				get :new, friend_id: users(:jill)
				assert_equal users(:jill), assigns(:user_friendship).friend
			end

			should "assign a new user friendship to the currently logged in user" do
				get :new, friend_id: users(:jill)
				assert_equal users(:jack), assigns(:user_friendship).user
			end

			should "return a 404 status if no friend is found" do
				get :new, friend_id: 'invalid'
				assert_response :not_found
			end
			should "ask if you really want to request friendship" do
				get :new, friend_id: users(:jill)
				assert_match /Do you really want to friend #{users(:jill).full_name}?/, response.body

			end
		end
	end

	context "#create" do
		context "when not logged in" do
			should "redirect to login page" do
				get :new
				assert_response :redirect
				assert_redirected_to login_path
			end
		end
	
		context "when logged in" do
			setup do
				sign_in users(:jack)
			end
			context "if no friend friend_id" do
				setup do
					post :create
				end
				
				should "set the flash error message" do
					assert !flash[:error].empty?
				end

				should "redirect to root path" do 
					assert_redirected_to root_path
				end
			end

			context "with a valid friend_id" do
				setup do
					post :create, user_friendship: { friend_id: users(:john) }
				end

				should "assign a friend object" do
					assert assigns(:friend)
					assert_equal users(:john), assigns(:friend)
				end

				should "assign a user_friendship object" do
					assert assigns(:user_friendship)
					assert_equal users(:jack), assigns(:user_friendship).user
					assert_equal users(:john), assigns(:user_friendship).friend
				end

				should "create a friendship" do
					assert users(:jack).pending_friends.include?(users(:john))
				end

				should "redirect to the profile page of the friend" do
					assert_response :redirect
					assert_redirected_to profile_path(users(:john))
				end

				should "set the flash message to say that we are now friends" do
					assert flash[:success]
					assert_equal "You are now friends with #{users(:john).full_name}", flash[:success]
				end
			end
		end
	end
	context "#accept" do
		context "when not logged in" do
			should "redirect to login page" do
				put :accept, id: 1
				assert_response :redirect
				assert_redirected_to login_path
			end
		end

		context "when logged in" do
			setup do
				@user_friendship = create(:pending_user_friendship, user: users(:jack))
				sign_in users(:jack)
				put :accept, id: @user_friendship
				@user_friendship.reload
			end

			should "assign a user_friendship" do
				assert assigns(:user_friendship)
				assert_equal @user_friendship, assigns(:user_friendship)
			end

			should "update the state to accepted" do
				assert_equal 'accepted', @user_friendship.state
			end

			should "have a flash success message" do
				assert_equal "You are now friends with #{@user_friendship.friend.first_name}", flash[:success]
			end
		end
	end

		context "#edit" do
			context "when not logged in" do
				should "redirect to login page" do
					get :edit, id: 1
					assert_response :redirect
				end
			end

		context "when logged in" do
			setup do
				@user_friendship = create(:pending_user_friendship, user: users(:jack))
				sign_in users(:jack)
				get :edit, id: @user_friendship
			end

			should "get the edit page and return success" do
				assert_response :success
			end

			should "assign to user_friendship" do
				assert assigns(:user_friendship)
			end

			should "assign to friend" do
				assert assigns(:friend)
			end
		end
	end
end
