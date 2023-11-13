require "test_helper"

class ConvertidorCsvControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get convertidor_csv_index_url
    assert_response :success
  end
end
