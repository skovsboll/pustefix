require 'rspec'
require_relative '../app/GitLogParser'

describe 'Parsing customized git log output' do

  it 'should parse commits correctly' do

    input = <<EOS
799969dccf5a95fb3e286dd9f9d681be61113af5 Wed Oct 30 21:50:15 2013 +0100 soren@skovsboll.com Redirect fra legetoejskatalog.dk
e5668d2df0bcf94abfe817b11d75977836c0b9d9 Wed Oct 30 21:18:53 2013 +0100 soren@skovsboll.com opened up site to the public!
bfca2f095e23cf8036a8a9132a2af8994d938396 Wed Oct 30 21:04:48 2013 +0100 soren@skovsboll.com idn canonical domain
d0f6f9097d03c61158d5cc73c0632b4b9cc3d21b Wed Oct 30 21:03:12 2013 +0100 soren@skovsboll.com temporary: short cache period
74f8ea761fdb64c995ca0031c8871d3c2192e244 Wed Oct 30 20:56:02 2013 +0100 soren@skovsboll.com Is this working in IE?
7ac1efbbed14f77f1ce69a28a002dda81ba228b3 Wed Oct 30 20:16:43 2013 +0100 soren@skovsboll.com Trying unicorn again
feaab37ba1a5fd8f6442af2e488f49b4e00e23e9 Wed Oct 30 16:29:31 2013 +0100 morten@vampyr.dk Event tracking
1e02b4dcfce9490efc8914acff96df2e0ca362b6 Wed Oct 30 16:15:09 2013 +0100 morten@vampyr.dk Analytics test
EOS

    sut = Pustefix::GitLogParser.new
    input.each_line do |line|
      commit = sut.parse_line(line)
      commit.sha.should_not be_empty
      commit.date.should_not be_empty
      Date.parse(commit.date).month.should be(10)
      commit.email.should_not be_empty
      commit.comment.should_not be_empty
    end

  end
end