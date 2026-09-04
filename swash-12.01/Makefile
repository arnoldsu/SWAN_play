# ------------------------------------------------------------------------------
#                      Makefile for building SWASH program and documentation
# ------------------------------------------------------------------------------
#
# Before compilation, type "make config" first!
#
# To compile the serial executable type "make ser"
# To compile the MPI executable type "make mpi"
#
# To remove compiled objects and modules: type "make clean"
#
# To remove compiled objects, modules and executable: type "make clobber"
#
# To compile the SWASH documentation type "make doc"
#
# To compile the html pages of SWASH documentation type "make html"
#
# To remove the PDF and HTML documents type "make cleandoc"
#
# Please do not change anything below, unless you're very sure what you're doing
# ------------------------------------------------------------------------------

include macros.inc

SWASH_EXE = swash.exe

SWASH_OBJS = \
ocpmod.$(EXTO) \
SwashModule1.$(EXTO) \
SwashModule2.$(EXTO) \
m_parall.$(EXTO) \
SwanGriddata.$(EXTO) \
SwanGridobjects.$(EXTO) \
SwanCompdata.$(EXTO) \
SwashFlowdata.$(EXTO) \
SwashSolvedata.$(EXTO) \
SwashRigBoddata.$(EXTO) \
Swash.$(EXTO) \
SwashMain.$(EXTO) \
SwashInit.$(EXTO) \
SwashReadInput.$(EXTO) \
SwashReadTestpnts.$(EXTO) \
SwashInputGrid.$(EXTO) \
SwashInputField.$(EXTO) \
SwanReadGrid.$(EXTO) \
SwanReadADCGrid.$(EXTO) \
SwanReadTriangleGrid.$(EXTO) \
SwanReadEasymeshGrid.$(EXTO) \
SwashCheckGrid.$(EXTO) \
SwanCreateEdges.$(EXTO) \
SwanGridTopology.$(EXTO) \
SwanGridVert.$(EXTO) \
SwanGridCell.$(EXTO) \
SwanGridFace.$(EXTO) \
SwashBndTopology.$(EXTO) \
SwashPrintGridInfo.$(EXTO) \
SwashInitCompGrid.$(EXTO) \
SwashInitCompUgrid.$(EXTO) \
SwashInitCond.$(EXTO) \
SwashBackup.$(EXTO) \
SwashBounCond.$(EXTO) \
SwanBpntlist.$(EXTO) \
SwashBCspecfile.$(EXTO) \
SwashBCspectrum.$(EXTO) \
SwashBCshortwave.$(EXTO) \
SwashBCboundwave.$(EXTO) \
SwashBCStokeswave.$(EXTO) \
SwashBCtransferfnc.$(EXTO) \
SwashIntWavgen.$(EXTO) \
SwashReqOutL.$(EXTO) \
SwashReqOutQ.$(EXTO) \
SwashCheckPrep.$(EXTO) \
SwashGeometrics.$(EXTO) \
SwashSpongeLayer.$(EXTO) \
SwashUSpongLayer.$(EXTO) \
SwashPrintSettings.$(EXTO) \
SwashFlowDP.$(EXTO) \
SwashFlowUDP.$(EXTO) \
SwashFloatObjects.$(EXTO) \
SwashUpdateData.$(EXTO) \
SwashUpdateUData.$(EXTO) \
SwashReadBndval.$(EXTO) \
SwashUpdateFld.$(EXTO) \
SwashUpdFlowFlds.$(EXTO) \
SwashUpdUFlowFlds.$(EXTO) \
SwashUpdPress.$(EXTO) \
SwashUpdUPress.$(EXTO) \
SwashUpdateDepths.$(EXTO) \
SwashUpdateUDepths.$(EXTO) \
SwashLayerIntfaces.$(EXTO) \
SwashLayUIntfaces.$(EXTO) \
SwashUpdDepu.$(EXTO) \
SwashUpdUDepu.$(EXTO) \
SwashInitSteady.$(EXTO) \
SwashInitBCtrans.$(EXTO) \
SwashInitBCUtrans.$(EXTO) \
SwashServices.$(EXTO) \
SwashUServ.$(EXTO) \
SwashSolvers.$(EXTO) \
SwashBotFrict.$(EXTO) \
SwashUBotFrict.$(EXTO) \
SwashLogLaw.$(EXTO) \
SwashULogLaw.$(EXTO) \
SwashPorousStruc.$(EXTO) \
SwashPorFricDep.$(EXTO) \
SwashPorFricLay.$(EXTO) \
SwashWindStress.$(EXTO) \
SwashUWindStress.$(EXTO) \
SwashVeget.$(EXTO) \
SwashDensity.$(EXTO) \
SwashHorzVisc.$(EXTO) \
SwashUHorzVisc.$(EXTO) \
SwashVertVisc.$(EXTO) \
SwashKepsMod1DH.$(EXTO) \
SwashKepsMod2DH.$(EXTO) \
SwashUKepsMod.$(EXTO) \
SwashReynoldsStress.$(EXTO) \
SwashAmbCurrent.$(EXTO) \
SwashComputStruc.$(EXTO) \
SwashCompUnstruc.$(EXTO) \
SwashComputFlow.$(EXTO) \
SwashCompUFlow.$(EXTO) \
SwashComputTrans.$(EXTO) \
SwashCompUTrans.$(EXTO) \
SwashComputTurb.$(EXTO) \
SwashCompUTurb.$(EXTO) \
SwashDryWet.$(EXTO) \
SwashUDryWet.$(EXTO) \
SwashPresFlow.$(EXTO) \
SwashBreakPoint.$(EXTO) \
SwashUBreakPoint.$(EXTO) \
SwashAverOutp.$(EXTO) \
SwashImpDep1DHflow.$(EXTO) \
SwashExpDep1DHflow.$(EXTO) \
SwashImpDepM1DHflow.$(EXTO) \
SwashImpLay1DHflow.$(EXTO) \
SwashImpLayM1DHflow.$(EXTO) \
SwashImpLayP1DHflow.$(EXTO) \
SwashExpLay1DHflow.$(EXTO) \
SwashExpLayP1DHflow.$(EXTO) \
SwashImpDep2DHflow.$(EXTO) \
SwashExpDep2DHflow.$(EXTO) \
SwashImpDepM2DHflow.$(EXTO) \
SwashImpLay2DHflow.$(EXTO) \
SwashImpLayP2DHflow.$(EXTO) \
SwashExpLay2DHflow.$(EXTO) \
SwashExpLayP2DHflow.$(EXTO) \
SwashExpDep1DHtrans.$(EXTO) \
SwashExpLay1DHtrans.$(EXTO) \
SwashExpDep2DHtrans.$(EXTO) \
SwashExpLay2DHtrans.$(EXTO) \
SwashExpDepUflow.$(EXTO) \
SwashImpDepUflow.$(EXTO) \
SwashExpLayUflow.$(EXTO) \
SwashImpLayUflow.$(EXTO) \
SwashExpDepUtrans.$(EXTO) \
SwashExpLayUtrans.$(EXTO) \
SwashAntiCreep1DH.$(EXTO) \
SwashAntiCreep2DH.$(EXTO) \
SwashHDiffZplane1DH.$(EXTO) \
SwashHDiffZplane2DH.$(EXTO) \
SwashUpdKBCrigb.$(EXTO) \
SwashForcesRigidBod.$(EXTO) \
SwashMotionRigidBod.$(EXTO) \
SwanFindPoint.$(EXTO) \
SwanPointinMesh.$(EXTO) \
SwashOutput.$(EXTO) \
SwashDecOutL.$(EXTO) \
SwashDecOutQ.$(EXTO) \
SwashCoorOutp.$(EXTO) \
SwashQuanOutp.$(EXTO) \
SwashElemOutp.$(EXTO) \
SwashHydroLoads.$(EXTO) \
SwashFlobjOutp.$(EXTO) \
SwashRunupHeight.$(EXTO) \
SwanInterpolatePoint.$(EXTO) \
SwanInterpolateOutput.$(EXTO) \
SwashVTKWriteHeader.$(EXTO) \
SwashVTKWriteData.$(EXTO) \
SwashVTKPDataSets.$(EXTO) \
SwashCleanMem.$(EXTO) \
ocpids.$(EXTO) \
ocpcre.$(EXTO) \
ocpmix.$(EXTO) \
swanser.$(EXTO) \
swanout2.$(EXTO) \
swanparll.$(EXTO)

.SUFFIXES: .f .for .f90

.PHONY: help clean clobber

help:
	@echo "This Makefile supports the following:"
	@echo "make config    -- makes machine-dependent macros include file"
	@echo "make ser       -- makes the serial $(SWASH_EXE) executable"
	@echo "make mpi       -- makes the    MPI $(SWASH_EXE) executable"
	@echo "make doc       -- makes the SWASH documentation (PDF)"
	@echo "make html      -- makes the html pages of SWASH documentation"
	@echo "make clean     -- removes compiled objects and modules"
	@echo "make clobber   -- removes compiled objects, modules and $(SWASH_EXE)"
	@echo "make cleandoc  -- removes all SWASH documents"

config:
	@perl platform.pl

install:
	@perl platform.pl

ser:
	@perl switch.pl $(swch) *.ftn *.ftn90
	$(MAKE) FOR=$(F90_SER) FFLAGS="$(FLAGS_OPT) $(FLAGS_MSC) $(FLAGS_SER)" \
	        FFLAGS90="$(FLAGS_OPT) $(FLAGS90_MSC) $(FLAGS_SER)" \
                INCS="$(INCS_SER)" LIBS="$(LIBS_SER)" OBJS="$(SWASH_OBJS)" $(SWASH_EXE)

mpi:
	@perl switch.pl $(swch) -mpi *.ftn *.ftn90
	$(MAKE) FOR=$(F90_MPI) FFLAGS="$(FLAGS_OPT) $(FLAGS_MSC) $(FLAGS_MPI)" \
	        FFLAGS90="$(FLAGS_OPT) $(FLAGS90_MSC) $(FLAGS_MPI)" \
                INCS="$(INCS_MPI)" LIBS="$(LIBS_MPI)" OBJS="$(SWASH_OBJS)" $(SWASH_EXE)

doc:
	mv swashuse.tex swashuse.tex.temp
	mv swashtech.tex swashtech.tex.temp
	@perl -p -e 's/^%%PDF//' swashuse.tex.temp > swashuse.tex
	@perl -p -e 's/^%%PDF//' swashtech.tex.temp > swashtech.tex
	$(MAKE) -f Makefile.latex TARGET=swashuse doc
	$(MAKE) -f Makefile.latex TARGET=swashtech doc
	$(MAKE) -f Makefile.latex TARGET=swashimp doc
	$(RM) swashuse.ind swashuse.idx swashtech.ind swashtech.idx
	mv swashuse.tex.temp swashuse.tex
	mv swashtech.tex.temp swashtech.tex

html:
	mv swashuse.tex swashuse.tex.temp
	mv swashtech.tex swashtech.tex.temp
	@perl -p -e 's/^%%HTML//' swashuse.tex.temp > swashuse.tex
	@perl -p -e 's/^%%HTML//' swashtech.tex.temp > swashtech.tex
	make4ht -u -c sizefig.cfg -e addbi swashuse.tex "pic-tabbing,svg"
	$(RM) swashgrid.pdf rettime.pdf layer.pdf stagg2.pdf
	mkdir swashuse
	mv *.html *.svg swashuse.css swashuse
	make4ht -u -c sizefig.cfg -e addbi swashtech.tex mathjax
	mkdir swashtech
	mv *.html *.svg swashtech.css swashtech
	cp *.png swashtech
	make4ht -u -c clist.cfg swashimp.tex "pic-tabbing,svg"
	mkdir swashimp
	mv *.html *.svg swashimp.css swashimp 
	$(RM) swash*.blg swash*.bbl swash*.4ct swash*.xref swash*.log swash*.idx swash*.ind swash*.ilg swash*.dvi swash*.aux swash*.4tc swash*.lg swash*.idv swash*.tmp
	mv swashuse.tex.temp swashuse.tex
	mv swashtech.tex.temp swashtech.tex

$(SWASH_EXE): $(OBJS)
	$(FOR) $(OBJS) $(FFLAGS) $(OUT)$(SWASH_EXE) $(INCS) $(LIBS)

.f.o:
	$(FOR) $< -c $(FFLAGS) $(INCS)

.f90.o:
	$(FOR) $< -c $(FFLAGS90) $(INCS)

.for.o:
	$(FOR) $< -c $(FFLAGS) $(INCS)

.for.obj:
	$(FOR) $< -c $(FFLAGS) $(INCS)

.f90.obj:
	$(FOR) $< -c $(FFLAGS90) $(INCS)

clean:
	$(RM) *.$(EXTO) *.mod

clobber:
	$(RM) *.$(EXTO) *.mod *.f *.for *.f90 $(SWASH_EXE)

cleandoc:
	$(MAKE) -f Makefile.latex TARGET=swashuse cleandoc
	$(MAKE) -f Makefile.latex TARGET=swashtech cleandoc
	$(MAKE) -f Makefile.latex TARGET=swashimp cleandoc

allclean:
	$(RM) *.$(EXTO) *.mod *.f *.for *.f90 $(SWASH_EXE)
	$(MAKE) -f Makefile.latex TARGET=swashuse cleandoc
	$(MAKE) -f Makefile.latex TARGET=swashtech cleandoc
	$(MAKE) -f Makefile.latex TARGET=swashimp cleandoc
