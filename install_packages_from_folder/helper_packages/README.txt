#######################
# helper_packages #
#######################

The Helper package directory is used to store scripts and installers which may be required by the the PrinterSetup installer.

Example 1 :
=========== 
If you downlaod InstallPKG from http://www.lucidsystems.org and place the InstallPKG.pkg bundle withing this directory. Then then this utility will be installed, and then used to install other packages placed into the "additional_packages" directory.

In addition you may place the InstallPKG-Uninstall uninstall script into this folder, to uninstall the InstallPKG package once it has complelted its job.

Both these steps can be perfomed by double clicking the "enable_additional_packages" script in the "helper_packags" directory. This will download and InstallPKG and the uninstall script into the "hleper_packages" driectory.
