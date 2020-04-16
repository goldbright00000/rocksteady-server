require_relative '../test_helper'

class PlacementRuleImporterTest < ActiveSupport::TestCase

  test 'qualifying year: Y' do
    y = '2000'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y' do
    y = '2000,2001'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y,Y' do
    y = '2000,2333,2323'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y-Y' do
    y = '1232,1232-4232'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y-Y,Y' do
    y = '1232,1232-4232,2312'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y,Y-Y' do
    y = '1111,2222,3333-4444'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y,Y-Y,Y-Y' do
    y = '1232,1232-4232,2312-2322'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y-Y' do
    y = '2000-2002'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y-Y,Y' do
    y = '2323-4523,2322'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y-Y,Y,Y' do
    y = '2323-4523,2322,3232'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y-Y,Y-Y' do
    y = '3232-3243,1232-2142'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: Y-Y,Y,Y-Y' do
    y = '1233-4232,2343,3243-2312'

    assert_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: not ending with comma' do
    y = '2122,'

    assert_not_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: not ending with dash' do
    y = '3243-'

    assert_not_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: year is not less than 4 digits' do
    y = '234'

    assert_not_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

  test 'qualifying year: year is not more than 4 digits' do
    y = '43423'

    assert_not_equal y, PlacementRuleImporterUnregulated::QUALIFYING_YEAR.match(y).to_s
  end

end
