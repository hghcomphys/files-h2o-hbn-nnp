import numpy as np

# ----------------------------

from sys import argv
s=argv[1:]
print ('Number of arguments:', len(s), 'arguments.')
print ('Argument List:', str(s))

# ----------------------------

O_type='O'
if len(s)>1:
    O_type=s[1]
print ('O-type (1):', O_type)

H_type='H'
if len(s)>2:
    H_type=s[2]
print ('H-type (2):', H_type)

start_indx=0;
if len(s)>2:
    start_indx=int(s[3])
print ('starting index:', start_indx)

# ----------------------------

fp=open(s[0],'r')
nAtoms=0; nFrame=0;
data=None; tt=[]; 
while 1:
      
    line = fp.readline()
    if not line:
        break

    nAtoms=int( line ); #print nAtoms
    if nFrame==0:
      print ("nAtoms:", nAtoms)
    fp.readline()

    if data is None:
        data=np.zeros(nAtoms*3)
        data.shape=(nAtoms,3)   
    
    # ------------------------
    
    if nFrame<1:   
       
       for i in range(nAtoms):
        
        line=fp.readline(); #print line
        line=line.rstrip("/n").split()
        
        if len(tt)<nAtoms:
          tt.append( line[0] )
        
        # Summing over all frames
        data[i,:]+=np.array( [float(x) for x in line[1:]]  )    
        
        nFrame+=1; 

fp.close()
d=np.array(data)

# ----------------------------

a_x=d[:,0]; a_y=d[:,1]; a_z=d[:,2]; 
N=len(a_x); 

print ("Atoms", N)

bonds=[]; angles=[]
for i in range(N):
  
  if tt[i]!=O_type: continue; # O atom
  
  a_id=int( start_indx+i+1 );
  bonds.append( [a_id,a_id+1] )
  bonds.append( [a_id,a_id+2] )
  angles.append( [a_id+1,a_id,a_id+2] )
  
## ------------------------------------------
  
print ("Bonds",len(bonds))
##print bonds

print ("Angles",len(angles))
##print angles

f=open("tip3p.dat","w")

#f.write("Atoms\n\n")
for i in range(N):
  
  type2num=1
  if tt[i]==O_type: 
      type2num=3
  elif tt[i]==H_type:
      type2num=2
      
  #f.write( "%d %d %d %1.3f %f %f %f\n"%(start_indx+i+1,i/3+1,type2num,0,a_x[i],a_y[i],a_z[i]) )

f.write("\n\nBonds\n\n")
for i in range(len(bonds)):
  f.write( "%d %d %d %d\n"%(i+1,1,bonds[i][0],bonds[i][1]) )

f.write("\n\nAngles\n\n")
for i in range(len(angles)):
  f.write( "%d %d %d %d %d\n"%(i+1,1,angles[i][0],angles[i][1],angles[i][2]) )

print ('atom charges should be set later!')
print ('Output file: tip3p.dat')
      
  
      
