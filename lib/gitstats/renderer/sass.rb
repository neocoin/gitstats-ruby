class SassRenderer
  def initialize(templatedir, outdir, verbose)
    @templatedir = templatedir
    @outdir = outdir
    @verbose = verbose
  end

  def name
    'sass/compass'
  end

  def handle?(file)
    (file =~ /\.sass$/) || (file =~ /\.scss$/)
  end

  def render(file, stats)
    scss = file =~ /\.scss$/

    ifile = File.join(@templatedir, file)
    ofile = File.join(@outdir, File.basename(file, scss ? '.scss' : '.sass') + '.css')

    lines = IO::readlines(ifile).join('')

    options = Compass.sass_engine_options
    options[:syntax] = scss ? :scss : :sass
    engine = Sass::Engine.new(lines, options)
    lines = engine.render

    File.new(ofile, 'w').write(lines)
  end
end

Renderer.register SassRenderer
