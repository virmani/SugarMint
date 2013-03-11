require 'test_helper'

class LifeEventsControllerTest < ActionController::TestCase
  setup do
    @life_event = life_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:life_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create life_event" do
    assert_difference('LifeEvent.count') do
      post :create, life_event: @life_event.attributes
    end

    assert_redirected_to life_event_path(assigns(:life_event))
  end

  test "should show life_event" do
    get :show, id: @life_event.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @life_event.to_param
    assert_response :success
  end

  test "should update life_event" do
    put :update, id: @life_event.to_param, life_event: @life_event.attributes
    assert_redirected_to life_event_path(assigns(:life_event))
  end

  test "should destroy life_event" do
    assert_difference('LifeEvent.count', -1) do
      delete :destroy, id: @life_event.to_param
    end

    assert_redirected_to life_events_path
  end
end
