#
# File:         MakeConfigs.Makefile
# Project:	PerlUtils %PP%
# Item:   	%PI% (%PF%)
# Desc:
#
#   This Makefile is used to setup, build and Install MakeConfigs
#   for use by the project.
#
# Notes:
#
# Author:	Paul Houghton - <paul.houghton@wcom.com>
# Created:	03/05/01 04:44
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

SHELL	= /bin/ksh
hide	= @

tools_archive_dir	= $(TOOL_DIR)/src/Archives
tools_build_dir		= $(TOOL_DIR)/src/Build/Tools
tools_inc_dir		= $(TOOL_DIR)/include
tools_bin_dir		= $(TOOL_DIR)/bin
tools_info_dir		= $(TOOL_DIR)/info

make_configs_vars_file	= \
	$(PROJECT_DIR)/support/.makeconfigs.configvars

setup_output	= >> $(EXTRACT_DIR)/$(PROJECT_DIR)/.setup.output 2>&1

GZIP_EXTRACT_DIR	= $(tools_build_dir)
GZIP_NAME		= gzip
GZIP_VER		= 1.2.4
GZIP_DOC		= http://www.gnu.org/software/gzip gzip(info)
GZIP_DESC_CMD		=	\
	echo gzip is a program for compressing and decompressing files.
GZIP_build_dir		= $(GZIP_NAME)-$(GZIP_VER)
GZIP_tar		= $(tools_archive_dir)/gzip-$(GZIP_VER).tar
GZIP_target		= $(tools_bin_dir)/gzip

MAKE_CONFIGS_EXTRACT_DIR	= $(tools_build_dir)
MAKE_CONFIGS_NAME		= MakeConfigs
MAKE_CONFIGS_VER		= $(make_cfg_ver)
MAKE_CONFIGS_DOC		= $(INSTALL_DOC_HTML_DIR)/Tools/MakeConfigs
MAKE_CONFIGS_DESC_CMD		= \
	cat $(MAKE_CONFIGS_EXTRACT_DIR)/$(MAKE_CONFIGS_build_dir)/src/config/.prjdesc.txt
MAKE_CONFIGS_build_dir		= $(MAKE_CONFIGS_NAME)-$(MAKE_CONFIGS_VER)
MAKE_CONFIGS_tar		= \
	$(tools_archive_dir)/$(MAKE_CONFIGS_NAME)-$(MAKE_CONFIGS_VER).tar.gz
MAKE_CONFIGS_target	= $(tools_inc_dir)/Make/make.cfg.$(MAKE_CONFIGS_VER)

MAKE_CONFIGS_TOOLS	= GZIP MAKE_CONFIGS

MAKE_CONFIGS_PROJECT_VARS	=	\
	MAKE_CONFIGS_PROJECT_VARS	\
					\
	MAKE_CONFIGS_TOOLS		\
					\
	GZIP_EXTRACT_DIR		\
	GZIP_NAME			\
	GZIP_VER			\
	GZIP_DOC			\
	GZIP_DESC_CMD			\
					\
	MAKE_CONFIGS_EXTRACT_DIR	\
	MAKE_CONFIGS_NAME		\
	MAKE_CONFIGS_VER		\
	MAKE_CONFIGS_DOC		\
	MAKE_CONFIGS_DESC_CMD

anon_ftp_cmd	= $(PROJECT_DIR)/support/AnonFtp.ksh
zcat_cmd	= $(tools_bin_dir)/zcat
mkdirhier_cmd	= $(PROJECT_DIR)/support/mkdirhier.sh

tools_subdirs	=		\
	$(tools_archive_dir)	\
	$(tools_build_dir)	\
	$(tools_bin_dir)

setup_targets	=		\
	$(GZIP_target)		\
	$(MAKE_CONFIGS_target)

#
# Targets
#
default:
	@echo "+ You should NOT directly call this makefile. the following"
	@echo "+ variables are needed:"
	@echo
	@echo "+    PROJECT_DIR=$(PROJECT_DIR)"
	@echo "+    TOOL_DIR=$(TOOL_DIR)"
	@echo "+    make_cfg_ver=$(make_cfg_ver)"
	@echo "+    tools_host=$(tools_host)"
	@echo "+    tools_host_dir=$(tools_host_dir)"

prep:
	$(hide) chmod +x $(anon_ftp_cmd)
	$(hide) chmod +x $(mkdirhier_cmd)


$(tools_subdirs):
	$(hide) $(mkdirhier_cmd) $@

tools_dirs: $(tools_subdirs)

$(GZIP_tar) $(MAKE_CONFIGS_tar):
	$(hide) echo "+ Ftp'ing `basename $@` from $(tools_host) ...\c"
	$(hide) $(anon_ftp_cmd)						\
	    $(tools_host)						\
	    $(tools_host_dir)/`basename $@` $(tools_archive_dir)
	$(hide) echo "Done -" `date`

$(GZIP_target): $(GZIP_tar)
	$(hide) echo "+ Installing $(GZIP_NAME) ...\c"		\
	&& cd $(GZIP_EXTRACT_DIR)				\
	&& rm -rf  $(GZIP_build_dir)				\
	&& tar xf $(GZIP_tar)					\
	&& cd $(GZIP_build_dir)					\
	&& ./configure --prefix=$(TOOL_DIR) $(setup_output)	\
	&& $(MAKE) $(setup_output)				\
	&& $(MAKE) install $(setup_output)			\
	&& echo " Done -" `date`

$(MAKE_CONFIGS_target): $(MAKE_CONFIGS_tar)
	$(hide) echo "+ Installing $(MAKECONFIGS_NAME) ...\c"		\
	&& cd $(MAKE_CONFIGS_EXTRACT_DIR)				\
	&& $(tools_bin_dir)/zcat $^ | tar xf -				\
	&& make -f $(MAKE_CONFIGS_build_dir)/Setup.Makefile setup	\
	&& $(tools_bin_dir)/make -C MakeConfigs-$(make_cfg_ver)		\
		install $(setup_output)					\
	&& echo " Done -" `date`

config_vars_cmd =						\
	$(foreach var, $(MAKE_CONFIGS_PROJECT_VARS),		\
	    echo "$(var)	= $($(var))" >> $@; )

$(make_configs_vars_file): .force
	@echo "# This file was generated by MakeConfigs.Makefile" > $@
	@$(config_vars_cmd)

gen_config_file:
	$(hide) $(tools_bin_dir)/make				\
		-f $(PROJECT_DIR)/support/MakeConfigs.Makefile	\
		$(make_configs_vars_file)

setup: prep tools_dirs $(setup_targets) gen_config_file


.force:


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
