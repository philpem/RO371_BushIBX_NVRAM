# Copyright 1997 Acorn Computers Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Makefile for NVRAM
#

#
# Paths
#
EXP_HDR = <CExport$Dir>.h

#
# Generic options:
#
MKDIR   = cdir
AS      = objasm
CC      = cc
CMHG    = cmhg
CP      = copy
LD      = link
RM      = remove
WIPE    = -wipe

AFLAGS = -depend !Depend -Stamp -quit
CFLAGS  = -c -depend !Depend -zM -zps1 -ff ${INCLUDES} ${DFLAGS}
CPFLAGS = ~cfr~v
WFLAGS  = ~c~v

#
# Libraries
#
CLIB      = CLIB:o.stubs
RLIB      = RISCOSLIB:o.risc_oslib
RSTUBS    = RISCOSLIB:o.rstubs
ROMSTUBS  = RISCOSLIB:o.romstubs
ROMCSTUBS = RISCOSLIB:o.romcstubs
ABSSYM    = RISC_OSLib:o.AbsSym

#
# Include files
#
INCLUDES = -IC:

#DFLAGS   = -dDEBUG
DFLAGS   =

#
# Program specific options:
#
COMPONENT = NVRAM
TARGET    = aof.${COMPONENT}
RAMTARGET = rm.${COMPONENT}
OBJS      = header.o module.o nvram.o msgfile.o parse.o trace.o
EXPORTS   = ${EXP_HDR}.${COMPONENT}
RDIR      = ${RESDIR}.NVRAM

#
# Rule patterns
#
.c.o:;      ${CC} ${CFLAGS} -o $@ $<
.cmhg.o:;   ${CMHG} -o $@ $<
.s.o:;      ${AS} ${AFLAGS} $< $@

#
# build a relocatable module:
#
all: ${RAMTARGET}

#
# RISC OS ROM build rules:
#
rom: ${TARGET}
	@echo ${COMPONENT}: rom module built

export: ${EXPORTS}
	@echo ${COMPONENT}: export complete

install_rom: ${TARGET}
	${CP} ${TARGET} ${INSTDIR}.${COMPONENT} ${CPFLAGS}
	@echo ${COMPONENT}: rom module installed

clean:
	${WIPE} o.* ${WFLAGS}
	${WIPE} linked.* ${WFLAGS}
	${WIPE} map.* ${WFLAGS}
	${RM} ${TARGET}
	${RM} ${RAMTARGET}
	@echo ${COMPONENT}: cleaned

resources:
	${MKDIR} ${RDIR}
	${CP} resources.<Machine>.Tags ${RDIR}.Tags ${CPFLAGS}
	@echo ${COMPONENT}: resource files copied

#
# ROM target (re-linked at ROM Image build time)
#
${TARGET}: ${OBJS} ${ROMCSTUBS}
	${LD} -o $@ -aof ${OBJS} ${ROMCSTUBS}

#
# Final link for the ROM Image (using given base address)
#
rom_link:
	${LD} -o linked.${COMPONENT} -map -bin -base ${ADDRESS} ${TARGET} ${ABSSYM} > map.${COMPONENT}
	truncate map.${COMPONENT} linked.${COMPONENT}
	${CP} linked.${COMPONENT} ${LINKDIR}.${COMPONENT} ${CPFLAGS}
	@echo ${COMPONENT}: rom_link complete

${RAMTARGET}: ${OBJS} ${CLIB}
	${LD} -o $@ -module ${OBJS} ${CLIB}

${EXP_HDR}.${COMPONENT}: export.h.${COMPONENT}
	${CP} export.h.${COMPONENT} $@ ${CPFLAGS}

# Dynamic dependencies:
