require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  setup do
    @status = statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:statuses)
  end

  test "should be redirected when new user" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should render the new page when logged in" do
    sign_in users(:jack)
    get :new
    assert_response :success
  end

  test "should be logged in to post a status" do
    post :create, status: { content: "Hello" }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "should create status when logged in" do
      sign_in users(:jack)

      assert_difference('Status.count') do
      post :create, status: { content: @status.content }
      end

    assert_redirected_to status_path(assigns(:status))
  end

  test "should create a status for the current user when logged in" do
      sign_in users(:jack)

      assert_difference('Status.count') do
      post :create, status: { content: @status.content, user_id: users(:jill).id }
      end

    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:jack).id
  end

  test "should show status" do
    get :show, id: @status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @status
    assert_response :success
  end

  test "should update status" do
    sign_in users(:jack)
    put :update, id: @status, status: { content: @status.content }
    assert_redirected_to status_path(assigns(:status))
  end

  test "should update status for the current user whe logged in" do
    sign_in users(:jack)
    put :update, id: @status, status: { content: @status.content, user_id: users(:jill).id }
    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:jack).id
  end

  test "should not update the status if nothing is sent in" do
    sign_in users(:jack)
    put :update, id: @status
    assert_redirected_to status_path(assigns(:status))
    assert_equal assigns(:status).user_id, users(:jack).id
  end

  test "should destroy status" do
    assert_difference('Status.count', -1) do
      delete :destroy, id: @status
    end

    assert_redirected_to statuses_path
  end
end
