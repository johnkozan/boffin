require 'spec_helper'

class MockObject
  def id; 100; end
end

describe Boffin::Utils do
  describe '::underscore' do
    it 'works with namespaces' do
      subject.underscore('MyMod::MyClass').should == 'my_mod_my_class'
    end

    it 'works without namespaces' do
      subject.underscore('MyMod').should == 'my_mod'
      subject.underscore('Mod').should == 'mod'
    end

    it 'works with blank strings' do
      subject.underscore('').should == ''
      subject.underscore(' ').should == ' '
    end
  end

  describe '::quick_token' do
    it 'generates tokens' do
      subject.quick_token.should be_a String
      subject.quick_token.length.should > 6
    end
  end

  describe '::blank?' do
    it 'returns true for []' do
      subject.blank?([]).should be_true
    end

    it 'returns true for {}' do
      subject.blank?({}).should be_true
    end

    it 'returns true for nil' do
      subject.blank?(nil).should be_true
    end

    it 'returns true for ""' do
      subject.blank?('').should be_true
    end

    it 'returns true for false' do
      subject.blank?(false).should be_true
    end

    it 'returns false for non-blank things' do
      subject.blank?(0).should be_false
    end
  end

  describe '::extract_time_unit' do
    specify { subject.extract_time_unit(hours:  6).should == [:hours,  6] }
    specify { subject.extract_time_unit(days:   2).should == [:days,   2] }
    specify { subject.extract_time_unit(months: 3).should == [:months, 3] }

    it 'throws an error if no time unit pair exists in the hash' do
      lambda { subject.extract_time_unit(fun: 'times') }.
        should raise_error ArgumentError
    end
  end

  describe '::time_ago' do
    before { @time = Time.local(2011, 2, 15, 12) }

    specify { subject.time_ago(@time, hours:  6).should == Time.local(2011, 2,  15, 6)  }
    specify { subject.time_ago(@time, days:   5).should == Time.local(2011, 2,  10, 12) }
    specify { subject.time_ago(@time, months: 1).should == Time.local(2011, 1,  16, 12) } # A "month" is 30 days

    it 'throws an error if no time unit pair exists in the hash' do
      lambda { subject.time_ago(@time, fun: 'fail') }.
        should raise_error ArgumentError
    end
  end

  describe '::time_ago_range' do
    before { @time = Time.local(2011, 2, 15, 12) }

    specify { subject.time_ago_range(@time, hours:  6).size.should == 6 }
    specify { subject.time_ago_range(@time, months: 1).size.should == 1 }

    specify do
      subject.time_ago_range(@time, days: 2).
        should == [Time.local(2011, 2, 14, 12), Time.local(2011, 2, 15, 12)]
    end

    specify do
      subject.time_ago_range(@time, days: 3).
        should == [
          Time.local(2011, 2, 13, 12),
          Time.local(2011, 2, 14, 12),
          Time.local(2011, 2, 15, 12)
        ]
    end

    it 'ranges from n days away upto @time' do
      times = subject.time_ago_range(@time, days: 4)
      times.first.should == Time.local(2011, 2, 12, 12)
      times.last.should == @time
    end

    it 'throws an error if no time unit pair exists in the hash' do
      lambda { subject.time_ago_range(@time, fun: 'crash') }.
        should raise_error ArgumentError
    end
  end

  describe '::uniquenesses_as_session_identifier' do
    specify { subject.uniquenesses_as_session_identifier([]).size.should > 8 }
    specify { subject.uniquenesses_as_session_identifier([nil, 'hi']).should == 'hi' }
    specify { subject.uniquenesses_as_session_identifier([MockObject.new]).should == 'mock_object:100' }
  end

  describe '::object_as_session_identifier' do
    specify { subject.object_as_session_identifier(nil).should == '' }
    specify { subject.object_as_session_identifier(MockObject.new).should == 'mock_object:100' }
    specify { subject.object_as_session_identifier(3.14).should == '3.14' }
  end

  describe '::object_as_namespace' do
    specify { subject.object_as_namespace(:ns).should == 'ns' }
    specify { subject.object_as_namespace(MockObject).should == 'mock_object' }
    specify { subject.object_as_namespace('ns').should == 'ns' }
  end

  describe '::object_as_key(obj)' do
    specify { subject.object_as_key(MockObject.new).should == '100' }
    specify { subject.object_as_key(100).should == 'MTAw' }
    specify { subject.object_as_key('/test?te=st').should == 'L3Rlc3Q/dGU9c3Q=' }
  end
end