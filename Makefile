##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : <unknown>
#  Created       : Sun Oct 1 12:39:19 2023
#  Last Modified : <231001.1240>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
#
#  Copyright (c) 2023 <unknown>.
# 
#  All Rights Reserved.
# 
#  This  document  may  not, in  whole  or in  part, be  copied,  photocopied,
#  reproduced,  translated,  or  reduced to any  electronic  medium or machine
#  readable form without prior written consent from <unknown>.
#
##############################################################################


default:
	cd doc && pantcl tclmain.md tclmain.html -s
	cd doc && htmlark tclmain.html -o tclmain-out.html
	cd doc && mv tclmain-out.html tclmain.html
