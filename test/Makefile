#
# File:         Setup.Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
#
#   This Makefile builds the targets in all the test subdirectories.
#
# Notes:
#
# Author:	Paul Houghton <paul4hough@gmail.com>
# Created:	5/30/101 using GenProject 6.01.01
#
# Revision History: (See end of file for Revision Log)
#
#   Last Mod By:    %PO%
#   Last Mod:	    %PRT%
#   Version:	    %PIV%
#   Status:	    %PS%
#
#   %PID%
#

show_commands 	= # true
force	 	= # true

PRJ_TOPDIR	= ..
config_dir	= $(PRJ_TOPDIR)/src/config

include $(config_dir)/00-Makefile.cfg
include Make/make.cfg.$(make_cfg_ver)

SUBDIRS		=							      \

TARGETS		= $(standard_targets) debug

HELP_TARGETS	= $(TARGETS)
PHONY_TARGETS	= $(TARGETS)

include Make/make.cfg.targets.common.$(make_cfg_ver)

$(TARGETS)::
	$(call make_subdirs,$@,$(SUBDIRS),$($(@)_exports) $(exports))



#
# Revision Log:
#
#
# %PL%
#
#

# Set XEmacs mode
#
# Local Variables:
# mode:makefile
# End:
