class Renderer
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

  class PlotHelper
    class Plotter
      attr_reader :plot

      def initialize(helper)
        @helper = helper
        @plot = nil
      end

      def run
        Gnuplot.open do |gp|
          Gnuplot::Plot.new(gp) do |plot|
            @plot = plot

            plot.terminal 'png transparent size 640,240'
            plot.size '1.0,1.0'
            plot.output File.join(@helper.outdir, File.basename(@helper.filename, '.plot') + '.png')
            plot.nokey
            plot.xtics 'rotate'
            plot.ytics 'autofreq'
            plot.grid 'y'

            yield self
          end
        end
      end

      def add_boxes(args = {})
        args = {
          :setrange => true,
          :limitlabels => true,
          :labelcount => 15
        }.merge(args)

        x = Array.new
        l = Array.new
        y = Array.new

        yield x, l, y

        limitlabels(l, args[:labelcount]) if args[:limitlabels]

        @plot.xrange "[\"#{x.first - 1}\":\"#{x.last + 1}\"]" if args[:setrange]

        @plot.data << Gnuplot::DataSet.new([x, l, y]) do |ds|
          ds.using = '1:3:(0.5):xtic(2)'
          ds.with = 'boxes fs solid'
          ds.notitle
        end
      end

      def add_steps(args = {})
        args = {
          :setrange => true,
          :limitlabels => true,
          :labelcount => 15,
          :firstlabel => '""'
        }.merge(args)

        x = Array.new
        l = Array.new
        y = Array.new

        yield x, l, y

        limitlabels(l, args[:labelcount]) if args[:limitlabels]

        @plot.xrange "[\"#{x.first - 1}\":\"#{x.last + 1}\"]" if args[:setrange]

        unless args[:firstlabel].nil?
          x.insert(0, x.first - 1)
          l.insert(0, args[:firstlabel])
          y.insert(0, 0)
        end

        @plot.data << Gnuplot::DataSet.new([x, l, y]) do |ds|
          ds.using = '1:3:xtic(2)'
          ds.with = 'steps'
          ds.notitle
        end
      end

      private
      def limitlabels(l, maxcount)
        cnt = l.size
        step = (cnt > maxcount) ? (cnt / maxcount + 0.5).round.to_i : 1

        i = 0
        l.map! do |e|
          unless ((i % step) == 0) || (i == (cnt - 1))
            e = '""'
          end
          i += 1
          e
        end
        l
      end
    end

    attr_reader :filename
    attr_reader :outdir
    attr_reader :stats
    attr_reader :verbose

    def initialize(filename, outdir, stats, verbose)
      @filename = filename
      @outdir = outdir
      @stats = stats
      @verbose = verbose
    end

    def run(lines)
      eval(lines)
    end

    def defplot(&block)
      plotter = Plotter.new(self)
      plotter.run(&block)
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

        PlotHelper.new(file, @outdir, stats, @verbose).run(lines)
      else
        puts "copying '#{file}' ..." if @verbose
        File.copy(File.join(@templatedir, file), @outdir)
      end
    end
  end
end

