class Renderer
  def self.register(cls)
    @@renderers ||= Array.new
    @@renderers << cls
  end

  def initialize(templatedir, outdir, verbose)
    @templatedir = templatedir
    @outdir = outdir
    @verbose = verbose
    @renderers = @@renderers.map { |x| x.new(templatedir, outdir, verbose) }
  end

  def render(stats)
    Dir.chdir(@templatedir) { Dir.glob('*').sort }.each do |file|
      next unless File.file?(File.join(@templatedir, file))

      r = @renderers.find { |r| r.handle?(file) }

      if r.nil?
        puts "copying '#{file}' ..." if @verbose
        File.copy(File.join(@templatedir, file), @outdir)
      else
        puts "rendering '#{file}' using #{r.name} ..." if @verbose
        r.render(file, stats)
      end
    end
  end
end

