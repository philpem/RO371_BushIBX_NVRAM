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
EXP_H   = <CExport$Dir>.h
EXP_HDR = <export$dir>.^.Interface2

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
CFLAGS  = -c -depend !Depend -zM -zps1 -ffa ${INCLUDES} ${THROWBACK}
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
DEBUGLIB  = <Lib$Dir>.DebugLib.o.DebugLibzm TCPIPLibs:o.unixlibzm TCPIPLibs:o.inetlibzm TCPIPLibs:o.socklib5zm


#
# Include files
#
INCLUDES = -IC:

#DFLAGS   = -dDEBUG
#DFLAGS   =

#
# Program specific options:
#
COMPONENT = NVRAM
TARGET    = aof.${COMPONENT}
RAMTARGET = rm.${COMPONENT}
TRACERAMTARGET = rm.${COMPONENT}db
OBJS      = header.o module.o nvram.o msgfile.o parse.o trace.o
EXPORTS   = ${EXP_H}.${COMPONENT} ${EXP_HDR}.${COMPONENT}
RDIR      = ${RESDIR}.NVRAM

#
# Rule patterns
#
.SUFFIXES: .o .c .s .cmhg

.c.o:;      ${CC} ${CFLAGS} ${DFLAGS} -o $@ $<
.cmhg.o:;   ${CMHG} -p -d h.header -o $@ $<
.cmhg.h:;       ${CMHG} ${CMHGFLAGS} -d $@ $<
.s.o:;      ${AS} ${AFLAGS} $< $@

#
# build a relocatable module:
#
all: ${RAMTARGET}

trace: ${TRACERAMTARGET}

o.module: h.module

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
	${RM} ${TARGET}
	${RM} ${RAMTARGET}
	@echo ${COMPONENT}: cleaned

resources:
	${MKDIR} ${RDIR}
	${CP} resources.<System>.Tags ${RDIR}.Tags ${CPFLAGS}
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
	${LD} -o linked.${COMPONENT} -rmf -base ${ADDRESS} ${TARGET} ${ABSSYM}
	${CP} linked.${COMPONENT} ${LINKDIR}.${COMPONENT} ${CPFLAGS}
	@echo ${COMPONENT}: rom_link complete

${RAMTARGET}: ${OBJS} ${CLIB}
	${LD} -o $@ -module ${OBJS} ${CLIB}

${TRACERAMTARGET}: ${OBJS} ${CLIB}
	${LD} -o $@ -module ${OBJS} ${CLIB} ${DEBUGLIB}

${EXP_H}.${COMPONENT}: export.h.${COMPONENT}
	${CP} export.h.${COMPONENT} $@ ${CPFLAGS}

${EXP_HDR}.${COMPONENT}: export.hdr.${COMPONENT}
	${CP} export.hdr.${COMPONENT} $@ ${CPFLAGS}

# Dynamic dependencies:
