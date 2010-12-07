#
# Copyright 2004-2005 Sun Microsystems, Inc.  All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   - Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#   - Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#   - Neither the name of Sun Microsystems nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

########################################################################
#
# Sample GNU Makefile for building 
#
#  Example uses:    
#       gnumake JDK=<java_home> [OPT=true] [LIBARCH=sparc]
#       gnumake JDK=<java_home> [OPT=true] [LIBARCH=sparcv9]
#       gnumake JDK=<java_home> [OPT=true]
#       gnumake JDK=<java_home> [OPT=true]
#
########################################################################

# Source lists
LIBNAME=hprof2
SOURCES= \
    debug_malloc.c	\
    hprof_blocks.c	\
    hprof_check.c \
    hprof_class.c	\
    hprof_cpu.c		\
    hprof_error.c	\
    hprof_event.c	\
    hprof_frame.c	\
    hprof_init.c	\
    hprof_io.c		\
    hprof_ioname.c	\
    hprof_listener.c	\
    hprof_loader.c	\
    hprof_monitor.c	\
    hprof_object.c	\
    hprof_reference.c	\
    hprof_site.c	\
    hprof_stack.c	\
    hprof_string.c	\
    hprof_table.c	\
    hprof_tag.c		\
    hprof_tls.c		\
    hprof_trace.c	\
    hprof_tracker.c	\
    hprof_util.c	\
    hprof_md.c \
    java_crw_demo.c

JAVA_SOURCES=Tracker.java

BUILD_OS := $(strip $(shell uname -s | tr '[:upper:]' '[:lower:]'))
OS ?= $(BUILD_OS)
ifeq ($(OS),sunos)
  OS = solaris
endif

# Name of jar file that needs to be created
#JARFILE=hprof.jar

# Solaris Sun C Compiler Version 5.5
ifeq ($(OS), solaris)
    # Sun Solaris Compiler options needed
    COMMON_FLAGS=-mt -KPIC
    # Options that help find errors
    COMMON_FLAGS+= -Xa -v -xstrconst -xc99=%none
    # To make hprof logging code available
    COMMON_FLAGS+= -DHPROF_LOGGING
    # Check LIBARCH for any special compiler options
    LIBARCH=$(shell uname -p)
    ifeq ($(LIBARCH), sparc)
        COMMON_FLAGS+=-xarch=v8 -xregs=no%appl
    endif
    ifeq ($(LIBARCH), sparcv9)
        COMMON_FLAGS+=-xarch=v9 -xregs=no%appl
    endif
    ifeq ($(OPT), true)
        CFLAGS=-xO2 $(COMMON_FLAGS)  -DNDEBUG
    else
        CFLAGS=-g $(COMMON_FLAGS) -DDEBUG
    endif
    # Object files needed to create library
    OBJECTS=$(SOURCES:%.c=%.o)
    # Library name and options needed to build it
    LIBRARY=lib$(LIBNAME).so
    LDFLAGS=-z defs -ztext
    # Libraries we are dependent on
    LIBRARIES=-lsocket -lnsl -ldl -lc
    # Building a shared library
    LINK_SHARED=$(LINK.c) -G -o $@
endif

# Linux GNU C Compiler
ifeq ($(OS), linux)
    # GNU Compiler options needed to build it
    COMMON_FLAGS=-fno-strict-aliasing -fPIC -fno-omit-frame-pointer
    # Options that help find errors
    COMMON_FLAGS+= -W -Wall  -Wno-unused -Wno-parentheses
    # To allow access to dladdr()
    COMMON_FLAGS+= -D_GNU_SOURCE
    # To prevent include of procfs.h
    COMMON_FLAGS+= -DLINUX
    # To make sure code is reentrant
    COMMON_FLAGS+= -D_REENTRANT
    # To make hprof logging code available
    COMMON_FLAGS+= -DHPROF_LOGGING
    ifeq ($(OPT), true)
        CFLAGS=-O2 $(COMMON_FLAGS)  -DNDEBUG
    else
        CFLAGS=-g $(COMMON_FLAGS)  -DDEBUG
    endif
    # Object files needed to create library
    OBJECTS=$(SOURCES:%.c=%.o)
    # Library name and options needed to build it
    LIBRARY=lib$(LIBNAME).so
    LDFLAGS=-Wl,-soname=$(LIBRARY) -static-libgcc -mimpure-text
    # Libraries we are dependent on
    LIBRARIES= -lnsl -ldl -lc
    # Building a shared library
    LINK_SHARED=$(LINK.c) -shared -o $@
endif

# Darwin (same as linux...I don't know make well enough)
ifeq ($(OS), darwin)
    # GNU Compiler options needed to build it
    COMMON_FLAGS=-fno-strict-aliasing -fPIC -fno-omit-frame-pointer
    # Options that help find errors
    COMMON_FLAGS+= -W -Wall  -Wno-unused -Wno-parentheses
    # To allow access to dladdr()
    COMMON_FLAGS+= -D_GNU_SOURCE
    # To prevent include of procfs.h
    COMMON_FLAGS+= -DLINUX
    # To make sure code is reentrant
    COMMON_FLAGS+= -D_REENTRANT
    # To make hprof logging code available
    COMMON_FLAGS+= -DHPROF_LOGGING
    # fat binary
    COMMON_FLAGS+= -arch i386 -arch x86_64
    ifeq ($(OPT), true)
        CFLAGS=-O2 $(COMMON_FLAGS)  -DNDEBUG
    else
        CFLAGS=-g $(COMMON_FLAGS)  -DDEBUG
    endif
    # Object files needed to create library
    OBJECTS=$(SOURCES:%.c=%.o)
    # Library name and options needed to build it
    LIBRARY=lib$(LIBNAME).jnilib
    LDFLAGS=-shared
    # Libraries we are dependent on
    LIBRARIES=-ldl -lc
    # Building a shared library
    LINK_SHARED=$(LINK.c) -shared -o $@
endif

# Windows Microsoft C/C++ Optimizing Compiler Version 12
ifeq ($(OS), win32)
    CC=cl
    # Compiler options needed to build it
    COMMON_FLAGS=-Gy -DWIN32
    # Options that help find errors
    COMMON_FLAGS+=-W0 -WX
    # To make hprof logging code available
    COMMON_FLAGS+= -DHPROF_LOGGING
    ifeq ($(OPT), true)
        CFLAGS= -Ox -Op -Zi $(COMMON_FLAGS)  -DNDEBUG
    else
        CFLAGS= -Od -Zi $(COMMON_FLAGS)  -DDEBUG
    endif
    # Add java_crw_demo source
    SOURCES += ../java_crw_demo.c
    # Object files needed to create library
    OBJECTS=$(SOURCES:%.c=%.obj)
    # Library name and options needed to build it
    LIBRARY=$(LIBNAME).dll
    LDFLAGS=
    # Libraries we are dependent on
    LIBRARIES=wsock32.lib winmm.lib
    # Building a shared library
    LINK_SHARED=link -dll -out:$@
endif

# Common -I options
CFLAGS += -I.
CFLAGS += -I../java_crw_demo

ifeq ($(OS), darwin)
  CFLAGS += -I/System/Library/Frameworks/JavaVM.framework/Headers
  CFLAGS += -I../bsd-port/jdk/src/share/javavm/export
  CFLAGS += -I../bsd-port/jdk/src/solaris/javavm/export
  CFLAGS += -I../bsd-port/jdk/src/share/demo/jvmti/java_crw_demo
  CFLAGS += -DSKIP_NPT
else
  CFLAGS += -I$(JDK)/include -I$(JDK)/include/$(OS)
endif

# Default rule (build both native library and jar file)
all: hprof_md.c $(LIBRARY) $(JARFILE)

# Get platform specific hprof_md.c
# hprof_md.c:
	# rm -f $@
	# cp $(OS)/hprof_md.c $@

# Build native library
$(LIBRARY): $(OBJECTS)
	$(LINK_SHARED) $(OBJECTS) $(LIBRARIES)

# Build jar file
$(JARFILE): $(JAVA_SOURCES)
	rm -f -r classes
	mkdir -p classes
	$(JDK)/bin/javac -d classes $(JAVA_SOURCES)
	(cd classes; $(JDK)/bin/jar cf ../$@ *)

# Cleanup the built bits
clean:
	rm -f -r classes
	rm -f $(LIBRARY) $(JARFILE) $(OBJECTS)

# Simple tester
test: all
	LD_LIBRARY_PATH=. $(JDK)/bin/java -agentlib:$(LIBNAME) -Xbootclasspath/a:./$(JARFILE) -version

# Compilation rule only needed on Windows
ifeq ($(OS), win32)
%.obj: %.c
	$(COMPILE.c) $<
endif

