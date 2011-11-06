class Git
  attr_reader :name
  attr_reader :base
  attr_reader :ref

  def initialize(name, base, ref = 'HEAD', debug = false, cachefile = nil)
    @name = name
    @base = base
    @ref = ref
    @debug = debug
    @cachefile = cachefile
  end

  def open_cache
    @cache = File.new(@cachefile, 'a')
  end

  def close_cache
    unless @cache.nil?
      @cache.close
      @cache = nil
    end
  end

  def write_cache(commit)
    obj = Marshal.dump(commit)
    raise "Object too large" if obj.size > 65535

    str = ((obj.size >> 8) & 0xff).chr
    str += (obj.size & 0xff).chr
    str += obj

    @cache.write(str)
    @cache.flush
  end

  def read_cache
    f = File.new(@cachefile)
    while(!f.eof?)
      tmp = f.read(2)
      len = (tmp[0] << 8) + tmp[1]
      obj = f.read(len)
      raise "Read short object" if obj.size != len
      yield Marshal.load(obj)
    end
    f.close
  end

  def get_commits(last = nil, &block)
    if last.nil?
      range = @ref
      unless @cachefile.nil?
        begin
          read_cache do |commit|
            block.call(commit)
            last = commit
          end
          range = "#{last[:hash]}..#{@ref}"
        rescue
        end
      end
    else
      range = "#{last}..#{@ref}"
    end

    open_cache unless @cachefile.nil?

    commit = nil
    sh("git log --reverse --summary --numstat --pretty=format:\"HEADER: %at %ai %H %T %aN <%aE>\" #{range}") do |line|
      if line =~ /^HEADER:/
        unless commit.nil?
          write_cache(commit) unless @cachefile.nil?
          block.call(commit)
        end

        parts = line.split(' ', 8)
        parts.shift

        commit = Hash.new
        commit[:time] = Time.at(parts[0].to_i)
        commit[:timezone] = parts[3]
        commit[:hash] = parts[4]
        commit[:tree] = parts[5]
        name = nil
        email = ''
        match = /^(.+) <(.+)>$/.match(parts[6])
        if match.nil?
          name = parts[6]
        else
          name, email = match.captures
        end
        commit[:author] = Author.new(name, email)
        commit[:files_added] = 0
        commit[:files_deleted] = 0
        commit[:lines_added] = 0
        commit[:lines_deleted] = 0
      elsif line == ''
        write_cache(commit) unless @cachefile.nil?
        block.call(commit)
        commit = nil
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

    unless commit.nil?
      write_cache(commit) unless @cachefile.nil?
      block.call(commit)
    end

  ensure
    close_cache unless @cachefile.nil?
  end

  def get_files(ref = nil, &block)
    ref ||= @ref

    sh("git ls-tree -r -l #{ref}").split(/\n/).each do |line|
      parts = line.split(/\s+/, 5)
      next if parts[1] != 'blob'

      file = Hash.new
      file[:hash] = parts[2]
      file[:size] = parts[3].to_i
      file[:name] = parts[4]

      block.call(file)
    end
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

