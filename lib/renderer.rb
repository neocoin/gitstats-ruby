class Renderer
  class HamlHelper
    attr_reader :stats

    def initialize(templatedir, stats, verbose)
      @templatedir = templatedir
      @stats = stats
      @verbose = verbose
      @layout = nil
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

  class PlotHelper
    attr_reader :outdir
    attr_reader :stats
    attr_reader :verbose

    def initialize(outdir, stats, verbose)
      @outdir = outdir
      @stats = stats
      @verbose = verbose
    end

    def run(lines)
      eval(lines)
    end
  end

  def initialize(templatedir, outdir, verbose)
    @templatedir = templatedir
    @outdir = outdir
    @verbose = verbose
  end

  def render(stats)
    Dir.chdir(@templatedir) { Dir.glob('*').sort }.each do |file|
      next unless File.file?(File.join(@templatedir, file))

      ext = File.extname(file)

      if ext == '.haml'
        puts "rendering '#{file}' using haml ..." if @verbose
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        helper = HamlHelper.new(@templatedir, stats, @verbose)

        engine = Haml::Engine.new(lines)
        lines = engine.render(helper)

        if !helper.get_layout.nil?
          puts "rendering layout '#{helper.get_layout}' ..." if @verbose
          layout = IO::readlines(File.join(@templatedir, 'layouts', helper.get_layout + '.haml')).join('')
          engine = Haml::Engine.new(layout)
          lines = engine.render(Object.new, :content => lines)
        end

        File.new(File.join(@outdir, File.basename(file, '.haml') + '.html'), 'w').write(lines)
      elsif ext == '.sass'
        puts "rendering '#{file}' using sass/compass ..." if @verbose
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        options = Compass.sass_engine_options
        options[:syntax] = :sass
        engine = Sass::Engine.new(lines, options)
        lines = engine.render

        File.new(File.join(@outdir, File.basename(file, '.sass') + '.css'), 'w').write(lines)
      elsif ext == '.scss'
        puts "rendering '#{file}' using sass/compass ..." if @verbose
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        options = Compass.sass_engine_options
        options[:syntax] = :scss
        engine = Sass::Engine.new(lines, options)
        lines = engine.render

        File.new(File.join(@outdir, File.basename(file, '.scss') + '.css'), 'w').write(lines)
      elsif ext == '.plot'
        puts "rendering '#{file}' using gnuplot ..." if @verbose
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        PlotHelper.new(@outdir, stats, @verbose).run(lines)
      else
        puts "copying '#{file}' ..." if @verbose
        File.copy(File.join(@templatedir, file), @outdir)
      end
    end
  end
end

