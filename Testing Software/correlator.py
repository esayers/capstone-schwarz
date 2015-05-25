import numpy

File_Name_A = None
File_Name_B = None

while not File_Name_A:
	File_Name_A = input('input file A''s extention: ')
	try:
		A = numpy.loadtxt(File_Name_A,numpy.float32)
	except FileNotFoundError:
		print('The file was not found.')
		File_Name_A = None

while not File_Name_B:
	File_Name_B = input('Input file B''s extention: ')
	try: 
		B = numpy.loadtxt(File_Name_B,numpy.float32)
	except FileNotFoundError:
		print('The file was not found.')
		File_Name_B = None
C = A - B
print (C)