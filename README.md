# shared-image-gallery-scripts

This is the collection of terraform and packer scripts for Azure.

Packer:
1.  To push the image to Shared Image Gallery, see PackerLinux-Generalized-1.json

Terraform:
2. To use “generalized” image from a shared image gallery in a different subscription, see vm-main-generalized-image-windows.tf or vm-main-generalized-image-linux.tf 
3. To use “specialized” image from a shared image gallery in a different subscription, see vm-main-specialized-image.tf
