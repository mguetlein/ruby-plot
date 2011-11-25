require "tempfile"

module RubyPlot

  def self.box_plot(path, title, y_lable, names, values)
    
    LOGGER.debug "plot box -- names   "+names.inspect
    LOGGER.debug "plot box -- values       "+values.inspect
    
#    STDOUT.sync = true
    raise if names.length != values.length
    gnuplot = '/home/martin/software/gnuplot-dev/install/bin/gnuplot'
    
    tmp_datasets = []
    tmp_file = Tempfile.new("data.dat")
    tmp_datasets << tmp_file
    value_string = []
    values.first.size.times do |i|
      v = ""
      values.each do |val|
        v += val[i].to_s+" "
      end
      value_string << v.to_s
    end
    #puts value_string.join("\n")
    
    tmp_file.puts value_string.join("\n")
    tmp_file.close
    LOGGER.debug "plot box -- dataset "+tmp_datasets.collect{|d| d.path}.inspect
    
    #"name1" 1, "name2" 2, "name3" 3 ...
    xtics_string = ""
    names.size.times do |i|
      xtics_string += "\""+names[i].to_s+"\" "+(i+1).to_s
      xtics_string += ", " if i<names.size-1
    end
    #puts xtics_string
    
    #plot '#{tmp_file.path}' using (1):1, '' using (2):2, '' using (3):3 ...
    plot_string = "plot '#{tmp_file.path}' using (1):1"
    if names.size>1
      plot_string += ","
      names.size.times do |i|
        if i>0
          plot_string += " '' using (#{i+1}):#{i+1}"
          plot_string += "," if i<names.size-1
        end
      end
    end
    #puts plot_string
    #exit
    
    plt = <<EOF
set terminal svg
set output '#{path}'
set border 2 front linetype -1 linewidth 1.000
set boxwidth 0.75 absolute
set style fill solid 0.25 border lt -1
unset key
set pointsize 0.5
set style data boxplot
set xtics border in scale 0,0 nomirror rotate  offset character 0, 0, 0
set xtics  norangelimit
set xtics (#{xtics_string})
set ytics border in scale 1,0.5 nomirror norotate  offset character 0, 0, 0
#set yrange [ 0.00000 : 100.000 ] noreverse nowriteback
#plot '#{tmp_file.path}' using (1):1, '' using (2):2, '' using (3):3
EOF
    
    plt += plot_string
   #puts plt
    #exit
    
    tmp_file = Tempfile.new("config.plt")
    tmp_datasets << tmp_file
    tmp_file.puts plt
    tmp_file.close
    
    # start gnuplot with created *.plt file
    cmd = gnuplot+" "+tmp_file.path+" 2>&1"
    LOGGER.debug "plot box -- running gnuplot '"+cmd+"'"
    response = ""
    IO.popen(cmd) do |f| 
      while line = f.gets
        response += line
      end
    end
    raise "gnuplot failes (cmd: "+cmd.to_s+", out: "+response.to_s+")" unless $?==0
    LOGGER.info "plot box -- RESULT: #{path}"
    
    tmp_datasets.each{|f| f.delete}
  end
 
  def self.test_plot_box
#    regression_point_plot("/tmp/regression.png" , "name of title", "x-values", "y-values", ["this-one-has-a-very-very-very-long-name", "test" ], 
#      [[0.20,0.60,0.80,0.20,1.0,0.001], [0.10,0.25,0.70,0.95,0.2,0.3434]], 
#      [[0.15,0.50,0.90,0.2,9,0.5],[0.20,0.40,0.50,0.70,0.3,0.234589]])
#    accuracy_confidence_plot("/tmp/accuracy-conf.png" , "name of title", "x-values", "y-values", ["test" ], 
#      [[0.9,0.5,0.3,0.1]],
#      [[100,90,70,30]])
    x=[]; y=[]; z=[]; zz=[]
    30.times do
      x << 5 + rand * 4 * (rand<0.5 ? 1 : -1)
      y << 5 + rand * 5 * (rand<0.5 ? 1 : -1)
      z << 5 + rand * 6 * (rand<0.5 ? 1 : -1)
      zz << 5 + rand * 5 * (rand<0.5 ? 1 : -1)
    end

    box_plot("/tmp/test-plot.svg" , "name of title", "values", ["x","y","z","zz"], [x,y,z,zz])
  end
 
end

