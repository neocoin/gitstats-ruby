class HamlRenderer
  class HamlHelper
    attr_reader :stats

    def initialize(templatedir, stats, verbose)
      @templatedir = templatedir
      @stats = stats
      @verbose = verbose
      @layout = nil

      Dir.glob(File.join(templatedir, 'helpers', '*.rb')).sort.each do |file|
        eval(IO::readlines(file).join(''))
      end
    end

    def partial(name, hash = {})
      name = name.to_s
      puts "rendering partial '#{name}' ..." if @verbose
      hash = hash.to_h unless hash.is_a? Hash
      lines = IO::readlines(File.join(@templatedir, 'partials', "#{name}.haml")).join('')
      engine = Haml::Engine.new(lines)
      engine.render(self, hash)
    end

    def layout(name)
      @layout = name.to_s
    end

    def get_layout
      @layout
    end
  end

  def initialize(templatedir, outdir, verbose)
    @templatedir = templatedir
    @outdir = outdir
    @verbose = verbose
  end

  def name
    'haml'
  end

  def handle?(file)
    file =~ /\.haml$/
  end

  def render(file, stats)
    ifile = File.join(@templatedir, file)
    ofile = File.join(@outdir, File.basename(file, '.haml') + '.html')

    lines = IO::readlines(ifile).join('')

    helper = HamlHelper.new(@templatedir, stats, @verbose)

    engine = Haml::Engine.new(lines)
    lines = engine.render(helper)

    if !helper.get_layout.nil?
      puts "rendering layout '#{helper.get_layout}' ..." if @verbose
      layout = IO::readlines(File.join(@templatedir, 'layouts', helper.get_layout + '.haml')).join('')
      engine = Haml::Engine.new(layout)
      lines = engine.render(Object.new, :content => lines)
    end

    File.new(ofile, 'w').write(lines)
  end
end

Renderer.register HamlRenderer
