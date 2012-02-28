#!/usr/bin/ruby1.8
# svg_roc_plot method - svg_roc_plot_method.rb
#       
# Copyright 2010 vorgrimmler <dv(a_t)fdm.uni-freiburg.de>
# This ruby method (svg_roc_plot) exports input data(from true-positive-rate and false-positive-rate arrays) to a *.svg file using gnuplot. Depending on the amount of input data is possible to create 1 to n curves in one plot. 
# Gnuplot is needed. Please install befor using svg_roc_plot. "sudo apt-get install gnuplot" (on debian systems).
# Usage: See below.

module RubyPlot
  
  class LinePlotData
    attr_accessor :name, :x_values, :y_values, :faint, :labels
    def initialize(params)
      params.each{|k,v| send((k.to_s+"=").to_sym,v)}
    end
  end

  def self.plot_lines(path, title, x_lable, y_lable, plot_data )
    
    plot_data.each do |d|
      LOGGER.debug "plot lines -- "+d.name+" - "+d.x_values.inspect+" - "+d.y_values.inspect+" - "+d.labels.inspect
    end
    
    # gnuplot check
    gnuplot=`which gnuplot | grep -o gnuplot`
    #puts gnuplot
    unless gnuplot =~ /gnuplot/
      raise "Please install gnuplot.\n"+
            "sudo apt-get install gnuplot"
    end
    
    output_dat_arr = Array.new
    tmp_datasets = []
    
    # -----------------------------------------------------
    # create *.dat files of imported data for gnuplot
    # -----------------------------------------------------
    # write true/false arrays to one array
    #for i in 0..plot_data.length-1#/2-1
    plot_data.size.times do |i|
      
      true_pos_arr = plot_data[i].y_values
      false_pos_arr = plot_data[i].x_values
      
      #check length of input files
      if true_pos_arr.length == false_pos_arr.length
        #LOGGER.debug "Same length!"
        for j in 0..true_pos_arr.length-1
          #check if array entries are float format and between 0.0 and 100.0
          if numeric?(true_pos_arr[j].to_s.tr(',', '.')) && true_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && true_pos_arr[j].to_s.tr(',', '.').to_f >= 0
            if  numeric?(false_pos_arr[j].to_s.tr(',', '.')) && false_pos_arr[j].to_s.tr(',', '.').to_f <= 100 && false_pos_arr[j].to_s.tr(',', '.').to_f >= 0
              output_dat_arr[j] = "#{true_pos_arr[j]} #{false_pos_arr[j]}"
            else
              raise "The data #{plot_data[i].inspect}  has not the right formatin at position #{j}\n"+
                    "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
            end
          else
            raise "The data #{plot_data[i].inspect}  has not the right formatin at position #{j}+\n"
                   "The right format is one float/int from 0 to 100 each line (e.g. '0'; '23,34'; '65.87' or '99')"
          end
        end
        #-----------------------------------------------------
        #write *.dat files
        #-----------------------------------------------------
        #write output_dat_arr content in new *.dat file
        tmp_file = Tempfile.new("data#{i}.dat")
        tmp_datasets << tmp_file
        tmp_file.puts output_dat_arr
        tmp_file.close
        output_dat_arr.clear
      else
        raise "num x-values != y-values: "+plot_data[i].inspect
      end
    end
    LOGGER.debug "plot lines -- datasets "+tmp_datasets.collect{|d| d.path}.inspect
    
    # -----------------------------------------------------
    # create *.plt file for gnuplot
    # -----------------------------------------------------
    # 
    output_plt_arr = Array.new
    output_plt_arr.push "# Specifies encoding and output format"
    output_plt_arr.push "set encoding default"
    #output_plt_arr.push "set terminal svg"
    if path=~/(?i)svg/
      output_plt_arr.push 'set terminal svg size 800,600 dynamic enhanced fname "Arial" fsize 12 butt'
    elsif path=~/(?i)png/
      output_plt_arr.push 'set terminal png'
    else
      raise "format not supported "+path.to_s
    end
    output_plt_arr.push "set output '#{path}'"
    output_plt_arr.push ""
    output_plt_arr.push "# Specifies the range of the axes and appearance"
    
    # x and y have equal scale
    output_plt_arr.push 'set size ratio -1'
    
    output_plt_arr.push "set xrange [0:100]"
    output_plt_arr.push "set yrange [0:100]"
    output_plt_arr.push "set grid lw 0.5"
    output_plt_arr.push "set title \"#{title}\""
    if plot_data.size>10
      output_plt_arr.push "set nokey"
    else
      output_plt_arr.push "set key below"
    end
    #output_plt_arr.push "set key invert reverse Left outside"
    output_plt_arr.push "set xlabel \"#{x_lable}\""
    output_plt_arr.push "set ylabel \"#{y_lable}\""
    output_plt_arr.push "set arrow from 0,0 to 100,100 nohead lt 0"
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push ""
    output_plt_arr.push "# Draws the plot and specifies its appearance ..."
    
    type = 1
    plot_data.each do |p|
      if p.labels
        p.labels.each do |label|
          l = label[0]
          x = label[1]
          y = label[2]
          #puts l.to_s+" "+x.to_s+" "+y.to_s
          #output_plt_arr.push "set label \"("+x.to_s+","+y.to_s+") "+l.to_s+"\" at first 25, first 40"
          output_plt_arr.push "set label \""+l.to_s+"\" at first "+x.to_s+", first "+y.to_s+" front offset 1,-1 tc lt "+type.to_s
          output_plt_arr.push "set arrow from "+(x+3).to_s+","+(y-3).to_s+" to "+(x+1).to_s+","+(y-1).to_s+" lt "+type.to_s
        end
      end    
      type += 1
    end
    
    output_plt_arr.push "plot \\"#'random_0.dat' using 1:2 title 'random' with lines lw 1, \\"
    i = 0
    for i in 0..plot_data.length-1
      
      #style = grey[i] ? "lw 1.5 lt 0" : "lw 3" 
      style = plot_data[i].faint ? "lw 2" : "lw 4"
      
      if i == plot_data.length-1
        output_plt_arr.push " '"+tmp_datasets[i].path+"'  using 2:1 title '#{plot_data[i].name}' with lines #{style}"
      else
        output_plt_arr.push " '"+tmp_datasets[i].path+"'  using 2:1 title '#{plot_data[i].name}' with lines #{style}, \\"
      end
    end
    output_plt_arr.push ""
    output_plt_arr.push ""
    
    # -----------------------------------------------------
    # write *.plt files
    # -----------------------------------------------------
    # write output_dat_arr content in new *.dat file
    tmp_file = Tempfile.new("config.plt")
    tmp_datasets << tmp_file
    tmp_file.puts output_plt_arr
    tmp_file.close
    
    # start gnuplot with created *.plt file
    cmd = "gnuplot "+tmp_file.path+" 2>&1"
    LOGGER.debug "plot lines -- running gnuplot '"+cmd+"'"
    response = ""
    IO.popen(cmd) do |f| 
      while line = f.gets
        response += line
      end
    end
    raise "gnuplot failes (cmd: "+cmd.to_s+", out: "+response.to_s+")" unless $?==0
    LOGGER.info "plot lines -- RESULT: #{path}"
    
    # -----------------------------------------------------
    # remove *.plt and *.dat files
    # -----------------------------------------------------
    tmp_datasets.each{|f| f.delete}
  end
 
  def self.test_plot_lines
    #plot_lines("/tmp/result.svg" , "name of title", "x-values", "y-values", ["name", "test", "bla"], [[20,60,80], [10,25,70,95], [12,78,99]], [[15,50,90],[20,40,50,70],[34,89,89]],[true,false,true])
    #plot_lines("/tmp/result.png" , "name of title", "x-values", "y-values", ["name", "test", "bla"], [[20,60,80], [10,25,70,95], [12,78,99]], [[15,50,90],[20,40,50,70],[34,89,89]],[true,false,true],[nil,["confidence",25,40]])
    
    plot_data = []
    plot_data << LinePlotData.new({ :name => "name", :x_values => [20,60,80], :y_values => [15,50,90] })
    plot_data << LinePlotData.new({ :name => "test", :x_values => [10,25,70,95], :y_values => [20,40,50,70], :labels => [["confidence",25,40]] })
    plot_data << LinePlotData.new({ :name => "bla", :x_values => [12,78,99], :y_values =>[34,89,89], :faint => true })
    plot_lines("/tmp/result.png" , "name of title", "x-values", "y-values", plot_data)
  end
 
  private
  # float check
  def self.numeric?(object) 
   true if Float(object) rescue false
  end
end

