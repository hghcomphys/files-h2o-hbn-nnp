###############################################################################
# MD simulation for water-NNP
# hgh.comphys@gmail.com
###############################################################################

###############################################################################
# VARIABLES
###############################################################################
# Configuration files
variable cfgFile         string "systems/w-hbn-rlx.lmp.w73"
# Timesteps
variable dt              equal  0.0005
# NN
variable nnpCutoff       equal  6.36
variable nnpDir          string "./"

###############################################################################
# GENERAL SETUP
###############################################################################
units metal   # METAL!!!
boundary p p p
atom_style full
read_data ${cfgFile}
#read_restart ${cfgFile}
replicate 1 1 1

###############################################################################
# NN
###############################################################################
pair_style nnp dir ${nnpDir} showew no showewsum 0 resetew yes maxew 10000 cflength 1.8897261328 cfenergy 0.0367493 # eV -> Hartree !!!
pair_coeff * * ${nnpCutoff}

###############################################################################
# SETTING
###############################################################################
group           sub type 2 3
group           wat type 1 4

#dump           pbc all atom 400 dump.lammpstrj
dump            1 all xyz 400 dump.xyz
dump_modify     1 sort id element H B N O

variable dl     equal 3.5  # O-B/N (average)
variable vp     equal (lx*ly*(lz-v_dl))  # effective volume
variable        dens equal (mass(wat)/v_vp*1.66054) # gr/cm3

timestep ${dt}
thermo 10
thermo_style    custom step temp etotal pe press lx ly lz v_dens

###############################################################################
# SIMULATION
###############################################################################

############################## minimization

#fix 		    1 all box/relax iso 0.0
#min_style 	    cg
#minimize       0.0 1.0e-8 100 1000
#unfix		    1

##############################

variable T      equal 300
variable P      equal 1.0
velocity   		wat create 1 2344 dist gaussian mom yes rot yes
velocity   		sub create 1 5234 dist gaussian mom yes rot yes

# ================= NPT

fix             rlx all npt temp $T $T 0.05 aniso $P $P 0.5
run 			1000
unfix			rlx

write_data      w-hbn-rlx.lmp.npt

# ================= NVT

fix             rlx all nvt temp $T $T 0.05
run 			1000
unfix			rlx

write_data      w-hbn-rlx.lmp.nvt

# ================= NVE

#fix            rlx all nve
#run 			1000
#unfix			rlx

#write_data      w-hbn-rlx.lmp.nve

######################################################## Equil. Parameters

variable numSteps   equal  4000000
reset_timestep 0

# ====================

compute         force sub group/group wat
variable        fx equal c_force[1]
variable        fy equal c_force[2]

# ====================

compute     Tw wat temp
compute     peratom wat stress/atom Tw
compute     sxx wat   reduce sum c_peratom[1]
compute     syy wat   reduce sum c_peratom[2]
compute     szz wat   reduce sum c_peratom[3]
compute     sxy wat   reduce sum c_peratom[4]
compute     sxz wat   reduce sum c_peratom[5]
compute     syz wat   reduce sum c_peratom[6]

variable    pxy  equal   -c_sxy/v_vp
variable    pxz  equal   -c_sxz/v_vp
variable    pyz  equal   -c_syz/v_vp
variable    pzz  equal   -c_szz/v_vp
variable    plat equal   -(c_sxx+c_syy)/(2*v_vp)
variable    pcnf equal   -(c_szz)/v_vp

# ====================

variable    p equal 500    # correlation length
variable    s equal 2      # sample interval
variable    d equal $p*$s  # dump interval 

# =================== CORRELATIONS
fix         SS wat ave/correlate $s $p $d v_fx v_fy v_pxz v_pyz type auto ave running #file correlate.dat 
# =================== 

# =================== DIFFUSION (lateral)
compute         msd wat msd com yes
fix             msd_vecx wat vector 50 c_msd[1]
variable        Dx equal slope(f_msd_vecx)/(50*dt*1E3)/2*1.0E3 #(A^2/ps)
fix             msd_vecy wat vector 50 c_msd[2]
variable        Dy equal slope(f_msd_vecy)/(50*dt*1E3)/2*1.0E3 #(A^2/ps)
variable        Dlat equal (v_Dx+v_Dy)/2
# ===================

# =================== FRICTION [Bocquet and Barrat]
variable    area   equal (lx*ly)*2  # PBC (two surfaces: front and back)
variable    coef   equal ($s*dt*1E3)*(503.2282/$T/v_area)*6.95/529 #(1E4 N.s/m^3)!!! 
variable    kxx    equal trap(f_SS[3])*${coef}
variable    kyy    equal trap(f_SS[4])*${coef}
variable    ksi    equal (v_kxx+v_kyy)/2 #(1E4 N.s/m^3)
# ==================

# =================== VISCOSITY
variable    volume  equal v_vp # effective volume
variable    scale   equal ($s*dt*1E3)*(0.0072954/$T)*1.01325E5*1E-11*0.974017  #(1E-4 Pa*s/atm^2)
variable    vxz     equal trap(f_SS[5])*${scale}*v_volume 
variable    vyz     equal trap(f_SS[6])*${scale}*v_volume  
variable    eta     equal (v_vxz+v_vyz)/2  #Pa*s (*1E-4)
# ==================

thermo          $d
thermo_style    custom step temp etotal press v_dens v_Dlat v_kxx v_kyy v_ksi v_eta

# --------------

fix        		 rlx all nvt temp $T $T 0.05 
run 			 ${numSteps}

# --------------
