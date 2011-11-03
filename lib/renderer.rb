class Renderer
  class Helper
    attr_reader :stats

    def initialize(templatedir, stats)
      @templatedir = templatedir
      @stats = stats
      @layout = nil
    end

    def partial(name, hash = {})
      name = name.to_s
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

  def initialize(templatedir, outdir)
    @templatedir = templatedir
    @outdir = outdir
  end

  def render(stats)
    Dir.chdir(@templatedir) { Dir.glob('*').sort }.each do |file|
      next unless File.file?(File.join(@templatedir, file))

      puts file

      ext = File.extname(file)

      if ext == '.haml'
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        helper = Helper.new(@templatedir, stats)

        engine = Haml::Engine.new(lines)
        lines = engine.render(helper)

        if !helper.get_layout.nil?
          layout = IO::readlines(File.join(@templatedir, 'layouts', helper.get_layout + '.haml')).join('')
          engine = Haml::Engine.new(layout)
          lines = engine.render(Object.new, :content => lines)
        end

        File.new(File.join(@outdir, File.basename(file, '.haml') + '.html'), 'w').write(lines)
      elsif ext == '.sass'
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        options = Compass.sass_engine_options
        options[:syntax] = :sass
        engine = Sass::Engine.new(lines, options)
        lines = engine.render

        File.new(File.join(@outdir, File.basename(file, '.sass') + '.css'), 'w').write(lines)
      elsif ext == '.scss'
        lines = IO::readlines(File.join(@templatedir, file)).join('')

        options = Compass.sass_engine_options
        options[:syntax] = :scss
        engine = Sass::Engine.new(lines, options)
        lines = engine.render

        File.new(File.join(@outdir, File.basename(file, '.scss') + '.css'), 'w').write(lines)
      else
        File.copy(File.join(@templatedir, file), @outdir)
      end
    end
  end
end

