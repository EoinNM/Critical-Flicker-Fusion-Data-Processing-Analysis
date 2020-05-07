import os
from utils.utils import *
from variables.variables import *
import textract
import pandas as pd
import csv


print '================================================================='
print '                          Get FLIM Data                          '
print '================================================================='

for subject in population:
    for day in days:
    
        print "===================="
        print "Working on %s %s" %(subject, day) 
        print "===================="
        
# Part 1 - Get the data from the pdf files and format them to remove all the weird extra lines
        text = textract.process('/home/raid2/molloy/Documents/FLIM/%s/%s_%s.pdf' %(subject, subject, day))
        print "...and printing it now to a text file"
        file1= open(r'/home/raid2/molloy/Documents/FLIM/%s/%s_%s.txt' %(subject, subject, day), 'a')
        file1.writelines(text)
        with open('/home/raid2/molloy/Documents/FLIM/%s/%s_%s.txt' %(subject, subject, day)) as infile, open('/home/raid2/molloy/Documents/FLIM/%s/%s_%s.txt' %(subject, subject, day), 'w') as outfile:
                for line in infile:
                    if not line.strip(): continue
                    outfile.write(line)
                    
# Part 2 - Get the flicker and the fusion data from the text files and append to a .csv
with open ("FLIM_Data.csv", 'a') as f:
    thewriter=csv.writer(f)
    thewriter.writerow(['SubID', 'Day', 'Measure', 'Score'])     
for subject in population:
    for day in days:    
        fp = open(r'/home/raid2/molloy/Documents/FLIM/%s/%s_%s.txt' %(subject, subject, day))
        with open ("FLIM_Data.csv", 'a') as f:
            thewriter=csv.writer(f)
            for i, line in enumerate(fp):
                if i == 14:
                    thewriter.writerow([subject, day, 'Fusion', line])
                elif i == 15:
                    thewriter.writerow([subject, day, 'Flicker', line])
                        
print 'Done - data now in a dataframe'