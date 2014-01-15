# -*- coding: euc-jp -*-

ENV.store("DCLENVCHAR","_") # ":"をbashでも使えるようにする
ENV.store("SW_LDUMP","true") # trueならXのダンプファイルを裏画面で作成
ENV.store("SW_LWAIT","false") # falseなら改ページのタイミングで一時停止しない
ENV.store("SW_LWAIT1","false") # falseならデバイスをクローズするときに一時停止しない


DCMODEL_THUM_ORIGIN = "/home/ykawai/dcmodel-thum.rb"
Depths=[0,100,500,1000,2500,5000]

def create_fig()
Depths.each{|depth|
  `gpview woa13_decav_t00_01.nc@t_an,depth=#{depth} --range -3:35 --int 2.5 --title "temperature at depth #{depth}m(annual mean)" --wsn 4`
  `mv dcl_001.png temp_d#{depth}_annual.png`

  `gpview woa13_decav_t13_01.nc@t_an,depth=#{depth} --range -3:35 --int 2.5 --title "temperature at depth #{depth}m(Winter:Jan-Mar)" --wsn 4`
  `mv dcl_001.png temp_d#{depth}_winter.png`

  `gpview woa13_decav_t15_01.nc@t_an,depth=#{depth} --range -3:35 --int 2.5 --title "temperature at depth #{depth}m(Summer:Jul-Sep)" --wsn 4`
  `mv dcl_001.png temp_d#{depth}_summer.png`
#
#
  `gpview woa13_decav_s00_01.nc@s_an,depth=#{depth} --range -4:42 --int 2.5 --title "salnity at depth #{depth}m(annual mean)" --wsn 4`
  `mv dcl_001.png sal_d#{depth}_annual.png`

  `gpview woa13_decav_s13_01.nc@s_an,depth=#{depth} --range -4:42 --int 2.5 --title "salinity at depth #{depth}m(Winter:Jan-Mar)" --wsn 4`
  `mv dcl_001.png sal_d#{depth}_winter.png`

  `gpview woa13_decav_s15_01.nc@s_an,depth=#{depth} --range -4:42 --int 2.5 --title "salinity at depth #{depth}m(Summer:Jul-Sep)" --wsn 4`
  `mv dcl_001.png sal_d#{depth}_summer.png`

}
end

def create_graph2
[0,20,45,55,85].each{|lat|

    `gpview woa13_decav_t00_01.nc woa13_decav_t13_01.nc woa13_decav_t15_01.nc --var t_an,lon=-150,lat=#{lat},time=0,depth=0:2000 --range -3:35  --title "temperature(lat=#{lat},lon=-150)" --wsn 4 --exch --overplot 3`
    `mv dcl_001.png temp_lat#{lat}lon-150.png`

  }


end

def create_thumb
  require "fileutils"
  p "create thumbnail.."
  FileUtils.mkdir(["figdir", "thum-src"])
  FileUtils.cp(DCMODEL_THUM_ORIGIN, "thum-src/")
  FileUtils.cp(Dir.glob("{sal,temp}_*.png"), "figdir")
  Dir.chdir("./thum-src/"){
    `ruby1.8 ./dcmodel-thum.rb`
    `ruby1.8 ./dcmodel-thum-make.rb`
  }
  FileUtils.mv(Dir.glob("./thumbdir/*.png"), ".")
  FileUtils.rm_r(["thumbdir", "figdir", "thum-src"])
  FileUtils.rm(Dir.glob("sample_thum.htm*"))
  FileUtils.rm("thumbdir.SIGEN")
end

#create_fig
create_graph2
create_thumb
