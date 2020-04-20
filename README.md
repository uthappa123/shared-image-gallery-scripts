# shared-image-gallery-scripts

This is the collection of terraform and packer scripts for Azure.

1.	Packer: To push the image to Shared Image Gallery, see PackerLinux-Generalized-1.json

2.	Terraform: 
a.	To use “generalized” image from a shared image gallery in a different subscription, see vm-main-generalized-image-windows.tf or vm-main-generalized-image-linux.tf

b.	To use “specialized” image from a shared image gallery in a different subscription, see vm-main-specialized-image.tf
