# -*- coding: euc-jp -*-

######################################################################
# NOAA が提供する海洋データ(NetCDF 形式) から図を生成するための Ruby スクリプト
#
######################################################################

require "fileutils"

##################################################

GPVIEW_CMD = (`pwd`).chomp! + "/gpview"
DCMODEL_THUM_ORIGIN = "/home/ykawai/dcmodel-thum.rb"

##################################################

#
TEMP_RANGE = "-3:32"
TEMP_INT = 2.0
TEMP_NCFILES = [
  "woa13_decav_t00_01_t_an.nc", "woa13_decav_t15_01_t_an.nc", "woa13_decav_t13_01_t_an.nc"
]
TEMP_TIMES = ["0", "0", "0"]

#
SAL_RANGE = "25:40"
SAL_INT = 1.0
SAL_NCFILES =  [
 "woa13_decav_s00_01_s_an.nc", "woa13_decav_s15_01_s_an.nc", "woa13_decav_s13_01_s_an.nc"
]
SAL_TIMES = ["0", "0", "0"]

#
OXY_RANGE = "0:12"
OXY_INT = 1.0
OXY_NCFILES =  [
 "dissolved_oxygen_annual_1deg.nc", "dissolved_oxygen_seasonal_1deg.nc", "dissolved_oxygen_seasonal_1deg.nc"
]
OXY_TIMES = ["0", "136", "320"]

#
SATOXY_RANGE = "0:110"
SATOXY_INT = 10.0
SATOXY_NCFILES =  [
"oxygen_saturation_annual_1deg.nc"
]
SATOXY_TIMES = ["0"]


#########################################

Periods = [
 "annual", "summer", "winter"
]
MERIODFIG_SampLons = [ 10, -90, 155 ]
HORIFIG_SampDepths=[0,100,500,1000,2500,5000]

############################################

# Configuration for gpview

ENV.store("DCLENVCHAR","_") # ":"をbashでも使えるようにする
ENV.store("SW_LDUMP","true") # trueならXのダンプファイルを裏画面で作成
ENV.store("SW_LWAIT","false") # falseなら改ページのタイミングで一時停止しない
ENV.store("SW_LWAIT1","false") # falseならデバイスをクローズするときに一時停止しない

############################################

def create_horizontalfig(ncfiles, varname, figtitile, range, intrv, times)
  times.each_with_index{|time,i|
    period = Periods[i]
    HORIFIG_SampDepths.each{|depth|
      `#{GPVIEW_CMD} #{ncfiles[i]}@#{varname},depth=#{depth},time=#{times[i]} --range #{range} --int #{intrv} --title "#{figtitile} (d=#{depth}m, #{period})" --wsn 4`
      `mv dcl_001.png #{varname}_d#{depth}_#{period}.png`      
    }
  }

end

def create_meriodinalfig(ncfiles, varname, figtitle, range, sint, times, clevels="", lonOri0=false)

  gpopt = "--range #{range}  --sint #{sint}  --wsn 4"
  if clevels.length > 0 then
    gpopt << " --clevels #{clevels}"
  else
    gpopt << " --cint #{sint}"
  end

  times.each_with_index{|time,i|
    period = Periods[i]
    MERIODFIG_SampLons.each{|lon|

      gplon = (lonOri0) ? 180+lon : lon
      p "gplon:#{gplon}"
      `#{GPVIEW_CMD} #{ncfiles[i]}@#{varname},lon=#{gplon},time=#{times[i]} #{gpopt} --title '#{figtitle} (lon=#{lon}, #{period})'`
      `mv dcl_001.png #{varname}_lon#{lon}_#{period}.png`
    }
    `#{GPVIEW_CMD} #{ncfiles[i]}@#{varname},time=#{times[i]} --mean lon #{gpopt} --title "#{figtitle} (lon mean, #{period})"`
    `mv dcl_001.png #{varname}_lonmean_#{period}.png`

  }
end

def create_meriodinalupperfig(ncfiles, varname, figtitle, range, sint, times, clevels="", lonOri0=false)

  gpopt = "--range #{range}  --sint #{sint}  --wsn 4"
  if clevels.length > 0 then
    gpopt << " --clevels #{clevels}"
  else
    gpopt << " --cint #{sint}"
  end
  
  times.each_with_index{|time,i|
    period = Periods[i]

    MERIODFIG_SampLons.each{|lon|

      gplon = (lonOri0) ? 180+lon : lon
      `#{GPVIEW_CMD} #{ncfiles[i]}@#{varname},lon=#{gplon},time=#{times[i]},depth=0:1000 #{gpopt} --title '#{figtitle} (lon=#{lon}, #{period})'`
      `mv dcl_001.png #{varname}_lon#{lon}_upper_#{period}.png`      
    }

    `#{GPVIEW_CMD} #{ncfiles[i]}@#{varname},time=#{times[i]},depth=0:1000 --mean lon #{gpopt} --title '#{figtitle} (lon mean, #{period})'`
    `mv dcl_001.png #{varname}_lonmean_upper_#{period}.png` 
  }
end

def create_graph2
[0,20,45,55,85].each{|lat|

    `#{GPVIEW_CMD}  --var t_an,lon=-150,lat=#{lat},time=0,depth=0:2000 --range -3:35  --title "temperature(lat=#{lat},lon=-150)" --wsn 4 --exch --overplot 3`
    `mv dcl_001.png temp_lat#{lat}lon-150.png`

  }


end

def create_thumb()
  
  p "create thumbnail.."
  FileUtils.mkdir(["figdir", "thum-src"])
  FileUtils.cp(DCMODEL_THUM_ORIGIN, "thum-src/")
  FileUtils.cp(Dir.glob("*_an_*.png"), "figdir")
  Dir.chdir("./thum-src/"){
    `ruby1.8 ./dcmodel-thum.rb`
    `ruby1.8 ./dcmodel-thum-make.rb`
  }
  FileUtils.mv(Dir.glob("./thumbdir/*.png"), ".")
  FileUtils.rm_r(["thumbdir", "figdir", "thum-src"])
  FileUtils.rm(Dir.glob("sample_thum.htm*"))
  FileUtils.rm("thumbdir.SIGEN")

end


FileUtils.chdir("./temp"){
#  create_horizontalfig(TEMP_NCFILES, "t_an", "temperature", TEMP_RANGE, TEMP_INT, TEMP_TIMES)
  create_meriodinalfig(TEMP_NCFILES, "t_an", "temperature", TEMP_RANGE, TEMP_INT, TEMP_TIMES, "0,1,2,5,10,15,20,25,30")
  create_meriodinalupperfig(TEMP_NCFILES, "t_an", "temperature", TEMP_RANGE, TEMP_INT, TEMP_TIMES, "1,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30")
  create_thumb
}

FileUtils.chdir("./sal"){
#  create_horizontalfig(SAL_NCFILES, "s_an", "salinity", SAL_RANGE, SAL_INT, SAL_TIMES)
  create_meriodinalfig(SAL_NCFILES, "s_an", "salinity", SAL_RANGE, 0.5, SAL_TIMES, "33,34,34.2,34.6,34.7,34.75,34.8,34.9,35,35.2,35.6")
  create_meriodinalupperfig(SAL_NCFILES, "s_an", "salinity", SAL_RANGE, 0.5, SAL_TIMES, "33,34,34.2,34.6,34.8,34.9,35,35.2,35.6")
  create_thumb
}

# FileUtils.chdir("./oxy"){
#   create_horizontalfig(OXY_NCFILES, "o_an", "dissolved oxygen", OXY_RANGE, OXY_INT, OXY_TIMES)
#   create_meriodinalfig(OXY_NCFILES, "o_an", "dissolved oxygen", OXY_RANGE, OXY_INT, OXY_TIMES, "", true)

#   create_horizontalfig(SATOXY_NCFILES, "O_an", "oxygen saturation", SATOXY_RANGE, SATOXY_INT, SATOXY_TIMES)
#   create_meriodinalfig(SATOXY_NCFILES, "O_an", "oxygen saturation", SATOXY_RANGE, SATOXY_INT, SATOXY_TIMES, "", true)

#   create_thumb
#}

