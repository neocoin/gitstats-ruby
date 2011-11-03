class Git
  def initialize(base, ref = 'HEAD')
    @base = base
    @ref = ref
  end

  def num_authors
    sh("git shortlog -s #{@ref}").split(/\n/).count
  end

  def get_commits(&block)
    commits = Array.new if block.nil?

    commit = nil
    sh("git log --summary --numstat --pretty=format:\"HEADER: %at %ai %H %T %aN <%aE>\" #{@ref}").split(/\n/).each do |line|
      if line =~ /^HEADER:/
        parts = line.split(' ', 8)
        parts.shift

        commit = Hash.new
        commit[:time] = Time.at(parts[0].to_i)
        commit[:timezone] = parts[3]
        commit[:hash] = parts[4]
        commit[:tree] = parts[5]
        commit[:name], commit[:email] = /^(.+) <(.+)>$/.match(parts[6]).captures
        commit[:files_added] = 0
        commit[:files_deleted] = 0
        commit[:lines_added] = 0
        commit[:lines_deleted] = 0
      elsif line == ''
        if block.nil?
          commits << commit
        else
          block.call(commit)
        end
      elsif line =~ /^ /
        if line =~ /^ create/
          commit[:files_added] += 1
        elsif line =~ /^ delete/
          commit[:files_deleted] += 1
        end
      else
        added, deleted = /^(\d+)\s+(\d+)/.match(line).captures
        commit[:lines_added] += added.to_i
        commit[:lines_deleted] += deleted.to_i
      end
    end

    commits if block.nil?
  end

  def get_files(ref = nil)
    ref ||= @ref

    files = Array.new

    sh("git ls-tree -r -l #{ref}").split(/\n/).each do |line|
      parts = line.split(/\s+/, 5)
      next if parts[1] != 'blob'

      file = Hash.new
      file[:hash] = parts[2]
      file[:size] = parts[3]
      file[:name] = parts[4]

      files << file
    end

    files
  end

  private
  def sh(cmd)
    Dir.chdir(@base) do
      `#{cmd}`
    end
  end
end

