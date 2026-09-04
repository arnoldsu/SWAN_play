###############################################################################
# IA32_GNU:	Intel Core/Xeon with Linux using GNU compiler gfortran.
###############################################################################
F90_SER = gfortran
F90_OMP = gfortran
F90_MPI = mpifort
FLAGS_OPT = -O
# from version 10 and higher, gfortran does not accept argument mismatches; see https://gcc.gnu.org/gcc-10/porting_to.html
FLAGS_MSC = -w -fno-second-underscore -fallow-argument-mismatch
FLAGS90_MSC = $(FLAGS_MSC) -ffree-line-length-none
FLAGS_SER =
FLAGS_OMP = -fopenmp
FLAGS_MPI =
INCS_SER =
INCS_OMP =
INCS_MPI =
LIBS_SER =
LIBS_OMP = -static-libgcc
LIBS_MPI =
OUT = -o 
EXTO = o
MAKE = make
RM = rm -f
swch = -unix
