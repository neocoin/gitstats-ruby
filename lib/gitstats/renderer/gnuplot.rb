class GnuplotRenderer
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

    def initialize(templatedir, filename, outdir, stats, verbose)
      @filename = filename
      @outdir = outdir
      @stats = stats
      @verbose = verbose

      Dir.glob(File.join(templatedir, 'helpers', '*.rb')).sort.each do |file|
        eval(IO::readlines(file).join(''))
      end
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

  def name
    'gnuplot'
  end

  def handle?(file)
    file =~ /\.plot$/
  end

  def render(file, stats)
    ifile = File.join(@templatedir, file)

    lines = IO::readlines(ifile).join('')

    PlotHelper.new(@templatedir, file, @outdir, stats, @verbose).run(lines)
  end
end

Renderer.register GnuplotRenderer
