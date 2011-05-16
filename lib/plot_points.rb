#!/usr/bin/ruby1.8
# svg_roc_plot method - svg_roc_plot_method.rb
#       
# Copyright 2010 vorgrimmler <dv(a_t)fdm.uni-freiburg.de>
# This ruby method (svg_roc_plot) exports input data(from true-positive-rate and false-positive-rate arrays) to a *.svg file using gnuplot. Depending on the amount of input data is possible to create 1 to n curves in one plot. 
# Gnuplot is needed. Please install befor using svg_roc_plot. "sudo apt-get install gnuplot" (on debian systems).
# Usage: See below.

module RubyPlot

  def self.regression_point_plot(path, title, x_lable, y_lable, names, x_values, y_values, log=true) #, quadratic_scale=true, line_points=false, reverse_x=false)
    
    min = Float::MAX
    max = -Float::MAX
    (0..x_values.size-1).each do |i|
      min = [ min, x_values[i].min, y_values[i].min ].min
      max = [ max, x_values[i].max, y_values[i].max ].max
    end
    
    if log && min<=0
      LOGGER.warn "cannot use logscale for <=0 data"
      log = false
    end
    
    border = (max-min)*0.1
    if log
      min_border = min-border/10.0
      while min_border<=0
        border /= 2
        min_border = min-border/10.0
      end
      max_border = max+border
    else
      min_border = min-border
      max_border = max+border
    end
    
    x_range = [min_border, max_border]
    y_range = [min_border, max_border]
    
    plot_points(path, title, x_lable, y_lable, names, x_values, y_values, log, x_range, y_range, true, true, false, false, false)      
  end
  
  def self.accuracy_confidence_plot(path, title, x_lable, y_lable, names, x_values, y_values, reverse_y=false) #y_range=nil, 
    
    min = Float::MAX
    max = -Float::MAX
    (0..x_values.size-1).each do |i|
      min = [ min, y_values[i].min ].min
      max = [ max, y_values[i].max ].max
    end
    border = (max-min)*0.1
    min_border = min-border
    max_border = max+border
    y_range = [min_border, max_border]
    
    plot_points(path, title, x_lable, y_lable, names, x_values, y_values, false, nil, y_range, false, false, true, true, reverse_y)
  end

  def self.plot_points(path, title, x_lable, y_lable, names, x_values, y_values, 
    log=true, x_range=nil, y_range=nil, quadratic_scale=true, draw_diagonale=true, line_points=false, reverse_x=false, reverse_y=false)
    
    LOGGER.debug "ruby-plot: plot points "+names.inspect
    LOGGER.debug "ruby-plot: plot points "+x_values.inspect
    LOGGER.debug "ruby-plot: plot points "+y_values.inspect
    
    data = []
    (0..x_values.size-1).each do |i|
      data << y_values[i]
      data << x_values[i]
    end
    
    #Main
    STDOUT.sync = true
    # -----------------------------------------------------
    # checking input
    # -----------------------------------------------------
    # check parameters
    status=false
    LOGGER.debug "#{names.length} algs entered"
    
    #LOGGER.debug names.inspect
    #LOGGER.debug data.inspect
    
    if names.length != data.length/2
        status=true
    end
    
    if status
      raise "Usage: svg_roc_plot (path(?), title(string), x-lable(string), y-lable(sting), algorithms(array), true_pos_data1(array), false_pos_data1(array), ...,  true_pos_data_n(array), false_pos_data_n(array))\n"+
            "       Only pairs of data are allowed but at least one.\n"+
            "       Each data array has to provide one float/int number from 0 to 100 per entry."
    end
    
    # gnuplot check
    gnuplot=`which gnuplot | grep -o gnuplot`
    if gnuplot == "gnuplot\n"
      LOGGER.debug "Gnuplot is already installed."
    else
      raise "Please install gnuplot.\n"+
            "sudo apt-get install gnuplot"
    end
    
    dat_number=0
    
    output_dat_arr = Array.new
    
    
    # -----------------------------------------------------
    # create *.dat files of imported data for gnuplot
    # -----------------------------------------------------
    # write true/false arrays to one array
    for i in 0..names.length-1#/2-1
      true_pos_arr = data[i*2]
      false_pos_arr = data[i*2+1]
      #check length of input files
      if true_pos_arr.length == false_pos_arr.length
        #LOGGER.debug "Same length!"
        for j in 0..true_pos_arr.length-1
          #check if array entries are float format and between 0.0 and 100.0
          #if numeric?(true_pos_arr[j].to_s.tr(',', '.')) && true_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && true_pos_arr[j].to_s.tr(',', '.').to_f >= 0
          #  if  numeric?(false_pos_arr[j].to_s.tr(',', '.')) && false_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && false_pos_arr[j].to_s.tr(',', '.').to_f >= 0
              output_dat_arr[j] = "#{true_pos_arr[j]} #{false_pos_arr[j]}"
          #  else
          #    raise "The data of #{names[i]}  has not the right formatin at position #{j}\n"+
          #          "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
          #  end
          #else
          #  raise "The data of #{names[i]}  has not the right formatin at position #{j}+\n"
          #         "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
          #end
        end
        #-----------------------------------------------------
        #write *.dat files
        #-----------------------------------------------------
        #write output_dat_arr content in new *.dat file
        File.open( "data#{i}.dat", "w" ) do |the_file|
            the_file.puts output_dat_arr
        end
        LOGGER.debug "data#{i}.dat created."
        output_dat_arr.clear
            
      else
        raise "Data pair of #{names[i]} have no the same number of elements."
      end
    end
    
    # -----------------------------------------------------
    # create *.plt file for gnuplot
    # -----------------------------------------------------
    # 
    output_plt_arr = Array.new
    output_plt_arr.push "# Specifies encoding and output format"
    output_plt_arr.push "set encoding default"
    
    if path=~/(?i)svg/
      output_plt_arr.push 'set terminal svg size 800,600 dynamic enhanced fname "Arial" fsize 12 butt'
    elsif path=~/(?i)png/
      output_plt_arr.push 'set terminal png'
    else
      raise "format not supported "+path.to_s
    end
    
    if log
      output_plt_arr.push 'set logscale x'
      output_plt_arr.push 'set logscale y'
    end
    
    output_plt_arr.push "set output '#{path}'"
    output_plt_arr.push ""
    output_plt_arr.push "# Specifies the range of the axes and appearance"
    
    x_range_s = x_range ? "["+x_range[0].to_s+":"+x_range[1].to_s+"]" : "[]"
    y_range_s = y_range ? "["+y_range[0].to_s+":"+y_range[1].to_s+"]" : "[]"
    reverse_x_s = reverse_x ? "reverse" : ""
    reverse_y_s = reverse_y ? "reverse" : ""
    output_plt_arr.push "set xrange "+x_range_s+" "+reverse_x_s
    output_plt_arr.push "set yrange "+y_range_s+" "+reverse_y_s
    
    output_plt_arr.push 'set size ratio -1' if quadratic_scale
    output_plt_arr.push "set arrow from "+x_range[0].to_s+","+y_range[0].to_s+" to "+x_range[1].to_s+","+y_range[1].to_s+" nohead lt 0" if draw_diagonale
    
    output_plt_arr.push "set grid lw 0.5"
    output_plt_arr.push "set title \"#{title}\""
    output_plt_arr.push "set key below"
    output_plt_arr.push "set xlabel \"#{x_lable}\""
    output_plt_arr.push "set ylabel \"#{y_lable}\""
    
    
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push "# Draws the plot and specifies its appearance ..."
    
    output_plt_arr.push "plot \\"#'random_0.dat' using 1:2 title 'random' with lines lw 1, \\"
    
    style = "points"
    if (line_points)
      style = "lp"
    end
    
    i = 0
    for i in 0..names.length-1
      if i == names.length-1
        output_plt_arr.push " 'data#{i}.dat'  using 2:1 title '#{names[i]}' with "+style.to_s
      else
        output_plt_arr.push " 'data#{i}.dat'  using 2:1 title '#{names[i]}' with "+style.to_s+", \\"
      end
    end
    output_plt_arr.push ""
    output_plt_arr.push ""
    
    
    #output_plt_arr << "plot f(x)"
    
    # -----------------------------------------------------
    # write *.plt files
    # -----------------------------------------------------
    # write output_dat_arr content in new *.dat file
    File.open( "config.plt", "w" ) do |the_file|
      the_file.puts output_plt_arr
    end
    LOGGER.debug "config.plt created, running gnuplot"
    
    # start gnuplot with created *.plt file
    cmd = "gnuplot config.plt 2>&1"
    response = ""
    IO.popen(cmd) do |f| 
      while line = f.gets
        response += line
      end
    end
    raise "gnuplot failes (cmd: "+cmd.to_s+", out: "+response.to_s+")" unless $?==0
    
    LOGGER.debug "#{path} created. "
    
    # -----------------------------------------------------
    # remove *.plt and *.dat files
    # -----------------------------------------------------
    `rm config.plt`
    LOGGER.debug "config.plt removed."
    for i in 0..names.length-1
      `rm data#{i}.dat`
      LOGGER.debug "data#{i}.dat removed."
    end
  end
 
  def self.test_plot_points
    regression_point_plot("/tmp/regression.png" , "name of title", "x-values", "y-values", ["this-one-has-a-very-very-very-long-name", "test" ], 
      [[0.20,0.60,0.80,0.20,1.0,0.001], [0.10,0.25,0.70,0.95,0.2,0.3434]], 
      [[0.15,0.50,0.90,0.2,9,0.5],[0.20,0.40,0.50,0.70,0.3,0.234589]])
      
    accuracy_confidence_plot("/tmp/accuracy-conf.png" , "name of title", "x-values", "y-values", ["test" ], 
      [[0.9,0.5,0.3,0.1]],
      [[100,90,70,30]])
  end
 
  private
  # float check
  def self.numeric?(object) 
   true if Float(object) rescue false
  end
end

