function FixRowBrightnessProtect(clip c, int row, int adj_val, int prot_val){
	prot_val = Default(prot_val, 16)
    c
	working="x 16 - " + string(100-adj_val) + " / 100 * 16 + x " + string(255-prot_val) + " - -10 / 0 max 1 min * x x " + string(245-prot_val) + " - 10 / 0 max 1 min * +"
	mt_lut(working)
    ConvertToY8().Crop(0,row,0,1)
    Overlay(c,last,0,row,mode="luma")
}

function FixColumnBrightnessProtect(clip c, int column, int adj_val, int prot_val){
	prot_val = Default(prot_val, 16)
    c
	working="x 16 - " + string(100-adj_val) + " / 100 * 16 + x " + string(255-prot_val) + " - -10 / 0 max 1 min * x x " + string(245-prot_val) + " - 10 / 0 max 1 min * +"
	mt_lut(working)
    ConvertToY8().Crop(column,0,1,0)
    Overlay(c,last,column,0,mode="luma")
}