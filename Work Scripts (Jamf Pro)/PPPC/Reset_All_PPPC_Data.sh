#!/bin/bash

########################################################################
#           Reset All Privacy Preferences Policy Control Data          #
#################### Written by Phil Walker Mar 2020 ###################
########################################################################

# For use during enrolment only to avoid any issue with screen sharing
# displaying a black screen only

########################################################################
#                         Script starts here                           #
########################################################################

# Reset all privacy consent data (root database only)
tccutil reset All

exit 0