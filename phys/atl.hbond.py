# -------------------------
# Atomic Tools Library
# hgh.comphys@gmail.comphys
# -------------------------

import numpy as np
import matplotlib.pyplot as plt

# ----------------------------

from sys import argv
s=argv[1:]
print 'Number of arguments:', len(s), 'arguments.'
print 'Argument List:', str(s)

# ----------------------------

f1=1; f2=1000000; f3=1;
if len(s)>1:
    f1=int(s[1]);

if len(s)>2:
    f2=int(s[2]);
    
if len(s)>3:
    f3=int(s[3]);
    
print 'f1,f2,f3=',f1,f2

# ----------------------------

fp = open(s[0],'r')
fout=open('nHB.dat','w')

O_type=3;  print 'O_type',O_type

nAtoms=0
data=None; 
nFrame=0; nf=0;
while 1:
      
    line = fp.readline()
    if not line:
        break

    nAtoms=int( line ); #print nAtoms
    #print "nAtoms:",nAtoms

    fp.readline() #skip line

    data=np.zeros(nAtoms*3)
    data.shape=(nAtoms,3)	
    t=np.zeros(nAtoms,int)
    
	# ------------------------
	
    if (nFrame+1)>=f1 and (nFrame+1)%f3==0:
        
        if f1<0: # reset to get last frame
            nf=0; data[:,:]=0.

        nf+=1
        for i in range(nAtoms):
            line=fp.readline(); #print line
            line=line.rstrip("/n").split()           
            data[i,:]=np.array( [float(x) for x in line[1:]]  )
            t[i]=int(line[0])

    else:
        
        for i in range(nAtoms):
            fp.readline();
	
    # ------------	
    nFrame+=1; 
    #print "Frame",nFrame

    if nFrame>=f2:
        break;
    
    if nFrame<f1 or nFrame%f3!=0:
        continue

    # =======================================
    
    x=data[:,0]; y=data[:,0]; z=data[:,0]; d=data[:,:];
    #print x,y,z,t

    # determining O atoms
    a_O=[]; 
    for i in range(nAtoms-2):
        if t[i]==O_type:    
            if t[i+1]!=O_type and t[i+2]!=O_type:           
                a_O.append( i );
    nO=len(a_O);
    
    # ---------------------------------------- 
    
    nHB=0.; 
    for i in a_O:
        for j in a_O:
            
            if i==j: continue
        
            # O-O distance
            r2=(x[i]-x[j])**2+(y[i]-y[j])**2+(z[i]-z[j])**2
            if r2<3.6**2:
                
                # O-H distance
                for ih in range(1,3):
                    r2=(x[i+ih]-x[j])**2+(y[i+ih]-y[j])**2+(z[i+ih]-z[j])**2
                    if r2<2.45**2:
                        
                        # OH-O angle
                        r1=d[j,:]-d[i,:]; r1/=np.linalg.norm(r1)
                        r2=d[i+ih,:]-d[i,:]; r2/=np.linalg.norm(r2)
                        angle=np.arccos(np.dot(r1,r2))*57.296 #deg
                        if angle<30.: #0.86600:                           
                            nHB+=1
                            
    nHB=nHB/nO;   
    print "nAtoms:",nAtoms
    print 'frm nO nHB/nO:',nFrame,nO,nHB
    
    fout.write("%d %f\n"%(nFrame,nHB) ) 
    fout.flush()
    
    # ---------------
    
fp.close()

# -------------------------------
print 'total frame:',nFrame
print 'readed frame:',nf
