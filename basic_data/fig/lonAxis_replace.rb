require "numru/ggraph"
include NumRu

def replaceAxis(ncfileName, varName)
  ncfile = NetCDF.open(ncfileName, "a")
  gp = GPhys::IO.open(ncfile, varName)
  lon = gp.axis("lon").pos
  lon2 = lon.copy
  minusIds = (lon2<0.0).where
  lon2[minusIds] = lon2[minusIds] + 360.0
  lon2.set_att("modulo", "180.0")
  lon2.set_att("topology", "circular")

 p lon2

  gp2 = gp.copy
  iMax = lon2.length
  p "iMax:#{iMax/2}"
#p gp.shape
  gp2[0..179,true,true,true] = gp[180..359,true,true,true]
  gp2[180..359,true,true,true] = gp[0..179,true,true,true]

#  gp2[true,true,true,iMax/2..iMax-1] = gp[true,true,true,0..iMax/2-1]
  gp2.set_att("_FillValue", gp.get_att("_FillValue"))
  #gp2.axis("lon").set_pos(lon2)
  ncfile.close

p lon2.axis_modulo
  newncfileName = ncfileName.sub("\.nc","_#{varName}.nc")
p newncfileName
  newncfile = NetCDF.create(newncfileName)
  GPhys::NetCDF_IO.write(newncfile, gp2)
  newncfile.close
end

[ "./sal/woa13_decav_s00_01.nc", 
  "./sal/woa13_decav_s13_01.nc", 
  "./sal/woa13_decav_s15_01.nc"
].each{|file|
  replaceAxis(file, "s_an")
}

[ "./temp/woa13_decav_t00_01.nc", 
  "./temp/woa13_decav_t13_01.nc", 
  "./temp/woa13_decav_t15_01.nc"
].each{|file|
  replaceAxis(file, "t_an")
}

#[ "./oxy/dissolved_oxygen_annual_1deg.nc",
#  "./oxy/dissolved_oxygen_seasonal_1deg.nc",
#].each{|file|
#  replaceAxis(file, "o_an")
#}
#
#replaceAxis("./oxy/oxygen_saturation_annual_1deg.nc", "O_an") 
