import os
from utils.utils import *
from variables.variables import *
import shutil
import glob

print '========================================================================================'
print '                           Copy all FLIM Data and Rename FIles                                 '
print '========================================================================================'

count = 0
for subject in flim_pop:
    count += 1
    
    print "===================================="
    print "%s. Working on %s" %(count, subject) 
    print "===================================="
    
    src = '/data/pt_nro174/DATA/DATA/%s/FLIM/' %(subject)
    data = mkdir_path(os.path.join("/home/raid2/molloy/Documents/FLIM/%s/" %(subject)))
    
    print'Copying the files now for %s' %(subject)

    pdfs = glob.iglob(os.path.join(src, "*.pdf"))
    for file in pdfs:
        if os.path.isfile(file):
            shutil.copy(file, data)
        else:
            print 'no FLIM pdf files here to copy...'
            
folders = os.path.join("/home/raid2/molloy/Documents/FLIM/")
for folder in os.listdir(folders):
    os.rename(str(os.path.join(folders, folder)), 
              str(os.path.join(folders, folder[4:])))
print "Directories now renamed"