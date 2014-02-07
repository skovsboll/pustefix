module Pustefix
  class GitLogParser

    def parse_line(line)
      rx =/([a-f0-9]+) \s (\w{3}\s\w{3}\s\d+\s\d+:\d+:\d+\s\d+\s(?:\+\d+)) \s ([a-zA-Z0-9._\-+%.]+@[a-zA-Z0-9_\-+%.]+\.[a-zA-Z]{2,4}) \s (.*)/ix
        _, sha, date, email, comment = *line.match(rx)
      GitCommit.new(email, sha, date, comment)
    end
  end

  class GitCommit < Struct.new(:email, :sha, :date, :comment); end
end