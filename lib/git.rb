class Git
  attr_reader :name
  attr_reader :base
  attr_reader :ref

  def initialize(name, base, ref = 'HEAD', debug = false)
    @name = name
    @base = base
    @ref = ref
    @debug = debug
  end

  def num_authors
    sh("git shortlog -s #{@ref}").split(/\n/).count
  end

  def get_commits(last = nil, &block)
    commits = Array.new if block.nil?

    if last.nil?
      range = @ref
    else
      range = "#{last}..#{@ref}"
    end

    commit = nil
    sh("git log --reverse --summary --numstat --pretty=format:\"HEADER: %at %ai %H %T %aN <%aE>\" #{range}") do |line|
      if line =~ /^HEADER:/
        parts = line.split(' ', 8)
        parts.shift

        commit = Hash.new
        commit[:time] = Time.at(parts[0].to_i)
        commit[:timezone] = parts[3]
        commit[:hash] = parts[4]
        commit[:tree] = parts[5]
        match = /^(.+) <(.+)>$/.match(parts[6])
        if match.nil?
          commit[:name], commit[:email] = parts[6], ''
        else
          commit[:name], commit[:email] = match.captures
        end
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
        match = /^(\d+)\s+(\d+)/.match(line)
        unless match.nil?
          added, deleted = match.captures
          commit[:lines_added] += added.to_i
          commit[:lines_deleted] += deleted.to_i
        end
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
  def sh(cmd, &block)
    puts cmd if @debug
    Dir.chdir(@base) do
      if block.nil?
        `#{cmd}`
      else
        IO.popen(cmd) do |io|
          io.each_line do |line|
            block.call(line.chomp)
          end
        end
      end
    end
  end
end

