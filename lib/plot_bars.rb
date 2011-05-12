
module RubyPlot

  def self.plot_bars(title = '', measures = [], algorithms = [], output_file = '')
    
   #puts "'"+title+"',"+measures.inspect+","+algorithms.inspect+","
    
    measures = measures.collect{|m| m.gsub(/_/,'-')}
    
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        string = ''
        (1..measures.length).collect.each do |i|
          string += '"' + measures[i-1] + '" ' + i.to_s + ".00000 -1 "
        end
  
        if output_file=~/(?i)svg/
          plot.terminal 'svg size 800,600 dynamic enhanced fname "Arial" fsize 12 butt'
        elsif output_file=~/(?i)png/
          plot.terminal 'png'
        else
          raise "format not supported "+path.to_s
        end
  
        plot.output   output_file
        plot.bar    '1.000000'
        plot.boxwidth '0.9 absolute'
        plot.style    'fill  solid 1.00 border -1'
        plot.style    'rectangle back fc lt -3 fillstyle  solid 1.00 border -1'
        #plot.key    'outside right top vertical Right noreverse enhanced autotitles columnhead nobox'
        #plot.key "invert reverse Left outside"
        plot.key "below"
        
        plot.style    'histogram clustered gap 3 title  offset character 0, 0, 0'
  #     plot.datafile 'missing "-"'
        plot.style    'data histograms'
        plot.xtics    'border in scale 1,0.5 nomirror  offset character 0, 0, 0'
        #plot.xtics    'norangelimit'
        plot.xtics    'rotate'
        #plot.xtics    string
        plot.title    title
        plot.rrange   '[ * : * ] noreverse nowriteback  # (currently [0.00000:10.0000])'
        plot.trange   '[ * : * ] noreverse nowriteback  # (currently [-5.00000:5.00000])'
        plot.urange   '[ * : * ] noreverse nowriteback  # (currently [-5.00000:5.00000])'
        plot.vrange   '[ * : * ] noreverse nowriteback  # (currently [-5.00000:5.00000])'
  #     plot.ylabel   'offset character 0, 0, 0 font "" textcolor lt -1 rotate by 90'
  #     plot.y2label  'offset character 0, 0, 0 font "" textcolor lt -1 rotate by 90'
        plot.yrange   '[ 0.00000 : 1.00000 ] noreverse nowriteback'                 #
        plot.cblabel  'offset character 0, 0, 0 font "" textcolor lt -1 rotate by 90'
        plot.locale   '"C"'
       
        
  
        algorithms.each do |algorithm|
          plot.data << Gnuplot::DataSet.new([ ["A"].concat(measures), algorithm ]) do |ds|
            ds.using = "2:xtic(1) ti col"
          end
        end
      end
    end
    LOGGER.info "plotted "+output_file.to_s
  end
  
  def self.test_plot_bars
    x = ['ACC_with_very_long_name_consider_that', 'AUC', 'SPEC', 'SENS']
    data = [['Alg1', 1.00, 1.00, 1.00, 1.00], ['Alg2', 0.75, 0.75, 0.75, 0.75], ['Alg3', 0.50, 0.50, 0.50, 0.50]]
    plot_bars('Vergleich der Algorithmen', x, data, '/tmp/hist.svg')
    
    x = ['ACC_with_very_long_name_consider_that', 'AUC', 'SPEC', 'SENS']
    data = [['Alg1', 1.00, 1.00, 1.00, 1.00], ['Alg2', 0.75, 0.75, 0.75, 0.75], ['Alg3', 0.50, 0.50, 0.50, 0.50]]
    plot_bars('Vergleich der Algorithmen', x, data, '/tmp/hist.png')
  end
  
end